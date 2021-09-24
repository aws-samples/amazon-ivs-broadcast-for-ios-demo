//
//  Modifiers.swift
//  Broadcasting
//
//  Created by Uldis Zingis on 01/07/2021.
//

import SwiftUI

struct FooterText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(Constants.lightGray)
            .font(Constants.fAppMediumSmall)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
            .multilineTextAlignment(.leading)
    }
}

struct ClearButton: ViewModifier {
    @Binding var text: String
    var onClear: (() -> Void)?

    public func body(content: Content) -> some View {
        HStack {
            content
            Spacer()
            Image(systemName: "multiply.circle.fill")
                .foregroundColor(Constants.lightGray)
                .opacity(text == "" ? 0 : 1)
                .onTapGesture {
                    self.text = ""
                    if let onClear = onClear {
                        onClear()
                    }
                }
        }
    }
}

struct DismissOnSwipe: ViewModifier {
    var dismissAction: () -> Void
    @State private var dragOffsetX: CGFloat = 0

    public func body(content: Content) -> some View {
        content
            .offset(x: dragOffsetX)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        guard gesture.translation.width > 0 else { return }
                        withAnimation {
                            dragOffsetX = gesture.translation.width
                        }
                    }
                    .onEnded { gesture in
                        withAnimation {
                            dragOffsetX = 0
                        }
                        guard gesture.translation.width > 0,
                              gesture.translation.width > 100 else { return }
                        withAnimation(.linear(duration: 0.2)) {
                            dragOffsetX = UIScreen.main.bounds.width
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                dismissAction()
                            }
                        }
                    }
            )
    }
}
