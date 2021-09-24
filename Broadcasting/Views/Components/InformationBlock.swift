//
//  InformationBlock.swift
//  Broadcasting
//
//  Created by Uldis Zingis on 15/06/2021.
//

import SwiftUI

struct InformationBlock: View {
    var icon: String
    var iconSize: CGFloat = 27
    var iconColor: Color = .white
    var withIconFrame: Bool = true
    var title: String
    var description: String
    var height: CGFloat

    var body: some View {
        Group {
            ZStack {
                if withIconFrame {
                    Rectangle()
                        .frame(width: 82, height: height)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Constants.yellow, lineWidth: 3)
                                .background(Color.black)
                        )
                }
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: iconSize))
            }
            .padding(.bottom, withIconFrame ? 50 : 15)

            Text(title)
                .foregroundColor(.white)
                .font(Constants.fAppBoldExtraLarge)
                .padding(.bottom, 10)
            Text(description)
                .foregroundColor(.white)
                .font(Constants.fAppRegular)
                .multilineTextAlignment(.center)
        }
    }
}
