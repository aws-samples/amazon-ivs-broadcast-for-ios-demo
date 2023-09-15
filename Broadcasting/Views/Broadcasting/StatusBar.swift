//
//  StatusBar.swift
//  Broadcasting
//
//  Created by Uldis Zingis on 11/06/2021.
//

import SwiftUI

struct StatusBar: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @ObservedObject private var viewModel: BroadcastViewModel
    @ObservedObject private var manager: ElapsedTimeAndDataManager

    init(viewModel: BroadcastViewModel, timeManager: ElapsedTimeAndDataManager) {
        self.viewModel = viewModel
        self.manager = timeManager
    }

    @ViewBuilder private func sessionStateLabel() -> some View {
        let connectedLabel = Text(manager.timeElapsed)
            .foregroundColor(.white)
            .font(Constants.fStatusBarLabels)
            .frame(height: 23)
            .background(Constants.red)
            .cornerRadius(56)

        if viewModel.isScreenSharingActive {
            connectedLabel
        } else {
            switch viewModel.broadcastDelegate.sessionState {
            case .connecting:
                Text(viewModel.isReconnecting ? "Reconnecting" : "Connecting")
                    .padding(.horizontal, 8)
                    .foregroundColor(.black)
                    .background(Constants.lightGray)
                    .font(Constants.fStatusBarLabels)
                    .cornerRadius(56)
            case .connected:
                connectedLabel
            case .disconnected, .error, .invalid:
                Text("Offline")
                    .padding(.horizontal, 8)
                    .foregroundColor(.gray)
                    .background(Color.black)
                    .font(Constants.fStatusBarLabels)
                    .cornerRadius(56)
            @unknown default:
                EmptyView()
            }
        }
    }

    private func toggleManager() {
        if viewModel.isScreenSharingActive {
            manager.start()
        } else {
            manager.stop()
        }
    }

    var body: some View {
        if verticalSizeClass == .compact {
            // Landscape
            HStack(alignment: .top) {
                VStack {
                    Text(viewModel.sessionIsRunning || viewModel.isScreenSharingActive ? manager.dataUsed : viewModel.activeQuality)
                        .foregroundColor(.white)
                        .font(Constants.fStatusBarLabels)
                        .multilineTextAlignment(.leading)
                        .frame(width: 70, alignment: .leading)
                        .padding()

                    Spacer()

                    Button {
                        viewModel.settingsOpen.toggle()
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .padding()
                    }
                    .accentColor(.yellow)
                    .padding(.vertical)
                    .frame(width: 50)
                }
                .background(Color.black)

                sessionStateLabel()
                    .padding(.top)
            }
            .onChange(of: viewModel.isScreenSharingActive) { _ in
                toggleManager()
            }

        } else {
            // Portrait
            HStack {
                Text(viewModel.sessionIsRunning || viewModel.isScreenSharingActive ? manager.dataUsed : viewModel.activeQuality)
                    .foregroundColor(.white)
                    .font(Constants.fStatusBarLabels)
                    .multilineTextAlignment(.leading)
                    .frame(width: 70, alignment: .leading)

                Spacer()
                sessionStateLabel()
                Spacer()
                Button("Settings") {
                    viewModel.settingsOpen.toggle()
                }
                .accentColor(.yellow)
                .font(Constants.fStatusBarLabels)
            }
            .padding(16)
            .padding(.top, 30)
            .background(Color.black)
            .onChange(of: viewModel.isScreenSharingActive) { _ in
                toggleManager()
            }
        }
    }
}
