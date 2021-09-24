//
//  ConfigurationSetup.swift
//  Broadcasting
//
//  Created by Uldis Zingis on 17/06/2021.
//

import SwiftUI

struct ConfigurationSetup: View {
    @Environment(\.openURL) var openURL
    @ObservedObject var viewModel: BroadcastViewModel
    @Binding var isServerTextInputPresent: Bool
    @Binding var isKeyTextInputPresent: Bool
    var autoConfigurationAction: () -> Void

    var body: some View {
        VStack {
            Spacer()

            Text("Auto-configuration")
                .font(Constants.fAppBoldExtraLarge)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 10)
                .padding(.horizontal, 16)

            ZStack {
                Rectangle()
                    .overlay(
                        RoundedRectangle(cornerRadius: 13)
                            .fill(Constants.backgroundGrayLight)
                            .background(Color.black)
                    )
                    .frame(height: 330)

                VStack(spacing: 0) {
                    Text("Auto-configuration chooses the best video settings for your current internet connection. You can always run this test again from the app settings.")
                        .font(Constants.fAppRegular)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.bottom, 16)

                    SettingsEntry(title: "Ingest server",
                                  value: viewModel.ingestServer.isEmpty ? "Not set" : viewModel.ingestServer,
                                  background: Constants.backgroundGrayLight) {
                        isServerTextInputPresent.toggle()
                    }
                    SettingsEntry(title: "Stream key",
                                  value: viewModel.streamKey.isEmpty ? "Not set" : "••••••••••••",
                                  background: Constants.backgroundGrayLight) {
                        isKeyTextInputPresent.toggle()
                    }

                    TextWithHyperlink(
                        leadingText: "Create an Amazon IVS channel to get an ingest server and stream key.",
                        urlLabel: " Create an Amazon IVS Channel.",
                        url: "https://docs.aws.amazon.com/ivs/latest/userguide/getting-started-create-channel.html"
                    )
                    .modifier(FooterText())
                    .frame(height: 70)
                    .padding(.top, 8)
                    .onTapGesture {
                        openURL(URL(string: "https://docs.aws.amazon.com/ivs/latest/userguide/getting-started-create-channel.html")!)
                    }

                    if !(viewModel.ingestServer.isEmpty && viewModel.streamKey.isEmpty) {
                        PrimaryButton(title: "Run auto-configuration") {
                            autoConfigurationAction()
                        }
                        .padding(.horizontal, 16)
                    } else {
                        DisabledPrimaryButton(title: "Run auto-configuration", background: Constants.backgroundGrayLight)
                            .padding(.horizontal, 16)
                    }
                }
                .padding(.top, 5)
            }
            .frame(maxWidth: UIScreen.main.bounds.width)

            Spacer()
        }
    }
}
