//
//  CameraSelection.swift
//  Broadcasting
//
//  Created by Uldis Zingis on 28/07/2021.
//  

import SwiftUI

struct CameraSelection: View {
    @ObservedObject var viewModel: BroadcastViewModel
    var dismissAction: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            Constants.background
                .edgesIgnoringSafeArea(.all)

            VStack() {
                VStack(spacing: 0) {
                    ForEach(viewModel.availableCameraDevices, id: \.urn) { device in
                        SettingsEntry(
                            title: device.friendlyName,
                            isSwitch: true,
                            useCheckmark: true,
                            isOn: .constant(viewModel.defaultCameraUrn == device.urn)
                        ) {
                            viewModel.defaultCameraUrn = device.urn
                        }
                    }
                }

                Text("Auto-orientation starts a stream in portrait or landscape mode depending on your device orientation.")
                    .modifier(FooterText())

                Spacer()
            }
            .padding(.vertical, 75)

            HeaderView(title: "Default camera", leftButtonAction: dismissAction)
        }
        .modifier(DismissOnSwipe(dismissAction: dismissAction))
    }
}
