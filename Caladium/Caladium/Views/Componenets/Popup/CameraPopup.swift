//
//  CameraPopup.swift
//  Caladium
//
//  Created by yoomin on 7/24/25.
//

import SwiftUI

struct CameraPopup: View {
    let cancelButtonAction: () -> Void
    let confirmButtonAction: () -> Void
    
    var body: some View {
        Rectangle()
            .fill(Color.gray0)
            .cornerRadius(14)
            .frame(maxWidth: 357, maxHeight: 212)
            .shadow(color: .gray900.opacity(0.25), radius: 1.5, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(.gray400, lineWidth: 1)
            )
            .overlay(
                VStack(alignment: .center, spacing: 0){
                    Text("일관적으로 찍을 수 있는 장소인가요?")
                        .customFont(.popupCategory)
                        .foregroundStyle(Color.gray900)
                        .padding(.bottom, 4)
                    Text("일관된 조명과 배경에서 촬영하면")
                        .customFont(.categoryButtonBody)
                        .foregroundStyle(Color.gray500)
                    Text("완성도 높은 결과물을 얻을 수 있어요")
                        .customFont(.categoryButtonBody)
                        .foregroundStyle(Color.gray500)
                    
                    // 액션 버튼들
                    actionButtons
                        .padding(.vertical, 20)
                }
                    .padding(.horizontal, 20), alignment: .bottom
            )
            .overlay(titleHeader, alignment: .top)
        
    }
    
    // MARK: - 제목 헤더
    private var titleHeader: some View {
        UnevenRoundedRectangle(
            cornerRadii: .init(
                topLeading: 10,
                bottomLeading: 0,
                bottomTrailing: 0,
                topTrailing: 10
            )
        )
        .fill(.pink300)
        .stroke(Color.pink600, lineWidth: 1)
        .frame(height: 44)
        .overlay(
            Text("사진찍기 TIP")
                .customFont(.popupTitle)
                .foregroundColor(.gray0)
        )
    }
    
    // MARK: - 액션 버튼들
    private var actionButtons: some View {
        HStack(spacing: 78) {
            ActionButton(
                title: "취소",
                backgroundColor: .gray200,
                borderColor: .gray300,
                action: {
                    cancelButtonAction()
                }
            )
            
            ActionButton(
                title: "확인",
                backgroundColor: .pink300,
                borderColor: .pink600,
                action: {
                    confirmButtonAction()
                }
            )
        }
    }
}

#Preview {
    CameraPopup(cancelButtonAction: {}, confirmButtonAction: {})
        .padding()
}
