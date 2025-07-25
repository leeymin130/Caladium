//
//  DeleteConfirmPopup.swift
//  Caladium
//
//  Created by yoomin on 6/25/25.
//

import SwiftUI

struct PhotoDeleteConfirmPopup: View {
    let cancelButtonAction: () -> Void
    let confirmButtonAction: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            // 제목 헤더
            titleHeader
            
            VStack(alignment: .center, spacing: 0){
                Text("정말로 이 사진을 삭제하시겠어요?")
                    .customFont(.popupCategory)
                    .foregroundStyle(Color.gray900)
                    .padding(.bottom, 4)
                Text("삭제하면 사진과 관련된 모든 정보가 완전히 사라지며,")
                    .customFont(.categoryButtonBody)
                    .foregroundStyle(Color.gray500)
                Text("되돌릴 수 없습니다.")
                    .customFont(.categoryButtonBody)
                    .foregroundStyle(Color.gray500)
            }
            .padding(.horizontal, 20)
            
            // 액션 버튼들
            actionButtons
        }
        .padding(.bottom, 20)
        .background(Color.gray0)
        .cornerRadius(14)
        .shadow(color: .gray900.opacity(0.25), radius: 1.5, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(.gray400, lineWidth: 1)
        )
    }
    
    // MARK: - 제목 헤더
    private var titleHeader: some View {
        Text("사진 삭제하기")
            .customFont(.popupTitle)
            .foregroundColor(.gray0)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(.pink300)
            .clipShape(.rect(topLeadingRadius: 14, topTrailingRadius: 14))
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
    PhotoDeleteConfirmPopup(cancelButtonAction: {}, confirmButtonAction: {})
    .padding()
}
