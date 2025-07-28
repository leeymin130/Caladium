//
//  ProjectAddButton.swift
//  Caladium
//
//  Created by yoomin on 6/26/25.
//

import SwiftUI

struct ProjectAddButton: View {
    var isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            if isEnabled {
                // 햅틱 피드백 추가
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                
                action()
            }
        }) {
            Rectangle()
                .fill(Color.gray0)
                .frame(width: 100, height: 100)
                .cornerRadius(10)
                .shadow(color: .gray900.opacity(0.25), radius: 1.5, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            Color.gray400,
                            lineWidth: 1
                        )
                )
                .overlay(
                    UnevenRoundedRectangle(
                        cornerRadii: .init(
                            topLeading: 10,
                            bottomLeading: 0,
                            bottomTrailing: 0,
                            topTrailing: 10
                        )
                    )
                    .fill(isEnabled ? Color.green500 : Color.gray300)
                    .stroke(isEnabled ? Color.green700 : Color.gray400, lineWidth: 1)
                    .frame(width: 100, height: 51),alignment: .top
                    
                )
                .overlay(
                    VStack(alignment: .center, spacing: 0){
                        Image("plant")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 38, height: 38)
                            .padding(.top, 6)
                            .padding(.bottom, 7)
                        
                        Text("새로운 식물")
                            .customFont(.categoryButtonTitle)
                            .foregroundColor(.gray900)
                            .padding(.top, 7)
                        
                        Text("추가하기")
                            .customFont(.categoryButtonBody)
                            .foregroundColor(.gray400)
                    }, alignment: .top
                )
        }
        .disabled(!isEnabled)
    }
}


#Preview {
    VStack(spacing: 30) {
        ProjectAddButton(isEnabled: true) {
            print("프로젝트 추가 - 활성화")
        }
        
        ProjectAddButton(isEnabled: false) {
            print("프로젝트 추가 - 비활성화")
        }
    }
    .padding()
}
