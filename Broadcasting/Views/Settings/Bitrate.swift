//
//  Bitrate.swift
//  Broadcasting
//
//  Created by Uldis Zingis on 18/06/2021.
//

import SwiftUI

struct Bitrate: View {
    @ObservedObject var viewModel: BroadcastViewModel
    var dismissAction: () -> Void

    @State private var manualBitrateLimits: Bool
    @State private var autoAdjustBitrate: Bool
    @State private var targetBitrate: String
    @State private var minBitrate: String
    @State private var maxBitrate: String
    @State private var dataUse: String

    @State private var isErrorPresent: Bool = false
    @State private var errorMessage: String = "" {
        didSet { isErrorPresent = errorMessage != "" }
    }

    init(viewModel: BroadcastViewModel, dismissAction: @escaping () -> Void) {
        self.viewModel = viewModel
        self.dismissAction = dismissAction
        self.manualBitrateLimits = viewModel.configurations.userDefaults.bool(forKey: Constants.kManualBitrateLimits)
        self.autoAdjustBitrate = viewModel.configurations.activeVideoConfiguration.useAutoBitrate
        self.targetBitrate = String(viewModel.configurations.activeVideoConfiguration.initialBitrate / 1000)
        self.minBitrate = String(viewModel.configurations.activeVideoConfiguration.minBitrate)
        self.maxBitrate = String(viewModel.configurations.activeVideoConfiguration.maxBitrate)
        self.dataUse = String(format: "%.1fGB/hr", viewModel.dataUsePerHour)
    }

    private func getDataUse() {
        dataUse = String(format: "%.1fGB/hr", viewModel.dataUsePerHour)
    }

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack() {
                    SettingsEntry(
                        title: "Estimated data use",
                        value: dataUse,
                        isInfoCell: true
                    )
                    Text("Actual data usage may be higher or lower, depending on network conditions during the livestream.")
                        .modifier(FooterText())

                    SettingsEntry(
                        title: "Auto-adjust bitrate",
                        isSwitch: true,
                        isOn: $autoAdjustBitrate) {
                        autoAdjustBitrate.toggle()
                        viewModel.configurations.toggleUseAutoBitrate()
                    }
                    Text("Automatically adjust the bitrate during a video stream. Turn on manually set bitrate limits to set the min and max bitrate.")
                        .modifier(FooterText())

                    Text("TARGET BITRATE")
                        .foregroundColor(Constants.lightGray)
                        .font(Constants.fAppMediumSmall)
                        .padding(.horizontal, 16)
                    TextInputField(
                        textBinding: $targetBitrate,
                        placeholder: String(viewModel.configurations.activeVideoConfiguration.initialBitrate / 1000)
                    )
                    .onChange(of: self.targetBitrate) { newBitrate in
                        if let bitrate = Int(targetBitrate) {
                            errorMessage = viewModel.configurations.setVideoBitrate(bitrate)?.localizedDescription ?? ""
                        } else {
                            errorMessage = "Invalid input. Target bitrate must be a number."
                        }
                        getDataUse()
                    }

                    Text("The target bitrate (or initial bitrate) of the stream in Kbps. Must be a number between 1 and 8500.")
                        .modifier(FooterText())

                    SettingsEntry(
                        title: "Manually set bitrate limits",
                        isSwitch: true,
                        isOn: $manualBitrateLimits) {
                        manualBitrateLimits.toggle()
                        viewModel.configurations.userDefaults.setValue(manualBitrateLimits, forKey: Constants.kManualBitrateLimits)
                    }
                    .padding(.bottom, 20)

                    if manualBitrateLimits {
                        Text("MINIMUM BITRATE")
                            .foregroundColor(Constants.lightGray)
                            .font(Constants.fAppMediumSmall)
                            .padding(.horizontal, 16)
                        TextInputField(
                            textBinding: $minBitrate,
                            placeholder: String(viewModel.configurations.activeVideoConfiguration.minBitrate)
                        )
                        .padding(.bottom, 20)
                        .onChange(of: self.minBitrate) { newBitrate in
                            if let bitrate = Int(minBitrate) {
                                errorMessage = viewModel.configurations.setMinVideoBitrate(bitrate)?.localizedDescription ?? ""
                            } else {
                                errorMessage = "Invalid input. Minimum bitrate must be a number."
                            }
                        }

                        Text("MAXIMUM BITRATE")
                            .foregroundColor(Constants.lightGray)
                            .font(Constants.fAppMediumSmall)
                            .padding(.horizontal, 16)
                        TextInputField(
                            textBinding: $maxBitrate,
                            placeholder: String(viewModel.configurations.activeVideoConfiguration.maxBitrate)
                        )
                        .padding(.bottom, 50)
                        .onChange(of: self.maxBitrate) { newBitrate in
                            if let bitrate = Int(maxBitrate) {
                                errorMessage = viewModel.configurations.setMaxVideoBitrate(bitrate)?.localizedDescription ?? ""
                            } else {
                                errorMessage = "Invalid input./n Maximum bitrate must be a number."
                            }
                        }

                        Spacer()
                    } else {
                        Spacer()
                    }
                }
                .padding(.vertical, 75)
            }
            .background(Constants.background)

            HeaderView(title: "Bitrate", leftButtonAction: dismissAction)
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .modifier(DismissOnSwipe(dismissAction: dismissAction))
        .notification(isPresent: $isErrorPresent,
                      title: "ERROR",
                      message: errorMessage,
                      height: 77,
                      type: .error)
    }
}
