//
//  StartView.swift
//  Broadcasting
//
//  Created by Uldis Zingis on 15/06/2021.
//

import SwiftUI

struct StartScreen: View {
    @ObservedObject var viewModel: BroadcastViewModel
    @Environment(\.openURL) var openURL
    @Binding var isPresented: Bool
    @State var isPermissionsPresent: Bool = false
    @State var isAutoConfigurationPresent: Bool = false

    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                InformationBlock(
                    icon: "video.fill",
                    title: "Amazon IVS Broadcast Demo",
                    description: "This demo application broadcasts your iPhone’s camera or screen to an Amazon IVS Channel.",
                    height: 152
                )
                Spacer()

                Group {
                    PrimaryButton(title: "Get Started") {
                        isPermissionsPresent.toggle()
                    }
                    SecondaryButton(title: "View source code") {
                        openURL(URL(string: "https://github.com/aws-samples/Broadcasting-SwiftUI")!)
                    }
                    .padding(.top, 5)
                    .padding(.bottom, 30)
                }
            }
            .padding()

            if isPermissionsPresent {
                Permissions() {
                    viewModel.configurations.userDefaults.set(true, forKey: Constants.kWasLaunchedBefore)
                    isPermissionsPresent = false
                    isAutoConfigurationPresent = true
                }
            }

            if isAutoConfigurationPresent {
                AutoConfiguration(viewModel: viewModel, dismissAction: {
                    isAutoConfigurationPresent = false
                    isPresented = false
                }, firstTimeLaunched: true)
            }
        }
    }
}
