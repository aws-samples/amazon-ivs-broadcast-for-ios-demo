//
//  NetworkWarning.swift
//  Broadcasting
//
//  Created by Uldis Zingis on 15/06/2021.
//

import SwiftUI

extension View {
    func notification(isPresent: Binding<Bool>,
                      title: String,
                      message: String,
                      height: CGFloat,
                      type: NotificationModifier.NotificationType) -> some View {
        self.modifier(NotificationModifier(isPresent: isPresent, title: title, message: message, height: height, type: type))
    }
}

struct NotificationModifier: ViewModifier {

    enum NotificationType {
        case success
        case warning
        case error
        case plain
    }

    @Binding var isPresent: Bool

    var title: String = ""
    var message: String = ""
    var height: CGFloat = 55
    var type: NotificationType

    @State private var timer: Timer?
    @State private var dismissTimer: Int = 8

    private var icon: String {
        switch type {
        case .error:
            return "exclamationmark.triangle.fill"
        case .warning, .success, .plain:
            return "info.circle.fill"
        }
    }

    private var color: Color {
        switch type {
        case .error:
            return Constants.error
        case .warning:
            return Constants.warning
        case .success:
            return Constants.success
        case .plain:
            return Color.white
        }
    }

    private var textColor: Color {
        switch type {
        case .success, .error:
            return Color.white
        case .warning, .plain:
            return Color.black
        }
    }

    private func startDismissTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            dismissTimer -= 1
            if dismissTimer == 0 {
                isPresent = false
                stopDismissTimer()
            }
        }
    }

    private func stopDismissTimer() {
        timer?.invalidate()
        timer = nil
        dismissTimer = 5
    }

    func body(content: Content) -> some View {
        ZStack {
            content

            if isPresent {
                VStack {
                    ZStack {
                        Rectangle()
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(color)
                                    .background(Color.clear)
                            )
                            .frame(height: height)
                            .frame(maxWidth: .infinity)

                        VStack(alignment: .leading, spacing: 2) {
                            Group {
                                HStack(alignment: .top) {
                                    Image(systemName: icon)
                                        .font(.system(size: 12))
                                        .opacity(0.6)
                                        .foregroundColor(textColor)
                                        .padding(.leading, 3)
                                    Text(title)
                                        .font(Constants.fAppRegularSmall)
                                        .opacity(0.6)
                                        .multilineTextAlignment(.leading)
                                        .foregroundColor(textColor)
                                }
                            }
                            .padding(.horizontal, 16)

                            Text(message)
                                .font(Constants.fAppRegular)
                                .padding(.horizontal, 5)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                                .foregroundColor(textColor)
                        }
                    }
                    .cornerRadius(12)
                    .onTapGesture {
                        isPresent.toggle()
                    }
                    Spacer()
                }
                .padding(.horizontal, 8)
                .onAppear {
                    if type != .warning {
                        startDismissTimer()
                    }
                }
            }
        }
    }
}
