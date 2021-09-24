//
//  TextInput.swift
//  Broadcasting
//
//  Created by Uldis Zingis on 16/06/2021.
//

import SwiftUI

struct TextInputView: View {
    var title: String
    var placeholder: String = ""
    var description: String = ""
    @ObservedObject var viewModel: BroadcastViewModel
    @Binding var textBinding: String
    var dismissAction: () -> Void

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    var body: some View {
        let textInput = TextInputField(textBinding: $textBinding, placeholder: placeholder)

        return ZStack(alignment: .top) {
            Constants.background
                .edgesIgnoringSafeArea(.all)

            VStack() {
                textInput

                Text(description)
                    .foregroundColor(Constants.lightGray)
                    .font(Constants.fAppRegularSmall)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)

                SettingsEntry(title: "Paste from clipboard") {
                    textBinding = UIPasteboard.general.string ?? ""
                    withAnimation {
                        dismissKeyboard()
                    }
                }

                Spacer()
            }
            .padding(.vertical, 75)

            HeaderView(title: title, leftButtonAction: dismissAction)
        }
        .modifier(DismissOnSwipe(dismissAction: dismissAction))
        .onTapGesture {
            dismissKeyboard()
        }
    }
}
