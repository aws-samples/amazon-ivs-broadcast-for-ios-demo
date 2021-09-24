//
//  SettingsView.swift
//  Broadcasting
//
//  Created by Uldis Zingis on 14/06/2021.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.openURL) var openURL
    @ObservedObject private var viewModel: BroadcastViewModel

    @State private var isAutoConfigurationPresent: Bool = false
    @State private var isServerTextInputPresent: Bool = false
    @State private var isKeyTextInputPresent: Bool = false
    @State private var isPlaybackUrlTextInputPresent: Bool = false
    @State private var isResolutionAndFrameratePresent: Bool = false
    @State private var isBitratePresent: Bool = false
    @State private var isDefaultCameraSelectionPresent: Bool = false

    init(viewModel: BroadcastViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack(alignment: .top) {
            Constants.background
                .edgesIgnoringSafeArea(.all)

            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    SettingsEntry(title: "Run auto-config",
                                  isDisabled: viewModel.sessionIsRunning) {
                        withAnimation {
                            isAutoConfigurationPresent = true
                        }
                    }
                    Text("Automatically configure resolution, framerate, and bitrate based on current network conditions.")
                        .modifier(FooterText())

                    SettingsEntry(title: "Default camera",
                                  value: viewModel.availableCameraDevices
                                    .first(where: {$0.urn == viewModel.defaultCameraUrn})?.friendlyName ?? "") {
                        withAnimation {
                            isDefaultCameraSelectionPresent.toggle()
                        }
                    }
                    .padding(.bottom, 25)

                    VStack(spacing: 0) {
                        SettingsEntry(title: "Resolution and framerate",
                                      value: viewModel.activeQuality,
                                      isDisabled: viewModel.sessionIsRunning) {
                            withAnimation {
                                isResolutionAndFrameratePresent.toggle()
                            }
                        }
                        SettingsEntry(title: "Orientation",
                                      value: viewModel.configurations.customOrientation.rawValue.capitalized,
                                      isDisabled: viewModel.sessionIsRunning) {
                            withAnimation {
                                isResolutionAndFrameratePresent.toggle()
                            }
                        }
                        SettingsEntry(title: "Bitrate",
                                      value: "\(viewModel.configurations.activeVideoConfiguration.useAutoBitrate ? "Auto - " : "")\(viewModel.formattedInitialBitrate)") {
                            withAnimation {
                                isBitratePresent.toggle()
                            }
                        }
                    }
                    Text("Bitrate, resolution, and framerate impact the quality of your video stream. Note that higher resolutions and framerates will require higher bitrates to avoid compression artifacts. The app will automatically adjust your bitrate based on network conditions.")
                        .modifier(FooterText())

                    VStack(spacing: 0) {
                        SettingsEntry(title: "Ingest server",
                                      value: viewModel.ingestServer.isEmpty ? "Not set" : viewModel.ingestServer,
                                      isDisabled: viewModel.sessionIsRunning) {
                            withAnimation {
                                isServerTextInputPresent.toggle()
                            }
                        }
                        SettingsEntry(title: "Stream key",
                                      value: viewModel.streamKey.isEmpty ? "Not set" : "••••••••••••",
                                      isDisabled: viewModel.sessionIsRunning) {
                            withAnimation {
                                isKeyTextInputPresent.toggle()
                            }
                        }
                        SettingsEntry(title: "Playback URL",
                                      value: viewModel.playbackUrl.isEmpty ? "Not set" : viewModel.playbackUrl) {
                            withAnimation {
                                isPlaybackUrlTextInputPresent.toggle()
                            }
                        }
                    }

                    TextWithHyperlink(
                        leadingText: "Create an Amazon IVS channel to get an ingest server and stream key. These values must be set before you can start streaming.",
                        urlLabel: " Create an Amazon IVS Channel.",
                        url: "https://aws.amazon.com/ivs"
                    )
                    .modifier(FooterText())
                    .frame(height: 80)
                    .frame(maxWidth: UIScreen.main.bounds.width)
                    .onTapGesture {
                        openURL(URL(string: "https://aws.amazon.com/ivs")!)
                    }

                    SettingsEntry(title: "Developer mode", isSwitch: true, isOn: $viewModel.developerMode) {
                        withAnimation {
                            viewModel.developerMode.toggle()
                        }
                    }
                    Text("Enable developer mode to show video and network stats for debugging.")
                        .modifier(FooterText())

                    Spacer()
                }
                .padding(.vertical, 75)
            }

            HeaderView(title: "Settings", leftButtonAction: {
                withAnimation {
                    presentationMode.wrappedValue.dismiss()
                }
            }, leftButtonTitle: "Close", leftButtonIcon: "", rightButtonAction: {
                withAnimation {
                    presentationMode.wrappedValue.dismiss()
                }
            }, rightButtonTitle: "Done")

            if isAutoConfigurationPresent {
                AutoConfiguration(viewModel: viewModel) {
                    isAutoConfigurationPresent.toggle()
                }
            }

            if isServerTextInputPresent {
                TextInputView(
                    title: "Ingest Server",
                    placeholder: "rtmps://",
                    viewModel: viewModel,
                    textBinding: $viewModel.ingestServer) {
                    isServerTextInputPresent.toggle()
                }
                .transition(.move(edge: .trailing))
            }

            if isKeyTextInputPresent {
                TextInputView(
                    title: "Stream Key",
                    placeholder: "Stream key",
                    description: "Keep your stream key secret. Anyone who has it can stream to your Amazon IVS channel.",
                    viewModel: viewModel,
                    textBinding: $viewModel.streamKey) {
                    isKeyTextInputPresent.toggle()
                }
                .transition(.move(edge: .trailing))
            }

            if isPlaybackUrlTextInputPresent {
                TextInputView(
                    title: "Playback URL",
                    placeholder: "https://",
                    description: "",
                    viewModel: viewModel,
                    textBinding: $viewModel.playbackUrl) {
                    isPlaybackUrlTextInputPresent.toggle()
                }
                .transition(.move(edge: .trailing))
            }

            if isResolutionAndFrameratePresent {
                ResolutionAndFramerate(viewModel: viewModel) {
                    isResolutionAndFrameratePresent.toggle()
                }
                .edgesIgnoringSafeArea(.vertical)
                .transition(.move(edge: .trailing))
            }

            if isBitratePresent {
                Bitrate(viewModel: viewModel) {
                    isBitratePresent.toggle()
                }
                .edgesIgnoringSafeArea(.vertical)
                .transition(.move(edge: .trailing))
            }

            if isDefaultCameraSelectionPresent {
                CameraSelection(viewModel: viewModel) {
                    isDefaultCameraSelectionPresent.toggle()
                }
                .edgesIgnoringSafeArea(.vertical)
                .transition(.move(edge: .trailing))
            }
        }
    }
}
