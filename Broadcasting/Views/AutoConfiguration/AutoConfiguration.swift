//
//  AutoConfiguration.swift
//  Broadcasting
//
//  Created by Uldis Zingis on 15/06/2021.
//

import SwiftUI
import Combine

struct AutoConfiguration: View {
    @ObservedObject private var viewModel: BroadcastViewModel
    var dismissAction: () -> Void
    var firstTimeLaunched: Bool

    @State private var isConfigurationInProgress: Bool = false
    @State private var isConfigurationFinished: Bool = false
    @State private var configurationProgress: Float = 0.0
    @State var isServerTextInputPresent: Bool = false
    @State var isKeyTextInputPresent: Bool = false
    @State private var isWarningPresent: Bool = false
    @State private var warningTimeout: Int = 12
    @State private var isErrorPresent: Bool = false
    @State private var errorMessage: String = "Could not complete network test. Check your internet connection and try again."

    @State private var timer: Timer?

    init(viewModel: BroadcastViewModel, dismissAction: @escaping () -> Void, firstTimeLaunched: Bool = false) {
        self.viewModel = viewModel
        self.dismissAction = dismissAction
        self.firstTimeLaunched = firstTimeLaunched
    }

    private func startTestTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ timer in
            warningTimeout -= 1
            if warningTimeout == 0 {
                isWarningPresent = true
                stopTestTimer()
            }
        }
    }

    private func stopTestTimer() {
        timer?.invalidate()
        timer = nil
        warningTimeout = 10
    }

    private func autoConfigurationAction() {
        isConfigurationInProgress = true

        viewModel.runAutoConfig(progressUpdate: { progress in
            configurationProgress = progress
        }) { error in
            if let error = error {
                print("Error received when running auto-configration: \(error.localizedDescription)")
            }
            isConfigurationFinished = error == nil
            errorMessage = error?.localizedDescription ?? ""
            isErrorPresent = !errorMessage.isEmpty
            isConfigurationInProgress = false
            isWarningPresent = false
        }
    }

    var body: some View {
        return ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()

                if isConfigurationInProgress {
                    Text("Testing network...")
                        .foregroundColor(.white)
                        .font(Constants.fAppRegular)
                    ProgressBar(value: $configurationProgress)
                } else if isConfigurationFinished {
                    ConfigurationSummary(viewModel: viewModel)
                        .padding()
                } else {
                    ConfigurationSetup(viewModel: viewModel,
                                       isServerTextInputPresent: $isServerTextInputPresent,
                                       isKeyTextInputPresent: $isKeyTextInputPresent) {
                        isWarningPresent = false
                        errorMessage = ""
                        autoConfigurationAction()
                    }
                }

                Spacer()
                Group {
                    if isConfigurationInProgress {
                        SecondaryButton(title: "Cancel auto-configuration") {
                            dismissAction()
                        }
                        .padding(.bottom, 30)
                        .onAppear {
                            startTestTimer()
                        }
                        .onDisappear {
                            stopTestTimer()
                        }

                    } else if isConfigurationFinished {
                        PrimaryButton(title: "Continue to App") {
                            dismissAction()
                        }
                        SecondaryButton(title: "Rerun auto-configuration") {
                            autoConfigurationAction()
                        }
                        .padding(.bottom, 30)
                    } else {
                        SecondaryButton(title: isConfigurationFinished ?
                                            "Rerun auto-configuration" :
                                            firstTimeLaunched ? "Skip this step" : "Return to settings") {
                            isConfigurationFinished ? autoConfigurationAction() : dismissAction()
                        }
                        .padding(.bottom, 30)
                    }
                }
                .frame(width: UIScreen.main.bounds.width)
                .padding(.top, 5)
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
        }
        .frame(maxWidth: UIScreen.main.bounds.width)
        .notification(isPresent: $isErrorPresent,
                      title: "ERROR",
                      message: errorMessage,
                      height: 100,
                      type: .error)
        .notification(isPresent: $isWarningPresent,
                      title: "NETWORK ISSUE",
                      message: "The test is taking longer than usual.",
                      height: 55,
                      type: .warning)
        .padding(.horizontal, 16)
    }
}
