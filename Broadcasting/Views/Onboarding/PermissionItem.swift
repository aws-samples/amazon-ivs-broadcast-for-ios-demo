//
//  PermissionItem.swift
//  Broadcasting
//
//  Created by Uldis Zingis on 15/06/2021.
//

import SwiftUI

struct PermissionItem: View {
    var title: String
    var description: String
    @Binding var isOn: Bool
    var action: () -> Void

    var body: some View {
        HStack(spacing: 23) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isOn ? Color.clear : Constants.lightGray, lineWidth: 3)
                    .frame(width: 32, height: 32)
                    .background(isOn ? Constants.yellow : Color.clear)
                    .cornerRadius(6)
                    .contentShape(Rectangle())
                    .padding(.top, 2)

                if isOn {
                    Image(systemName: "checkmark")
                        .foregroundColor(.black)
                        .font(.system(size: 17, weight: .semibold))
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .foregroundColor(.white)
                    .font(Constants.fAppHeavy)
                    .fontWeight(.bold)
                Text(description)
                    .foregroundColor(Constants.lightGray)
                    .font(Font.custom(Constants.defaultFontName, size: 13))
            }
        }
        .padding(.horizontal, 19)
        .padding(.vertical, 20)
        .onTapGesture {
            action()
        }
    }
}
