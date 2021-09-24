//
//  ProgressBar.swift
//  Broadcasting
//
//  Created by Uldis Zingis on 15/06/2021.
//

import SwiftUI

struct ProgressBar: View {
    @Binding var value: Float

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.18)
                    .foregroundColor(Constants.lightGray)

                Rectangle()
                    .frame(width: min(CGFloat(value) * geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(Constants.yellow)
                    .animation(.linear)
                    .cornerRadius(2)
            }
            .cornerRadius(2)
        }
        .frame(height: 4)
        .padding(.horizontal, 16)
    }
}
