//
//  ResolutionAndFramerate.swift
//  Broadcasting
//
//  Created by Uldis Zingis on 18/06/2021.
//

import SwiftUI

struct ResolutionAndFramerate: View {
    @ObservedObject private var viewModel: BroadcastViewModel
    private var dismissAction: () -> Void

    @State private var useCustomResolution: Bool = false
    @State private var useCustomFramerate: Bool = false
    @State private var customResolution: String
    @State private var customFramerate: String
    @State private var isOrientationPresent: Bool = false

    @State private var isErrorPresent: Bool = false
    @State private var errorMessage: String = "" {
        didSet { isErrorPresent = errorMessage != "" }
    }

    @State private var isFullHdOn: Bool = false
    @State private var isHdOn: Bool = false
    @State private var isSdOn: Bool = false

    @State private var is60On: Bool = false
    @State private var is30On: Bool = false
    @State private var is15On: Bool = false

    init(viewModel: BroadcastViewModel, dismissAction: @escaping () -> Void) {
        self.viewModel = viewModel
        self.dismissAction = dismissAction
        self.useCustomResolution = viewModel.configurations.useCustomResolution
        self.useCustomFramerate =  viewModel.configurations.customFramerate != nil
        self.customResolution = "\(Int(viewModel.configurations.activeVideoConfiguration.size.width))x\(Int(viewModel.configurations.activeVideoConfiguration.size.height))"
        self.customFramerate = String(viewModel.configurations.activeVideoConfiguration.targetFramerate)
        self.setCurrentResolution()
        self.setCurrentFramerate()
    }

    private func setCurrentResolution() {
        let currentSize = viewModel.configurations.activeVideoConfiguration.size
        self.customResolution = "\(Int(currentSize.width))x\(Int(currentSize.height))"

        self.isFullHdOn = currentSize.width == 1080 || currentSize.height == 1080
        self.isHdOn = isFullHdOn ? false : currentSize.width == 720 || currentSize.height == 720
        self.isSdOn = isFullHdOn || isHdOn ? false : currentSize.width == 480 || currentSize.height == 480
    }

    private func setCurrentFramerate() {
        self.is60On = viewModel.configurations.activeVideoConfiguration.targetFramerate == Framerate.max.rawValue
        self.is30On = viewModel.configurations.activeVideoConfiguration.targetFramerate == Framerate.mid.rawValue
        self.is15On = viewModel.configurations.activeVideoConfiguration.targetFramerate == Framerate.low.rawValue
        self.customFramerate = String(viewModel.configurations.activeVideoConfiguration.targetFramerate)
    }

    private func getBindingFor(_ resolution: Resolution) -> Binding<Bool> {
        switch resolution {
        case .fullHd:
            return $isFullHdOn
        case .hd:
            return $isHdOn
        case .sd:
            return $isSdOn
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack() {
                    VStack(spacing: 0) {
                        SettingsEntry(
                            title: "Use custom resolution",
                            isSwitch: true,
                            isOn: $useCustomResolution
                        ) {
                            withAnimation {
                                useCustomResolution.toggle()
                            }
                            errorMessage = ""
                            viewModel.configurations.setUseCustomResolution(useCustomResolution)
                            customResolution = "\(Int(viewModel.configurations.activeVideoConfiguration.size.width))x\(Int(viewModel.configurations.activeVideoConfiguration.size.height))"
                        }

                        if useCustomResolution {
                            TextInputField(
                                textBinding: $customResolution,
                                placeholder: "\(Int(viewModel.configurations.activeVideoConfiguration.size.width))x\(Int(viewModel.configurations.activeVideoConfiguration.size.height))",
                                onFocus: {
                                    errorMessage = ""
                                },
                                onClear: {
                                    errorMessage = ""
                                }
                            )
                            .onChange(of: customResolution) { newValue in
                                if newValue == "" {
                                    return
                                }

                                if let widthString = newValue.split(separator: "x").first?.trimmingCharacters(in: .whitespacesAndNewlines) as NSString?,
                                   let heightString = newValue.split(separator: "x").last?.trimmingCharacters(in: .whitespacesAndNewlines) as NSString? {
                                    let size = CGSize(width: CGFloat(widthString.floatValue), height: CGFloat(heightString.floatValue))
                                    errorMessage = viewModel.configurations.updateResolution(for: size)?.localizedDescription ?? ""
                                } else {
                                    errorMessage = "Invalid resolution format. Must be 'width x height' where width and height is a number"
                                }
                            }
                        } else {
                            ForEach(Resolution.allCases, id: \.self) { resolution in
                                SettingsEntry(
                                    title: "\(resolution.height)p",
                                    isSwitch: true,
                                    useCheckmark: true,
                                    isOn: getBindingFor(resolution)
                                ) {
                                    errorMessage = viewModel.configurations.setResolutionTo(to: resolution)?.localizedDescription ?? ""
                                    setCurrentResolution()
                                }
                            }
                        }
                    }
                    Text(
                        useCustomResolution ?
                            "Type a resolution in width x height pixel format. Width and height must both be between 160 and 1920, and the total pixel count (width x height) must be under 2,072,600." :
                            "The source resolution of your video stream. This cannot be changed during a stream."
                    )
                    .modifier(FooterText())

                    VStack(spacing: 0) {
                        SettingsEntry(
                            title: "Use custom framerate",
                            isSwitch: true,
                            isOn: $useCustomFramerate
                        ) {
                            withAnimation {
                                useCustomFramerate.toggle()
                            }
                            errorMessage = ""
                            customFramerate = String(viewModel.configurations.activeVideoConfiguration.targetFramerate)
                        }

                        if useCustomFramerate {
                            TextInputField(
                                textBinding: $customFramerate,
                                placeholder: String(viewModel.configurations.activeVideoConfiguration.targetFramerate),
                                onFocus: {
                                    errorMessage = ""
                                },
                                onClear: {
                                    errorMessage = ""
                                }
                            )
                            .onChange(of: customFramerate) { newFramerate in
                                if newFramerate == "" {
                                    return
                                }

                                if let new = Int(newFramerate) {
                                    errorMessage = viewModel.configurations.setFramerate(to: new)?.localizedDescription ?? ""
                                } else {
                                    errorMessage = "Invalid input. Framerate must be a number."
                                }
                            }
                        } else {
                            SettingsEntry(
                                title: "\(Framerate.max.rawValue)fps",
                                isSwitch: true,
                                useCheckmark: true,
                                isOn: $is60On
                            ) {
                                errorMessage = viewModel.configurations.setFramerate(to: Framerate.max.rawValue)?.localizedDescription ?? ""
                                setCurrentFramerate()
                            }
                            SettingsEntry(
                                title: "\(Framerate.mid.rawValue)fps",
                                isSwitch: true,
                                useCheckmark: true,
                                isOn: $is30On
                            ) {
                                errorMessage = viewModel.configurations.setFramerate(to: Framerate.mid.rawValue)?.localizedDescription ?? ""
                                setCurrentFramerate()
                            }
                            SettingsEntry(
                                title: "\(Framerate.low.rawValue)fps",
                                isSwitch: true,
                                useCheckmark: true,
                                isOn: $is15On
                            ) {
                                errorMessage = viewModel.configurations.setFramerate(to: Framerate.low.rawValue)?.localizedDescription ?? ""
                                setCurrentFramerate()
                            }
                        }
                    }
                    Text(
                        useCustomFramerate ?
                            "Type the number of frames per second (fps). Must be a whole number between 10 and 60." :
                            "The source framerate of your video stream. This cannot be changed during a stream."
                    )
                    .modifier(FooterText())

                    SettingsEntry(
                        title: "Orientation",
                        value: viewModel.configurations.customOrientation.rawValue.capitalized
                    ) {
                        withAnimation {
                            isOrientationPresent.toggle()
                        }
                    }
                    Text(useCustomResolution ?
                            "Orientation cannot be changed when using a custom resolution. Change the orientation by setting a different resolution." :
                            "Auto-orientation starts a stream in portrait or landscape mode depending on your device orientation. This setting cannot be changed during a stream."
                    )
                    .modifier(FooterText())
                }
                .padding(.vertical, 75)
            }
            .background(Constants.background)

            HeaderView(title: "Resolution and framerate", leftButtonAction: dismissAction)

            if isOrientationPresent {
                OrientationView(viewModel: viewModel) {
                    setCurrentResolution()
                    withAnimation {
                        isOrientationPresent.toggle()
                    }
                }
                .transition(.move(edge: .trailing))
            }
        }
        .onAppear {
            setCurrentResolution()
            setCurrentFramerate()
        }
        .onDisappear {
            viewModel.initializeBroadcastSession()
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
