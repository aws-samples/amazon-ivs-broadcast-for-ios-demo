//
//  TextWithHyperlink.swift
//  Broadcasting
//
//  Created by Uldis Zingis on 05/07/2021.
//

import SwiftUI

struct TextWithHyperlink: UIViewRepresentable {
    var leadingText: String = ""
    var urlLabel: String
    var url: String
    var trailingText: String = ""
    var urlColor: Color = Constants.yellow
    var textColor: Color = Constants.lightGray
    var textAlignment: NSTextAlignment = .left
    var font: UIFont = UIFont(name: Constants.defaultFontName, size: 13) ?? UIFont.systemFont(ofSize: 13)
    var underlineStyle: NSUnderlineStyle = NSUnderlineStyle(rawValue: 0x00)

    func makeUIView(context: Context) -> UITextView {
        let textAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor(cgColor: textColor.cgColor!)
        ]
        let hyperlinkTextAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor(cgColor: urlColor.cgColor!),
            NSAttributedString.Key.underlineStyle: underlineStyle.rawValue,
            NSAttributedString.Key.underlineColor: UIColor(cgColor: urlColor.cgColor!),
            NSAttributedString.Key.link: url
        ]

        let text = NSMutableAttributedString(string: leadingText)
        text.addAttributes(textAttributes, range: NSRange(location: 0, length: text.length))

        let textWithHyperlink = NSMutableAttributedString(string: urlLabel)
        textWithHyperlink.addAttributes(hyperlinkTextAttributes, range: NSRange(location: 0, length: textWithHyperlink.length))

        let trailing = NSMutableAttributedString(string: trailingText)
        trailing.addAttributes(textAttributes, range: NSRange(location: 0, length: trailing.length))

        text.append(textWithHyperlink)
        text.append(trailing)

        let textView = UITextView()
        textView.attributedText = text
        textView.linkTextAttributes = hyperlinkTextAttributes

        textView.isEditable = false
        textView.textAlignment = textAlignment
        textView.backgroundColor = .clear
        textView.isUserInteractionEnabled = false

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {}
}
