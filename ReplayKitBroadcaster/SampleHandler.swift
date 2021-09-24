//
//  SampleHandler.swift
//  ReplayKitBroadcaster
//
//  Created by Uldis Zingis on 06/07/2021.
//

import AmazonIVSBroadcast
import ReplayKit

class SampleHandler: RPBroadcastSampleHandler {
    private var ivsRPBroadcastSession: IVSReplayKitBroadcastSession?
    private var ingestServer: String = ""
    private var streamKey: String = ""
    private let userDefaults = UserDefaults(suiteName: Constants.appGroupName) ?? UserDefaults.standard

    override init() {
        super.init()

        ingestServer = userDefaults.string(forKey: Constants.kIngestServer) ?? ""
        streamKey = userDefaults.string(forKey: Constants.kStreamKey) ?? ""

        do {
            try ivsRPBroadcastSession = IVSReplayKitBroadcastSession(
                videoConfiguration: BroadcastConfiguration.shared.activeVideoConfiguration,
                audioConfig: BroadcastConfiguration.shared.activeAudioConfiguration,
                delegate: self
            )
        } catch {
            NSLog("❌ Error creating IVSReplayKitBroadcastSession: \(error.localizedDescription)")
        }
    }

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        startStream()
    }

    override func broadcastPaused() {
        stopStream()
    }

    override func broadcastResumed() {
        startStream()
    }

    override func broadcastFinished() {
        stopStream()
        ivsRPBroadcastSession = nil
    }

    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case .audioApp:
            ivsRPBroadcastSession?.systemAudioSource.onSampleBuffer(sampleBuffer)
        case .audioMic:
            ivsRPBroadcastSession?.microphoneSource.onSampleBuffer(sampleBuffer)
        case .video:
            if let imageSource = ivsRPBroadcastSession?.systemImageSource,
               let orientationAttachment =  CMGetAttachment(sampleBuffer,
                                                            key: RPVideoSampleOrientationKey as CFString,
                                                            attachmentModeOut: nil) as? NSNumber
            {
                switch orientationAttachment.uint32Value {
                case 6:
                    imageSource.setHandsetRotation(-(Float.pi / 2))
                case 8:
                    imageSource.setHandsetRotation((Float.pi / 2))
                case 1:
                    fallthrough
                default:
                    imageSource.setHandsetRotation(0)
                }
            }
            ivsRPBroadcastSession?.systemImageSource.onSampleBuffer(sampleBuffer)
        @unknown default:
            NSLog("❌ Unknown RPSampleBufferType: \(sampleBufferType)")
        }
    }

    private func stopStream() {
        ivsRPBroadcastSession?.stop()
        userDefaults.setValue(false, forKey: Constants.kReplayKitSessionHasBeenStarted)
    }

    private func startStream() {
        guard let url = URL(string: ingestServer) else {
            print("❌ Could not create url from ingest server: '\(ingestServer)'")
            return
        }

        do {
            try ivsRPBroadcastSession?.start(with: url, streamKey: streamKey)
        } catch {
            NSLog("❌ Error starting IVSReplayKitBroadcastSession: \(error.localizedDescription)")
        }
    }
}

extension SampleHandler: IVSBroadcastSession.Delegate {
    func broadcastSession(_ session: IVSBroadcastSession, didChange state: IVSBroadcastSession.State) {
        NSLog("ℹ️ IVSBroadcastSession state did change: \(state.rawValue)")

        switch state {
        case .connected:
            userDefaults.setValue(true, forKey: Constants.kReplayKitSessionHasBeenStarted)
        default:
            userDefaults.setValue(false, forKey: Constants.kReplayKitSessionHasBeenStarted)
        }
    }

    func broadcastSession(_ session: IVSBroadcastSession, didEmitError error: Error) {
        NSLog("❌ IVSBroadcastSession did emit error: \(error)")
        userDefaults.setValue(false, forKey: Constants.kReplayKitSessionHasBeenStarted)
    }
}
