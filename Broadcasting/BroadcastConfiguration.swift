//
//  BroadcastConfigurations.swift
//  Broadcasting
//
//  Created by Uldis Zingis on 06/07/2021.
//

import AmazonIVSBroadcast

class BroadcastConfiguration {
    static let shared = BroadcastConfiguration()

    var useCustomResolution: Bool = false
    var customResolution: String?
    var customFramerate: Int?
    var customOrientation: Orientation {
        didSet { onCustomOrientationChange() }
    }

    var activeConfiguration: IVSBroadcastConfiguration = IVSPresets.configurations().basicPortrait()
    var activeVideoConfiguration = IVSVideoConfiguration()
    var activeAudioConfiguration = IVSAudioConfiguration()

    let userDefaults = UserDefaults(suiteName: Constants.appGroupName) ?? UserDefaults.standard

    init() {
        customOrientation = Orientation(rawValue: userDefaults.string(forKey: Constants.kVideoConfigurationOrientation) ?? "auto") ?? .auto

        loadVideoConfiguration()
        loadAudioConfiguration()

        activeConfiguration.video = activeVideoConfiguration
        activeConfiguration.audio = activeAudioConfiguration
        do {
            try activeConfiguration.audio.setChannels(2)
        } catch {
            print("❌ Could not set 2 audio channels: \(error)")
        }

        // Cleanup if the app was suspended while screen sharing was still active
        userDefaults.setValue(false, forKey: Constants.kReplayKitSessionHasBeenStarted)
    }

    func setupSlots() {
        let cameraSlot = IVSMixerSlotConfiguration()
        do { try cameraSlot.setName(Constants.cameraSlotName) } catch {
            print("❌ Could not set camera slot name: \(error)")
        }
        cameraSlot.preferredAudioInput = .microphone
        cameraSlot.preferredVideoInput = .camera
        cameraSlot.matchCanvasAspectMode = false
        cameraSlot.aspect = customOrientation == .auto ? .fit : .fill
        cameraSlot.zIndex = 0

        let cameraOffSlot = IVSMixerSlotConfiguration()
        do { try cameraOffSlot.setName(Constants.cameraOffSlotName) } catch {
            print("❌ Could not set camera off image slot name: \(error)")
        }
        cameraOffSlot.preferredAudioInput = .unknown
        cameraOffSlot.preferredVideoInput = .userImage
        cameraOffSlot.size = UIScreen.main.bounds.size
        cameraOffSlot.aspect = .fill
        cameraOffSlot.zIndex = 1

        activeConfiguration.mixer.slots = [cameraSlot, cameraOffSlot]
    }

    func loadVideoConfiguration() {
        useCustomResolution = userDefaults.bool(forKey: Constants.kVideoConfigurationUseCustomResolution)

        let savedBitrate = userDefaults.integer(forKey: Constants.kVideoConfigurationBitrate)
        if savedBitrate != 0 {
            setVideoBitrate(savedBitrate / 1000)
        }

        let savedKeyframeInterval = userDefaults.float(forKey: Constants.kVideoConfigurationKeyframeInterval)
        if savedKeyframeInterval != 0 {
            setKeyframeInterval(savedKeyframeInterval)
        }
        let savedMaxBitrate = userDefaults.integer(forKey: Constants.kVideoConfigurationMaxBitrate)
        if savedMaxBitrate != 0 {
            setMaxVideoBitrate(savedMaxBitrate)
        }
        let savedMinBitrate = userDefaults.integer(forKey: Constants.kVideoConfigurationMinBitrate)
        if savedMinBitrate != 0 {
            setMinVideoBitrate(savedMinBitrate)
        }
        let savedSizeW = userDefaults.float(forKey: Constants.kVideoConfigurationSizeWidth)
        let savedSizeH = userDefaults.float(forKey: Constants.kVideoConfigurationSizeHeight)
        let savedSize = CGSize(width: CGFloat(savedSizeW == 0 ? 1280 : savedSizeW), height: CGFloat(savedSizeH == 0 ? 720 : savedSizeH))
        updateResolution(for: savedSize)

        let savedTargetFramerate = userDefaults.integer(forKey: Constants.kVideoConfigurationFramerate)
        if savedTargetFramerate != 0 {
            setFramerate(to: savedTargetFramerate)
        }
        if userDefaults.object(forKey: Constants.kVideoConfigurationTransparency) != nil {
            let savedEnableTransparency = userDefaults.bool(forKey: Constants.kVideoConfigurationTransparency)
            activeVideoConfiguration.enableTransparency = savedEnableTransparency
        }
        if userDefaults.object(forKey: Constants.kVideoConfigurationBFrames) != nil {
            let savedUsesBFrames = userDefaults.bool(forKey: Constants.kVideoConfigurationBFrames)
            activeVideoConfiguration.usesBFrames = savedUsesBFrames
        }
        if userDefaults.object(forKey: Constants.kVideoConfigurationAutoBitrate) != nil {
            let savedUseAutoBitrate = userDefaults.bool(forKey: Constants.kVideoConfigurationAutoBitrate)
            activeVideoConfiguration.useAutoBitrate = savedUseAutoBitrate
        }
    }

    func loadAudioConfiguration() {
        let savedBitrate = userDefaults.integer(forKey: Constants.kAudioConfigurationBitrate)
        if savedBitrate != 0 {
            if let error = setAudioBitrate(savedBitrate) {
                print("❌ Error setting saved audio bitrate: \(error.localizedDescription)")
            }
        }
    }

    func setResolutionTo(to resolution: Resolution) -> Error? {
        let size = Resolution.sizeFor(customOrientation, a: resolution.width, b: resolution.height)
        return updateResolution(for: size)
    }

    @discardableResult
    func updateResolution(for size: CGSize) -> Error? {
        let newSize = Resolution.sizeFor(customOrientation, a: Int(size.width), b: Int(size.height))
        do {
            try activeVideoConfiguration.setSize(newSize)
            customResolution = "\(Int(newSize.width))x\(Int(newSize.height))"
            userDefaults.setValue(newSize.width, forKey: Constants.kVideoConfigurationSizeWidth)
            userDefaults.setValue(newSize.height, forKey: Constants.kVideoConfigurationSizeHeight)
            return nil
        } catch {
            print("❌ Error updating resolution \(error)")
            return error
        }
    }

    func setUseCustomResolution(_ value: Bool) {
        useCustomResolution = value
        userDefaults.setValue(value, forKey: Constants.kVideoConfigurationUseCustomResolution)
    }

    func toggleUseAutoBitrate() {
        activeVideoConfiguration.useAutoBitrate.toggle()
        userDefaults.setValue(activeVideoConfiguration.useAutoBitrate, forKey: Constants.kVideoConfigurationAutoBitrate)
    }

    @discardableResult
    func setVideoBitrate(_ bitrate: Int) -> Error? {
        guard bitrate != activeVideoConfiguration.initialBitrate else {
            return nil
        }
        let bps = bitrate * 1000
        do {
            try activeVideoConfiguration.setInitialBitrate(bps)
            userDefaults.setValue(bps, forKey: Constants.kVideoConfigurationBitrate)
        } catch {
            print("❌ Error setting bitrate \(error)")
            return error
        }

        return nil
    }

    @discardableResult
    func setFramerate(to framerate: Int) -> Error? {
        return updateAndSave(newValue: framerate,
                      oldValue: activeVideoConfiguration.targetFramerate,
                      key: Constants.kVideoConfigurationFramerate) {
            try activeVideoConfiguration.setTargetFramerate(framerate)
        }
    }

    func setAudioBitrate(_ bitrate: Int) -> Error? {
        return updateAndSave(newValue: bitrate,
                      oldValue: activeAudioConfiguration.bitrate,
                      key: Constants.kAudioConfigurationBitrate) {
            try activeAudioConfiguration.setBitrate(bitrate)
        }
    }

    @discardableResult
    func setMinVideoBitrate(_ bitrate: Int) -> Error? {
        return updateAndSave(newValue: bitrate,
                      oldValue: activeVideoConfiguration.minBitrate,
                      key: Constants.kVideoConfigurationMinBitrate) {
            try activeVideoConfiguration.setMinBitrate(bitrate)
        }
    }

    @discardableResult
    func setMaxVideoBitrate(_ bitrate: Int) -> Error? {
        return updateAndSave(newValue: bitrate,
                      oldValue: activeVideoConfiguration.maxBitrate,
                      key: Constants.kVideoConfigurationMaxBitrate) {
            try activeVideoConfiguration.setMaxBitrate(bitrate)
        }
    }

    @discardableResult
    func setKeyframeInterval(_ interval: Float) -> Error? {
        return updateAndSave(newValue: interval,
                             oldValue: activeVideoConfiguration.keyframeInterval,
                             key: Constants.kVideoConfigurationKeyframeInterval) {
            try activeVideoConfiguration.setKeyframeInterval(interval)
        }
    }

    // Private functions

    private func onCustomOrientationChange() {
        updateAndSave(newValue: customOrientation.rawValue, oldValue: "", key: Constants.kVideoConfigurationOrientation) {}
        guard let custom = customResolution,
              let w = custom.split(separator: "x").first as NSString?,
              let h = custom.split(separator: "x").last as NSString? else { return }

        let size = Resolution.sizeFor(customOrientation, a: Int(w.intValue), b: Int(h.intValue))
        let error = updateResolution(for: size)
        if error == nil {
            customResolution = "\(Int(size.width))x\(Int(size.height))"
        }
    }

    @discardableResult
    private func updateAndSave<T: Equatable>(newValue: T, oldValue: T, key: String, updateAction: () throws -> Void) -> Error? {
        guard newValue != oldValue else { return nil }

        do {
            try updateAction()
            userDefaults.setValue(newValue, forKey: key)
        } catch {
            return error
        }

        return nil
    }
}
