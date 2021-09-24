//
//  Orientation.swift
//  Broadcasting
//
//  Created by Uldis Zingis on 01/07/2021.
//

import SwiftUI

struct OrientationView: View {
    @ObservedObject var viewModel: BroadcastViewModel
    var dismissAction: () -> Void

    @State private var isAutoOn: Bool = false
    @State private var isPortraitOn: Bool = false
    @State private var isLandscapeOn: Bool = false
    @State private var isSquareOn: Bool = false

    private func updateViewStateValues() {
        isAutoOn = viewModel.configurations.customOrientation == .auto
        isPortraitOn = viewModel.configurations.customOrientation == .portrait
        isLandscapeOn = viewModel.configurations.customOrientation == .landscape
        isSquareOn = viewModel.configurations.customOrientation == .square
    }

    private func getBindingFor(_ orientation: Orientation) -> Binding<Bool> {
        switch orientation {
        case .auto:
            return $isAutoOn
        case .portrait:
            return $isPortraitOn
        case .landscape:
            return $isLandscapeOn
        case .square:
            return $isSquareOn
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            Constants.background
                .edgesIgnoringSafeArea(.all)

            VStack() {
                VStack(spacing: 0) {
                    ForEach(Orientation.allCases, id: \.self) { orientation in
                        SettingsEntry(
                            title: orientation.rawValue.capitalized,
                            isSwitch: true,
                            useCheckmark: true,
                            isOn: getBindingFor(orientation)
                        ) {
                            viewModel.configurations.customOrientation = orientation
                            updateViewStateValues()
                        }
                    }
                }

                Text("Auto-orientation starts a stream in portrait or landscape mode depending on your device orientation.")
                    .modifier(FooterText())

                Spacer()
            }
            .padding(.vertical, 75)

            HeaderView(title: "Orientation", leftButtonAction: dismissAction)
        }
        .modifier(DismissOnSwipe(dismissAction: dismissAction))
        .onAppear {
            updateViewStateValues()
        }
    }
}
