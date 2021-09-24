//
//  TextInputField.swift
//  Broadcasting
//
//  Created by Uldis Zingis on 18/06/2021.
//

import SwiftUI

struct TextInputField: View {
    @Binding var textBinding: String
    @State var placeholder: String
    var onFocus: () -> Void
    var onClear: (() -> Void)?

    init(textBinding: Binding<String>,
         placeholder: String,
         onFocus: @escaping () -> Void = {},
         onClear: (() -> Void)? = nil) {
        self._textBinding = textBinding
        self.placeholder = placeholder
        self.onFocus = onFocus
        self.onClear = onClear
    }

    var body: some View {
        let text = Binding<String>(
            get: {
                textBinding
            }, set: {
                textBinding = $0
            }
        )

        return ZStack(alignment: .leading) {
            if text.wrappedValue.isEmpty {
                Text(placeholder)
                    .font(Constants.fAppRegularLarge)
                    .foregroundColor(Constants.lightGray)
                    .padding(.horizontal, 16)
                    .opacity(0.6)
            }
            TextField("", text: text, onEditingChanged: { isEditing in
                if isEditing {
                    onFocus()
                    return
                }
            })
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .font(Constants.fAppRegularLarge)
            .modifier(ClearButton(text: text, onClear: onClear))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
        }
        .frame(height: 44)
        .background(Constants.backgroundGrayDark)
    }
}
