//
//  BroadcastViewDelegate.swift
//  Broadcasting
//
//  Created by Uldis Zingis on 11/06/2021.
//

import AmazonIVSBroadcast

class BroadcastDelegateViewController: UIViewController, IVSBroadcastSession.Delegate {
    var viewModel: BroadcastViewModel?
    var sessionState: IVSBroadcastSession.State = .disconnected

    func broadcastSession(_ session: IVSBroadcastSession, didChange state: IVSBroadcastSession.State) {
        DispatchQueue.main.async { [weak self] in

            self?.viewModel?.sessionIsRunning = false

            switch state {
            case .invalid:
                print("ℹ️ IVSBroadcastSession state did change to invalid")
                self?.sessionState = .invalid
            case .connecting:
                print("ℹ️ IVSBroadcastSession state did change to connecting")
                self?.sessionState = .connecting
            case .connected:
                print("ℹ️ IVSBroadcastSession state did change to connected")
                self?.viewModel?.sessionIsRunning = true
                self?.viewModel?.isReconnecting = false
                self?.sessionState = .connected
            case .disconnected:
                print("ℹ️ IVSBroadcastSession state did change to disconnected")
                self?.sessionState = .disconnected
            case .error:
                print("ℹ️ IVSBroadcastSession state did change to error")
                self?.sessionState = .error
            @unknown default:
                print("ℹ️ IVSBroadcastSession state did change to unknown")
            }
        }
    }

    func broadcastSession(_ session: IVSBroadcastSession, didEmitError error: Error) {
        print("❌ IVSBroadcastSession did emit error \(error)")
        DispatchQueue.main.async { [weak self] in
            self?.viewModel?.errorMessage = error.localizedDescription
            if (error as NSError).code == 10405 {
                self?.viewModel?.reconnectOnceNetworkIsAvailable()
            } else if (error as NSError).code == 0 {
                self?.viewModel?.reconnect()
            }
        }
    }

    func broadcastSession(_ session: IVSBroadcastSession, didAddDevice descriptor: IVSDeviceDescriptor) {
        print("📲 IVSBroadcastSession did discover device \(descriptor)")
    }

    func broadcastSession(_ session: IVSBroadcastSession, didRemoveDevice descriptor: IVSDeviceDescriptor) {
        print("📱 IVSBroadcastSession did lose device \(descriptor)")
    }

    func broadcastSession(_ session: IVSBroadcastSession, audioStatsUpdatedWithPeak peak: Double, rms: Double) {
        // This fires frequently, so we don't log it here.
    }
}
