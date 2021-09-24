//
//  BroadcastPreviewView.swift
//  Broadcasting
//
//  Created by Uldis Zingis on 10/06/2021.
//

import SwiftUI
import AmazonIVSBroadcast

struct BroadcastView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @ObservedObject private var viewModel: BroadcastViewModel
    @StateObject private var timeManager = ElapsedTimeAndDataManager()
    @State var isDebugInfoPresent: Bool = false
    @State var isControlButtonsPresent: Bool = true

    init(viewModel: BroadcastViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)

            viewModel.previewView
                .edgesIgnoringSafeArea(.all)
                .blur(radius: viewModel.cameraIsOn ? 0 : 24)
                .onTapGesture {
                    withAnimation() {
                        isControlButtonsPresent.toggle()
                    }
                }
                .onChange(of: viewModel.configurations.activeVideoConfiguration) { _ in
                    viewModel.deviceOrientationChanged(toLandscape: verticalSizeClass == .compact)
                }
                .onChange(of: verticalSizeClass) { vSizeClass in
                    viewModel.deviceOrientationChanged(toLandscape: vSizeClass == .compact)
                }

            if !viewModel.cameraIsOn {
                ZStack {
                    Color.black
                        .edgesIgnoringSafeArea(.all)
                        .opacity(0.5)

                    VStack(spacing: 10) {
                        Image(systemName: "video.slash.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 38))
                        Text("Camera Off")
                            .foregroundColor(.white)
                            .font(Constants.fAppBoldExtraLarge)
                    }
                }
            }

            if viewModel.isScreenSharingActive {
                ZStack {
                    Color.black
                        .edgesIgnoringSafeArea(.all)

                    VStack {
                        InformationBlock(
                            icon: "iphone.badge.play",
                            iconSize: 50,
                            iconColor: Constants.yellow,
                            withIconFrame: false,
                            title: "Screen sharing active",
                            description: "The camera is disabled while you are sharing your screen. Stop sharing to enable it again.",
                            height: 50
                        )
                        SimpleButton(title: "Stop sharing", height: 40, maxWidth: 200) {
                            viewModel.broadcastPicker.toggleView()
                        }
                        .padding(.top, 15)
                    }
                    .padding()
                }
            }

            if verticalSizeClass == .compact {
                // Landscape
                HStack {
                    StatusBar(viewModel: viewModel, timeManager: timeManager)
                        .edgesIgnoringSafeArea(.all)
                    Spacer()
                    if isControlButtonsPresent {
                        ControlButtonsSlider(viewModel: viewModel,
                                             isControlButtonsPresent: $isControlButtonsPresent,
                                             isDebugInfoPresent: $isDebugInfoPresent)
                            .frame(minHeight: 100)
                            .transition(.move(edge: .trailing))
                    }
                }
                .sheet(isPresented: $viewModel.settingsOpen, content: {
                    SettingsView(viewModel: viewModel)
                })

            } else {
                // Portrait
                VStack {
                    StatusBar(viewModel: viewModel, timeManager: timeManager)
                    Spacer()
                    if isControlButtonsPresent {
                        ControlButtonsSlider(viewModel: viewModel,
                                             isControlButtonsPresent: $isControlButtonsPresent,
                                             isDebugInfoPresent: $isDebugInfoPresent)
                            .frame(minHeight: 100)
                            .transition(.move(edge: .bottom))
                    }
                }
                .sheet(isPresented: $viewModel.settingsOpen, content: {
                    SettingsView(viewModel: viewModel)
                })
                .edgesIgnoringSafeArea(.top)

            }

            if viewModel.developerMode && isDebugInfoPresent {
                DebugInfo(viewModel: viewModel, isPresent: $isDebugInfoPresent)
                    .padding(.top, verticalSizeClass == .compact ? 0 : 90)
                    .padding(.bottom, verticalSizeClass == .compact ? 0 : 190)
                    .frame(maxWidth: verticalSizeClass == .compact ? 200 : .infinity,
                           maxHeight: verticalSizeClass == .compact ? 100 : .infinity)
            }

            if viewModel.isReconnectViewVisible {
                ZStack {
                    Color.black
                        .edgesIgnoringSafeArea(.all)
                        .opacity(0.7)

                    VStack(spacing: 10) {
                        Text("Reconnecting...")
                            .foregroundColor(.white)
                            .font(Constants.fAppBoldExtraLarge)
                        Text("The connection to the server was lost. The app will automatically try to reconnect.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .font(Constants.fAppRegular)

                        SimpleButton(title: "Don't reconnect", height: 37, font: Constants.fAppBold, backgroundColor: Constants.red) {
                            viewModel.cancelAutoReconnect()
                        }
                        .frame(width: 155)
                        .padding(.top, 40)

                        SimpleButton(title: "Hide this notice", height: 37) {
                            viewModel.isReconnectViewVisible = false
                        }
                        .frame(width: 155)
                        .padding(.top, 8)
                    }
                }
            }
        }
        .onAppear {
            viewModel.observeUserDefaultChanges()
            viewModel.initializeBroadcastSession()
        }
        .onReceive(NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)) { notification in
            viewModel.audioSessionInterrupted(notification)
        }
        .onChange(of: viewModel.sessionIsRunning, perform: { _ in
            if viewModel.sessionIsRunning {
                timeManager.start()
            } else {
                timeManager.stop()
            }
        })
    }
}
