//
//  HeaderView.swift
//  HeaderView
//
//  Created by Uldis Zingis on 16/07/2021.
//

import SwiftUI

struct HeaderView: View {
    var title: String = ""
    var leftButtonAction: () -> Void
    var leftButtonTitle = "Back"
    var leftButtonIcon = "chevron.left"
    var rightButtonAction: () -> Void = {}
    var rightButtonTitle: String?

    var body: some View {
        HStack {
            Button {
                withAnimation {
                    leftButtonAction()
                }
            } label: {
                if leftButtonIcon != "" {
                    Image(systemName: leftButtonIcon).foregroundColor(.white)
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                }
                Text(leftButtonTitle)
                    .foregroundColor(.white)
                    .font(Constants.fAppRegularLarge)
            }

            Spacer()

            Text(title)
                .foregroundColor(.white)
                .font(Constants.fAppRegularLarge)

            Spacer()

            if let rightButtonTitle = rightButtonTitle {
                Button(action: rightButtonAction) {
                    Text(rightButtonTitle)
                        .foregroundColor(Constants.yellow)
                        .fontWeight(.bold)
                }
            } else {
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 25)
        .background(Constants.background)
    }
}
