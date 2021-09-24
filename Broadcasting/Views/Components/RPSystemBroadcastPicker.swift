//
//  BroadcastPickerView.swift
//  Broadcasting
//
//  Created by Uldis Zingis on 06/07/2021.
//

import SwiftUI
import ReplayKit

struct RPSystemBroadcastPicker: UIViewRepresentable {
    var broadcastPickerView = RPSystemBroadcastPickerView()

    init() {
        broadcastPickerView.preferredExtension = "\(Bundle.main.bundleIdentifier!).ReplayKitBroadcaster"
    }

    func makeUIView(context: Context) -> UIView {
        broadcastPickerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        return broadcastPickerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    func toggleView() {
        for subview in broadcastPickerView.subviews {
            if let button = subview as? UIButton {
                button.sendActions(for: UIControl.Event.touchUpInside)
            }
        }
    }
}
