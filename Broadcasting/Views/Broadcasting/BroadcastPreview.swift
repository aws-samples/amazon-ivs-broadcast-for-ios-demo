//
//  BroadcastPreviewView.swift
//  Broadcasting
//
//  Created by Uldis Zingis on 11/06/2021.
//

import SwiftUI
import AmazonIVSBroadcast

struct BroadcastPreview: UIViewRepresentable {
    let viewModel: BroadcastViewModel
    let previewView = UIView()

    func makeUIView(context: Context) -> UIView {
        previewView.frame = UIScreen.main.bounds
        previewView.backgroundColor = .black
        return previewView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        attachCameraPreview()
    }

    func attachCameraPreview() {
        let attachedCameras = viewModel.broadcastSession?.listAttachedDevices()
            .filter({ $0.descriptor().type == .camera })
            .compactMap({ $0 as? IVSImageDevice })

        do {
            if let preview = try attachedCameras?.first?.previewView(with: .fit) {
                attachCameraPreview(preview)
            }
        } catch {
            print("❌ Error getting preview view \(error)")
        }
    }

    func detachCameraPreview() {
        previewView.subviews.forEach { $0.removeFromSuperview() }
    }

    private func attachCameraPreview(_ cameraView: IVSImagePreviewView) {
        detachCameraPreview()
        cameraView.layer.cornerRadius = 10
        cameraView.frame = previewRectForCurrentConfiguration()
        previewView.addSubview(cameraView)
    }

    private func previewRectForCurrentConfiguration() -> CGRect {
        var width: CGFloat
        var height: CGFloat
        let configWidth = viewModel.configurations.activeVideoConfiguration.size.width
        let configHeight = viewModel.configurations.activeVideoConfiguration.size.height
        let isLandscape = UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight

        switch viewModel.configurations.customOrientation {
        case .auto:
            if isLandscape {
                width = UIScreen.main.bounds.width
                height = width * (configHeight / configWidth)
            } else {
                height = UIScreen.main.bounds.height
                width = height * (configWidth / configHeight)
            }
        case .portrait:
            height = isLandscape ? UIScreen.main.bounds.height : UIScreen.main.bounds.height
            width = height * (configWidth / configHeight)
        case .landscape:
            width = UIScreen.main.bounds.width
            height = width * (configHeight / configWidth)
        case .square:
            height = isLandscape ? UIScreen.main.bounds.height : UIScreen.main.bounds.width
            width = height
        }

        return CGRect(
            x: UIScreen.main.bounds.midX - width / 2.0,
            y: UIScreen.main.bounds.midY - height / 2.0,
            width: width,
            height: height
        )
    }
}
