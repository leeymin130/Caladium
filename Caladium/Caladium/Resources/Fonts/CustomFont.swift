//
//  CustomFont.swift
//  Caladium
//
//  Created by yoomin on 7/25/25.
//

import SwiftUI

enum TypographyStyle {
    case categoryButtonTitle
    case categoryButtonBody
    case navigationBarTitle
    case photoDate
    case popupTitle
    case popupCategory
    case categoryTitle
}

struct CustomFontModifier: ViewModifier {
    let style: TypographyStyle

    func body(content: Content) -> some View {
        switch style {
        case .categoryButtonTitle:
            content
                .font(.custom("SUIT-SemiBold", size: 13))
                .padding(.vertical, 1)
        case .categoryButtonBody:
            content
                .font(.custom("SUIT-Regular", size: 12))
                .padding(.vertical, 2.5)
        case .navigationBarTitle:
            content
                .font(.custom("SUIT-SemiBold", size: 24))
                .padding(.vertical, 4.5)
        case .photoDate:
            content
                .font(.custom("SUIT-SemiBold", size: 15))
        case .popupTitle:
            content
                .font(.custom("Paperlogy-6SemiBold", size: 14))
                .padding(.vertical, 1)
        case .popupCategory:
            content
                .font(.custom("SUIT-Bold", size: 16))
                .padding(.vertical, 8.5)
        case .categoryTitle:
            content
                .font(.custom("Paperlogy-6SemiBold", size: 18))
                .padding(.vertical, 7.5)  // (33 - 18) / 2 : line height 보정
        }
    }
}


extension View {
    func customFont(_ style: TypographyStyle) -> some View {
        self.modifier(CustomFontModifier(style: style))
    }
}

