//
//  ControlButtons.swift
//  Broadcasting
//
//  Created by Uldis Zingis on 11/06/2021.
//

import SwiftUI
import AmazonIVSBroadcast

struct ControlButtonsSlider: View {

    enum CardPosition: CGFloat {
        case expanded
        case collapsed
        case hidden
    }

    enum DragState {
        case inactive
        case dragging(translation: CGSize)

        var translation: CGSize {
            switch self {
            case .inactive:
                return .zero
            case .dragging(let translation):
                return translation
            }
        }

        var isDragging: Bool {
            switch self {
            case .inactive:
                return false
            case .dragging:
                return true
            }
        }
    }

    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?

    @ObservedObject private var viewModel: BroadcastViewModel
    @GestureState private var dragState = DragState.inactive
    @State var position = CardPosition.collapsed
    @Binding var isControlButtonsPresent: Bool
    @Binding var isDebugInfoPresent: Bool

    @State private var isSuccessPresent: Bool = false
    @State private var successMessage: String = "" {
        didSet { isSuccessPresent = successMessage != "" }
    }
    @State private var isErrorPresent: Bool = false
    @State private var errorMessage: String = "" {
        didSet { isErrorPresent = errorMessage != "" }
    }
    @State private var isScreenShareAlertPresent: Bool = false
    @State private var isBroadcastPickerViewPresent: Bool = false

    let cardHeight: CGFloat = UIScreen.main.bounds.height * 0.85
    private let narrowScreenRatio = UIScreen.main.bounds.height / UIScreen.main.bounds.width
    private var shareSheet: UIActivityViewController?

    init(viewModel: BroadcastViewModel, isControlButtonsPresent: Binding<Bool>, isDebugInfoPresent: Binding<Bool>) {
        self.viewModel = viewModel
        self._isControlButtonsPresent = isControlButtonsPresent
        self._isDebugInfoPresent = isDebugInfoPresent
        if let url = viewModel.watchUrl {
            self.shareSheet = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        }
    }

    private func onDragEnded(drag: DragGesture.Value) {
        let isLandscape = verticalSizeClass == .compact
        let dragDirection = isLandscape ? drag.startLocation.x - drag.location.x : drag.startLocation.y - drag.location.y
        let offsetFromTopOfView = cardOffsetX(for: position) +
            (isLandscape ? drag.translation.width : drag.translation.height)
        let expandedPos = cardOffsetX(for: .expanded)
        let hiddenPos = cardOffsetX(for: .hidden)
        let abovePosition: CardPosition
        let belowPosition: CardPosition

        if offsetFromTopOfView - expandedPos < hiddenPos - offsetFromTopOfView {
            abovePosition = .expanded
            belowPosition = .collapsed
        } else {
            abovePosition = .collapsed
            belowPosition = .hidden
        }

        if dragDirection < 0 {
            position = belowPosition
        } else if dragDirection > 0 {
            position = abovePosition
        }
    }

    private func cardOffsetX(for state: CardPosition) -> CGFloat {
        let isLandscape = verticalSizeClass == .compact
        var offset: CGFloat = 0
        let isNarrowScreen = (isLandscape ?
                                floor(UIScreen.main.bounds.width / UIScreen.main.bounds.height) :
                                floor(UIScreen.main.bounds.height / UIScreen.main.bounds.width)) == 2.0

        switch state {
        case .expanded:
            offset = isLandscape ?
                UIScreen.main.bounds.width * (isNarrowScreen ? 0.09 : 0) :
                UIScreen.main.bounds.height * (isNarrowScreen ? 0.55 : 0.45)
        case .collapsed:
            offset = isLandscape ?
                UIScreen.main.bounds.width * (isNarrowScreen ? 0.8 * narrowScreenRatio : 0.3) :
                UIScreen.main.bounds.height * (isNarrowScreen ? 0.3 * narrowScreenRatio : 0.6)
        case .hidden:
            offset = (isLandscape ? UIScreen.main.bounds.width : UIScreen.main.bounds.height) * 0.85
        }

        if isLandscape {
            return max(offset + dragState.translation.width, UIScreen.main.bounds.width * (isNarrowScreen ? 0.07 : 0))
        } else {
            return max(offset + dragState.translation.height, UIScreen.main.bounds.height * (isNarrowScreen ? 0.4 : 0.3))
        }
    }

    @ViewBuilder private func streamControlButtons() -> some View {
        Group {
            if viewModel.isMuted {
                ControlButton(
                    title: "Unmute",
                    action: viewModel.mute,
                    icon: "mic.fill",
                    backgroundColor: Constants.error
                )
            } else {
                ControlButton(
                    title: "Mute",
                    action: viewModel.mute,
                    icon: "mic.slash.fill",
                    backgroundColor: Constants.backgroundButton
                )
            }

            if viewModel.cameraIsOn {
                ControlButton(
                    title: "Camera off",
                    action: viewModel.toggleCamera,
                    icon: "video.slash.fill",
                    backgroundColor: Constants.backgroundButton,
                    disabled: !viewModel.canToggleCamera
                )
            } else {
                ControlButton(
                    title: "Camera on",
                    action: viewModel.toggleCamera,
                    icon: "video.fill",
                    backgroundColor: Constants.error,
                    disabled: !viewModel.canToggleCamera
                )
            }

            ControlButton(
                title: "Flip",
                action: viewModel.flipCamera,
                icon: "arrow.triangle.2.circlepath.camera.fill",
                disabled: !viewModel.canFlipCamera
            )


            if viewModel.sessionIsRunning {
                ControlButton(
                    title: "End stream",
                    action: viewModel.toggleBroadcastSession,
                    icon: "multiply",
                    iconColor: .white,
                    iconSize: 30,
                    backgroundColor: .clear,
                    borderColor: Constants.red,
                    disabled: !viewModel.canStartSession
                )
            } else {
                ControlButton(
                    title: "Start",
                    action: viewModel.toggleBroadcastSession,
                    icon: "circle.fill",
                    iconColor: Constants.red,
                    iconSize: viewModel.sessionIsRunning ? 30 : 43,
                    backgroundColor: .white,
                    borderColor: .clear,
                    disabled: !viewModel.canStartSession
                )
            }
        }
        .transition(.move(edge: .bottom))
    }

    @ViewBuilder private func shareAndInviteButtons() -> some View {
        Group {
            if dragState.isDragging || position != .collapsed {
                ZStack {
                    SimpleButton(title: "Share screen", height: 50) {
                        if viewModel.sessionIsRunning {
                            isScreenShareAlertPresent = true
                        } else {
                            viewModel.broadcastPicker.toggleView()
                        }
                    }
                }

                SimpleButton(title: "Invite to watch", height: 50) {
                    guard let shareSheet = shareSheet else { return }
                    DispatchQueue.main.async {
                        UIApplication.shared.windows.first?.rootViewController?.present(shareSheet, animated: true)
                    }
                }
            }
        }
        .frame(maxWidth: 200)
        .padding(.bottom, 10)
        .transition(.move(edge: verticalSizeClass == .compact ? .trailing : .bottom))
        .alert(isPresented: $isScreenShareAlertPresent) {
            Alert(
                title: Text("Your stream must be restarted"),
                message: Text("Your stream will go offline for a few moments while screen sharing is started."),
                primaryButton: .default(Text("Cancel")),
                secondaryButton: .cancel(Text("Continue"), action: {
                    if viewModel.sessionIsRunning {
                        viewModel.broadcastSession?.stop()
                    }
                    viewModel.broadcastPicker.toggleView()
                })
            )
        }
    }

    var body: some View {
        let drag = DragGesture()
            .updating($dragState) { drag, state, transaction in
                state = .dragging(translation: drag.translation)
            }
            .onEnded(onDragEnded)

        return ZStack {
            VStack {}
                .frame(height: cardHeight + 200)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .gesture(drag)

            Group {
                if verticalSizeClass == .compact {
                    // Landscape
                    HStack(alignment: .bottom, spacing: 20) {
                        if viewModel.developerMode && isControlButtonsPresent && !isDebugInfoPresent {
                            DebugButton(title: "Show debug info", color: Constants.yellow, background: Constants.background) {
                                isDebugInfoPresent.toggle()
                            }
                            .frame(width: 150)
                            .padding(.bottom, 20)
                        } else {
                            Spacer()
                                .frame(height: 34)
                        }

                        ZStack {
                            VisualEffectView(effect: UIBlurEffect(style: .dark))
                            HStack {
                                RoundedRectangle(cornerRadius: 2.5)
                                    .frame(width: 5, height: 40)
                                    .foregroundColor(Color.secondary)
                                    .padding(5)

                                VStack {
                                    streamControlButtons()
                                        .simultaneousGesture(drag)
                                }
                                .padding(.vertical, 12)
                                .padding(.trailing, 20)
                                .frame(width: 100, height: UIScreen.main.bounds.height)

                                VStack(alignment: .leading, spacing: 20) {
                                    shareAndInviteButtons()
                                        .simultaneousGesture(drag)
                                }

                                Spacer()
                            }
                            .frame(width: UIScreen.main.bounds.width / 2)
                        }
                        .cornerRadius(20)
                    }

                } else {
                    // Portrait
                    VStack(spacing: 20) {
                        if viewModel.developerMode && isControlButtonsPresent && !isDebugInfoPresent {
                            DebugButton(title: "Show debug info", color: Constants.yellow, background: Constants.background) {
                                isDebugInfoPresent.toggle()
                            }
                            .frame(maxWidth: 153)
                        } else {
                            Spacer()
                                .frame(height: 34)
                        }

                        ZStack {
                            VisualEffectView(effect: UIBlurEffect(style: .dark))

                            VStack {
                                RoundedRectangle(cornerRadius: 2.5)
                                    .frame(width: 40, height: 5.0)
                                    .foregroundColor(Color.secondary)
                                    .padding(5)

                                HStack {
                                    streamControlButtons()
                                        .simultaneousGesture(drag)
                                }
                                .padding(.bottom, 25)

                                HStack(spacing: 20) {
                                    shareAndInviteButtons()
                                        .simultaneousGesture(drag)
                                }
                                .padding(.horizontal, 25)

                                Spacer()
                            }
                        }
                        .cornerRadius(20)
                    }
                    .frame(height: cardHeight)
                }
            }
            .frame(maxHeight: cardHeight)
            .gesture(drag)
            .animation(.easeOut(duration: 0.3))
        }
        .offset(x: verticalSizeClass == .compact ? cardOffsetX(for: position) : 0,
                y: verticalSizeClass == .compact ? 0 : cardOffsetX(for: position))
        .onTapGesture {
            position = position == .hidden ? .collapsed : .hidden
        }
        .notification(isPresent: $isErrorPresent,
                      title: "ERROR",
                      message: errorMessage,
                      height: 77,
                      type: .error)
        .notification(isPresent: $isSuccessPresent,
                      title: "SUCCESS",
                      message: successMessage,
                      height: 55,
                      type: .success)
    }
}
