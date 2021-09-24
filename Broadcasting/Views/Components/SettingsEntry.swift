//
//  SettingsEntry.swift
//  Broadcasting
//
//  Created by Uldis Zingis on 14/06/2021.
//

import SwiftUI

struct SettingsEntry: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?

    var title: String
    var value: String?
    var isDisabled: Bool
    var isSwitch: Bool
    var useCheckmark: Bool
    var isInfoCell: Bool
    var background: Color
    @Binding var isOn: Bool
    var action: () -> Void

    init(title: String,
         value: String? = nil,
         isDisabled: Bool = false,
         isSwitch: Bool = false,
         useCheckmark: Bool = false,
         isInfoCell: Bool = false,
         background: Color = Constants.backgroundGrayDark,
         isOn: Binding<Bool> = .constant(false),
         action: @escaping () -> Void = {}) {
        self.title = title
        self.value = value
        self.isDisabled = isDisabled
        self.isSwitch = isSwitch
        self.useCheckmark = useCheckmark
        self.isInfoCell = isInfoCell
        self.background = background
        self._isOn = isOn
        self.action = action
    }

    var body: some View {
        HStack {
            if isSwitch || value != nil {
                Text(title)
                    .foregroundColor(isDisabled ? .gray : .white)
                    .font(Constants.fAppRegularLarge)
                    .padding(.leading, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()

                if isSwitch {
                    if useCheckmark {
                        if isOn {
                            Image(systemName: "checkmark")
                                .foregroundColor(Constants.yellow)
                                .padding(.trailing, 16)
                        }
                    } else {
                        Toggle("", isOn: $isOn)
                            .padding(.trailing, 16)
                            .frame(maxWidth: 100)
                    }

                } else {
                    Text(value!)
                        .foregroundColor(Constants.gray)
                        .opacity(0.6)
                        .font(Constants.fAppRegularLarge)
                        .padding(.trailing, isInfoCell ? 16 : 0)
                    if !isInfoCell {
                        Image(systemName: "chevron.right")
                            .foregroundColor(Constants.gray)
                            .opacity(0.3)
                            .padding(.trailing, 16)
                    }
                }
            } else {
                Button(action: {
                    action()
                }, label: {
                    Text(title)
                        .foregroundColor(isDisabled ? .gray : Constants.yellow)
                        .fontWeight(.semibold)
                        .font(Constants.fAppRegularLarge)
                })
            }
        }
        .frame(width: UIScreen.main.bounds.width - (verticalSizeClass == .compact ? 60 : 0), height: 30)
        .padding(.vertical, 11)
        .background(background)
        .overlay(Rectangle().frame(width: nil, height: 0.5, alignment: .top).foregroundColor(Constants.borderColor), alignment: .top)
        .overlay(Rectangle().frame(width: nil, height: 0.5, alignment: .bottom).foregroundColor(Constants.borderColor), alignment: .bottom)
        .onTapGesture {
            if value != nil || isSwitch {
                action()
            }
        }
        .disabled(isDisabled)
    }
}
