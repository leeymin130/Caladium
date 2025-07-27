//
//  FormatSelectPopupView.swift
//  Caladium
//
//  Created by 이종선 on 7/17/25.
//

import SwiftUI

struct FormatSelectPopupView: View {

    let cancelButtonAction: () -> Void
    let confirmButtonAction: () -> Void
    
    init(cancelButtonAction: @escaping () -> Void, confirmButtonAction: @escaping () -> Void) {
        self.cancelButtonAction = cancelButtonAction
        self.confirmButtonAction = confirmButtonAction
    }
    
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
                // 영상 포멧 선택 안내문구
                VStack(alignment: .center, spacing: 0){
                    Text("저장 방식을 선택해주세요")
                        .customFont(.popupCategory)
                        .foregroundStyle(Color.gray900)
                        .padding(.bottom, 4)
                    Text("GIF는 작은 용량으로 어디든 쉽게 공유할 수 있어요.")
                        .customFont(.categoryButtonBody)
                        .foregroundStyle(Color.gray500)
                    Text("MOV는 높은 화질로 오래 보관하기 좋아요.")
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
                topLeading: 14,
                bottomLeading: 0,
                bottomTrailing: 0,
                topTrailing: 14
            )
        )
        .fill(.green500)
        .stroke(Color.green700, lineWidth: 1)
        .frame(height: 44)
        .overlay(
            Text("영상 공유하기")
                .customFont(.popupTitle)
                .foregroundColor(.gray0)
        )
    }
    

    
    // MARK: - 액션 버튼들
    private var actionButtons: some View {
        HStack(spacing: 40) {
            ActionButton(
                title: "MOV로 만들기",
                backgroundColor: .gray200,
                borderColor: .gray300,
                action: {
                   cancelButtonAction()
                }
            )
            .padding(.horizontal, -12)
            
            ActionButton(
                title: "GIF로 만들기",
                backgroundColor: .green500,
                borderColor: .green700,
                action: {
                    confirmButtonAction()
                }
            )
            .padding(.horizontal, -12)
            
        }
    }
}

#Preview {
    FormatSelectPopupView {} confirmButtonAction: {}
        .padding()

}
