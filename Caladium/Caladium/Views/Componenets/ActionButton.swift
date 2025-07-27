//
//  ActionButton.swift
//  Caladium
//
//  Created by yoomin on 6/25/25.
//

import SwiftUI

// MARK: - 액션 버튼 컴포넌트
struct ActionButton: View {
    let title: String
    let backgroundColor: Color
    let borderColor: Color
    let textColor: Color?
    let action: () -> Void
    
    @State private var scale: CGFloat = 1.0
    
    init(
            title: String,
            backgroundColor: Color,
            borderColor: Color,
            textColor: Color? = nil,
            action: @escaping () -> Void
        ) {
            self.title = title
            self.backgroundColor = backgroundColor
            self.borderColor = borderColor
            self.textColor = textColor
            self.action = action
        }

    
    var body: some View {
        Button(action: {
            // 햅틱 피드백 추가
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            action()
        }) {
            Text(title)
                .customFont(.categoryButtonTitle)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
                .foregroundColor(determineTextColor())
                .background(backgroundColor)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(borderColor, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle()) // 기본 버튼 스타일 제거
        .scaleEffect(scale)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                scale = pressing ? 0.95 : 1.0
            }
        }, perform: {})
    }
    
    private func determineTextColor() -> Color {
            if let textColor = textColor {
                return textColor
            }
            
            // 기본 색상 로직
            switch backgroundColor {
            case .green500:
                return .gray0
            case .pink300:
                return .gray0
            default:
                return .gray900
            }
        }
}

#Preview {
    VStack(spacing: 20) {
        // 확인 버튼
        ActionButton(
            title: "확인",
            backgroundColor: .green500,
            borderColor: .green700,
            action: { print("확인 버튼 클릭") }
        )
        
        // 취소 버튼
        ActionButton(
            title: "취소",
            backgroundColor: .gray200,
            borderColor: .gray300,
            action: { print("취소 버튼 클릭") }
        )
        
        // 확인 버튼(삭제)
        ActionButton(
            title: "삭제",
            backgroundColor: .pink300,
            borderColor: .pink600,
            action: { print("삭제 버튼 클릭") }
        )
    }
    .padding()
}
