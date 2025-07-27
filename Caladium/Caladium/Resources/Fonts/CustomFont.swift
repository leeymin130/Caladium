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
                .frame(height: 15)
        case .categoryButtonBody:
            content
                .font(.custom("SUIT-Regular", size: 12))
                .frame(height: 17)
        case .navigationBarTitle:
            content
                .font(.custom("SUIT-SemiBold", size: 24))
                .frame(height: 33)
        case .photoDate:
            content
                .font(.custom("SUIT-SemiBold", size: 15))
                .frame(height: 15)
        case .popupTitle:
            content
                .font(.custom("Paperlogy-6SemiBold", size: 14))
                .frame(height: 16)
        case .popupCategory:
            content
                .font(.custom("SUIT-Bold", size: 16))
                .frame(height: 33)
        case .categoryTitle:
            content
                .font(.custom("Paperlogy-6SemiBold", size: 18))
                .frame(height: 33)
        }
    }
}


extension View {
    func customFont(_ style: TypographyStyle) -> some View {
        self.modifier(CustomFontModifier(style: style))
    }
}

