//
//  Buttons.swift
//  Broadcasting
//
//  Created by Uldis Zingis on 15/06/2021.
//

import SwiftUI

struct PrimaryButton: View {
    var title: String
    @Binding var isEnabled: Bool
    var action: () -> Void

    init(title: String, isEnabled: Binding<Bool> = .constant(true), action: @escaping () -> Void) {
        self.title = title
        self._isEnabled = isEnabled
        self.action = action
    }

    var body: some View {
        Button(action: {
            action()
        }, label: {
            Text(title)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .font(Constants.fAppBoldLarge)
        })
        .frame(height: 50)
        .background(isEnabled ? Constants.yellow : Constants.lightGray)
        .cornerRadius(8)
        .disabled(!isEnabled)
    }
}

struct DisabledPrimaryButton: View {
    var title: String
    var background: Color = .black

    var body: some View {
        ZStack {
            Rectangle()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Constants.borderColor, lineWidth: 5)
                        .background(background)
                )
                .frame(maxWidth: .infinity)
            Text(title)
                .foregroundColor(Constants.lightGray)
                .font(Constants.fAppBoldLarge)
                .frame(maxWidth: .infinity)
        }
        .frame(height: 50)
        .background(Color.clear)
        .cornerRadius(8)
    }
}

struct SecondaryButton: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }, label: {
            Text(title)
                .foregroundColor(Constants.yellow)
                .frame(maxWidth: .infinity)
                .font(Constants.fAppRegular)
        })
        .frame(height: 50)
    }
}

struct DebugButton: View {
    var title: String
    var color: Color = .black
    var background: Color = Constants.yellow
    var action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }, label: {
            Text(title)
                .foregroundColor(color)
                .font(Constants.fAppRegular)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 10)
        })
        .frame(height: 34)
        .background(background)
        .cornerRadius(8)
    }
}

struct ControlButton: View {
    var title: String
    var action: () -> Void
    var icon: String
    var iconColor: Color = .white
    var iconSize: CGFloat = 22
    var backgroundColor: Color = Constants.backgroundButton
    var borderColor: Color = Color.clear
    var disabled: Bool = false

    var body: some View {
        Button(action: {
            action()
        }) {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: iconSize)
                        .stroke(borderColor, lineWidth: 2)
                        .frame(width: 52, height: 52)
                    Circle()
                        .fill(backgroundColor)
                        .frame(width: 52, height: 52)
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                        .font(Font.custom(Constants.defaultFontName, size: iconSize))
                }

                Text(title)
                    .font(Font.custom(Constants.defaultFontName, size: 13))
                    .foregroundColor(.white)
            }
            .opacity(disabled ? 0.2 : 1.0)
        }
        .frame(maxWidth: .infinity)
        .disabled(disabled)
        .transition(.opacity)
    }
}

struct SimpleButton: View {
    var title: String
    var height: CGFloat = 10
    var maxWidth: CGFloat = .infinity
    var font: Font = Constants.fAppRegular
    var backgroundColor: Color = Constants.backgroundButton
    var action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }, label: {
            Text(title)
                .foregroundColor(.white)
                .frame(maxWidth: maxWidth)
                .font(font)
        })
        .frame(height: height)
        .background(backgroundColor)
        .cornerRadius(48)
    }
}
