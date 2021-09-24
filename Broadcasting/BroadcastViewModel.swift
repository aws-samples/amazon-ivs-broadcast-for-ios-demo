//
//  BroadcastViewModel.swift
//  Broadcasting
//
//  Created by Uldis Zingis on 11/06/2021.
//

import AmazonIVSBroadcast

class BroadcastViewModel: NSObject, ObservableObject {

    @Published var sessionIsRunning: Bool = false
    @Published var cameraIsOn: Bool = true
    @Published var isMuted: Bool = false
    @Published var activeCameraDescriptor: IVSDeviceDescriptor?
    @Published var settingsOpen = false
    @Published var developerMode: Bool = false
    @Published var hasBeenStarted: Bool = false
    @Published var isReconnecting: Bool = false {
        didSet { isReconnectViewVisible = isReconnecting }
    }
    @Published var isReconnectViewVisible: Bool = false
    @Published var shouldReconnect: Bool = false
    @Published var errorMessage: String?
    @Published var ingestServer: String {
        didSet {
            guard ingestServer != Constants.ingestServer else { return }
            configurations.userDefaults.setValue(ingestServer, forKey: Constants.kIngestServer)
        }
    }
    @Published var streamKey: String {
        didSet {
            guard streamKey != Constants.streamKey else { return }
            configurations.userDefaults.setValue(streamKey, forKey: Constants.kStreamKey)
        }
    }
    @Published var playbackUrl: String {
        didSet {
            guard playbackUrl != Constants.playbackUrl else { return }
            configurations.userDefaults.setValue(playbackUrl, forKey: Constants.kPlaybackUrl)
        }
    }
    @Published var defaultCameraUrn: String {
        didSet {
            configurations.userDefaults.setValue(defaultCameraUrn, forKey: Constants.kDefaultCamera)
            if let defaultCamera = availableCameraDevices.first(where: { $0.urn == defaultCameraUrn }) {
                activeCameraDescriptor = defaultCamera
                attachDeviceCamera()
            }
        }
    }
    @Published var isScreenSharingActive: Bool = false
    @Published var canFlipCamera: Bool = true
    @Published var canStartSession: Bool = true
    @Published var canToggleCamera: Bool = true

    let broadcastDelegate = BroadcastDelegateViewController()
    var configurations = BroadcastConfiguration.shared
    var broadcastSession: IVSBroadcastSession?
    var previewView: BroadcastPreview?
    var broadcastPicker: RPSystemBroadcastPicker

    var watchUrl: URL? {
        return URL(string: "https://www.ivs.rocks/live#\(playbackUrl)")
    }
    var initialBitrate: Double {
        return Double(configurations.activeVideoConfiguration.initialBitrate) / 1000
    }
    var formattedInitialBitrate: String {
        return String(format: "%.0fKbps", locale: Locale.current, initialBitrate)
    }
    var dataUsePerHour: Double {
        return initialBitrate * 0.125 * 3600.0 * 0.000001
    }
    var activeQuality: String {
        return "\(Int(configurations.activeVideoConfiguration.size.height ))p\(Int(configurations.activeVideoConfiguration.targetFramerate))"
    }
    var availableCameraDevices: [IVSDeviceDescriptor] {
        return IVSBroadcastSession.listAvailableDevices().filter { $0.type == .camera }
    }

    private var networkMonitor: MonitorNetwork?
    private var customImageSource: IVSCustomImageSource?
    private var attachedCamera: IVSDevice?
    private var sessionWasRunningBeforeInterruption = false

    override init() {
        ingestServer = configurations.userDefaults.string(forKey: Constants.kIngestServer) ?? Constants.ingestServer
        streamKey = configurations.userDefaults.string(forKey: Constants.kStreamKey) ?? Constants.streamKey
        playbackUrl = configurations.userDefaults.string(forKey: Constants.playbackUrl) ?? Constants.playbackUrl
        defaultCameraUrn = configurations.userDefaults.string(forKey: Constants.kDefaultCamera) ??
            IVSPresets.devices().frontCamera().first!.urn
        broadcastPicker = RPSystemBroadcastPicker()
        super.init()
    }

    deinit {
        configurations.userDefaults.removeObserver(self, forKeyPath: Constants.kReplayKitSessionHasBeenStarted)
    }

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        isScreenSharingActive = configurations.userDefaults.bool(forKey: Constants.kReplayKitSessionHasBeenStarted)
        if isScreenSharingActive {
           broadcastSession?.stop()
        }
    }

    func observeUserDefaultChanges() {
        configurations.userDefaults.addObserver(
            self,
            forKeyPath: Constants.kReplayKitSessionHasBeenStarted,
            options: [.initial],
            context: nil)
    }

    func initializeBroadcastSession() {
        guard !sessionIsRunning else {
            previewView?.attachCameraPreview()
            return
        }

        if previewView == nil {
            previewView = BroadcastPreview(viewModel: self)
        }

        if activeCameraDescriptor == nil {
            let defaultCamera = availableCameraDevices.first(where: { $0.urn == defaultCameraUrn })
            activeCameraDescriptor = defaultCamera ?? IVSPresets.devices().frontCamera().first
        }

        do {
            configurations.setupSlots()
            // Create the session with a preset config and camera/microphone combination.
            broadcastSession = try IVSBroadcastSession(configuration: configurations.activeConfiguration,
                                                       descriptors: nil,
                                                       delegate: broadcastDelegate)
            broadcastDelegate.viewModel = self
            attachedCamera = nil
            attachDeviceCamera()
            attachDeviceMic()
        } catch {
            print("❌ Error initializing IVSBroadcastSession: \(error)")
        }
    }

    func toggleBroadcastSession() {
        if let session = broadcastSession, sessionIsRunning {
            session.stop()
            UIApplication.shared.isIdleTimerDisabled = false
        } else {
            initializeBroadcastSession()
            do {
                guard let url = URL(string: ingestServer) else {
                    print("Ingest server not set or invalid")
                    return
                }
                try broadcastSession?.start(with: url, streamKey: streamKey)
                UIApplication.shared.isIdleTimerDisabled = true
            } catch {
                print("❌ Error starting IVSBroadcastSession: \(error)")
            }
        }
    }

    func toggleCamera() {
        canToggleCamera = false
        if cameraIsOn {
            attachCameraOffImage()
        } else {
            attachDeviceCamera { [weak self] in
                self?.customImageSource = nil
                self?.cameraIsOn.toggle()
                self?.canToggleCamera = true
            }
        }
    }

    func flipCamera() {
        canFlipCamera = false
        activeCameraDescriptor = getCameraDescriptor(for: attachedCamera?.descriptor().position == .back ? .front : .back)
        attachDeviceCamera { [weak self] in
            self?.canFlipCamera = true
        }
    }

    func mute() {
        isMuted.toggle()
        toggleMic(!isMuted)
    }

    func runAutoConfig(progressUpdate: ((_ progress: Float) -> Void)? = nil, _ callback: @escaping (Error?) -> Void) {
        guard let url = URL(string: ingestServer) else {
            callback(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Ingest server not set or invalid"]))
            return
        }

        initializeBroadcastSession()
        broadcastSession?.recommendedVideoSettings(
            with: url,
            streamKey: streamKey,
            results: { [weak self] testResult in
                progressUpdate?(testResult.progress)
                switch testResult.status {
                case .connecting, .testing:
                    break
                case .success:
                    if let settings = testResult.recommendations.first {
                        guard let self = self else { return }
                        self.configurations.setVideoBitrate(settings.initialBitrate / 1000)
                        self.configurations.setFramerate(to: settings.targetFramerate)
                        self.configurations.updateResolution(for: Resolution.sizeFor(self.configurations.customOrientation, a: Int(settings.size.width), b: Int(settings.size.height)))
                    }
                    callback(nil)
                case .error:
                    callback(testResult.error)
                @unknown default:
                    callback(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown test result status!"]))
                }
        })
    }

    func reconnectOnceNetworkIsAvailable() {
        isReconnecting = true
        sessionIsRunning = false
        shouldReconnect = true

        networkMonitor = MonitorNetwork(onNetworkAvailable: { [weak self] in
            if self?.shouldReconnect == true {
                self?.toggleBroadcastSession()
                self?.networkMonitor = nil
            }
        })
    }

    func reconnect() {
        isReconnecting = true
        sessionIsRunning = false
        toggleBroadcastSession()
    }

    func cancelAutoReconnect() {
        shouldReconnect = false
        isReconnecting = false
    }

    func deviceOrientationChanged(toLandscape: Bool) {
        if (configurations.customOrientation == .auto) {
            let configWidth = configurations.activeVideoConfiguration.size.width
            let configHeight = configurations.activeVideoConfiguration.size.height

            let width = toLandscape ? max(configWidth, configHeight) : min(configWidth, configHeight)
            let height = toLandscape ? min(configWidth, configHeight) : max(configWidth, configHeight)

            let error = configurations.updateResolution(for: CGSize(width: width, height: height))
            if error == nil {
                initializeBroadcastSession()
            }
        }
    }

    @objc func audioSessionInterrupted(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue)
        else { return }

        switch type {
        case .began:
            sessionWasRunningBeforeInterruption = sessionIsRunning
            toggleBroadcastSession()
        case .ended:
            defer {
                sessionWasRunningBeforeInterruption = false
            }
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) && sessionWasRunningBeforeInterruption {
                toggleBroadcastSession()
            }
        @unknown default:
            break
        }
    }

    // Private functions

    private func attachDeviceCamera(_ callback: @escaping () -> Void = {}) {
        guard let activeDescriptor = activeCameraDescriptor,
              let activeCamera = IVSBroadcastSession.listAvailableDevices()
                .first(where: { $0.urn == activeDescriptor.urn }) else { return }

        if let customImageSource = customImageSource {
            broadcastSession?.detach(customImageSource, onComplete: { [weak self] in
                self?.customImageSource = nil
            })
        }

        let onComplete: ((IVSDevice?, Error?) -> Void)? = { [weak self] device, error in
            if let error = error { print("❌ Error attaching/exchanging camera: \(error)") }
            self?.attachedCamera = device
            self?.previewView?.attachCameraPreview()
            callback()
        }

        if let attachedCamera = attachedCamera {
            broadcastSession?.exchangeOldDevice(attachedCamera, withNewDevice: activeCamera, onComplete: onComplete)
        } else {
            broadcastSession?.attach(activeCamera, toSlotWithName: Constants.cameraSlotName, onComplete: onComplete)
        }
    }

    private func attachDeviceMic() {
        guard let mic = IVSBroadcastSession.listAvailableDevices().first(where: { $0.type == .microphone }) else {
            print("Cannot attach microphone - no available device with type microphone found")
            return
        }
        broadcastSession?.attach(mic, toSlotWithName: Constants.cameraSlotName, onComplete: { [weak self] (device, error)  in
            if let error = error {
                print("❌ Error attaching device microphone to session: \(error)")
            }

            self?.toggleMic(!(self?.isMuted ?? false))
        })
    }

    private func attachCameraOffImage() {
        guard let broadcastSession = broadcastSession else { return }

        // Attach custom image source to slot
        if customImageSource == nil {
            customImageSource = broadcastSession.createImageSource(withName: Constants.cameraOffSlotName)
            broadcastSession.attach(customImageSource!, toSlotWithName: Constants.cameraOffSlotName) { [weak self] error in
                if let error = error { print("❌ Error attaching custom image source: \(error)") }
                self?.cameraIsOn.toggle()
                self?.canToggleCamera = true

                if let attachedCamera = self?.attachedCamera {
                    self?.broadcastSession?.detach(attachedCamera, onComplete: { [weak self] in
                        self?.attachedCamera = nil
                    })
                }
            }
        }

        let image = UIImage(named: "camera_off")!.cmSampleBuffer
        customImageSource?.onSampleBuffer(image)
    }

    private func toggleMic(_ isOn: Bool) {
        broadcastSession?.awaitDeviceChanges({ [weak self] in
            self?.broadcastSession?.listAttachedDevices()
                .filter({ $0.descriptor().type == .microphone || $0.descriptor().type == .userAudio })
                .forEach({
                    if let microphone = $0 as? IVSAudioDevice {
                        microphone.setGain(isOn ? 2 : 0)
                    }
                })
        })
    }

    private func getCameraDescriptor(for position: IVSDevicePosition) -> IVSDeviceDescriptor? {
        let defaultCamera = IVSBroadcastSession.listAvailableDevices().first(where: { $0.urn == defaultCameraUrn })

        if defaultCamera?.position == position {
            return defaultCamera
        } else {
            return IVSBroadcastSession.listAvailableDevices().last(where: { $0.type == .camera && $0.position == position })
        }
    }
}
