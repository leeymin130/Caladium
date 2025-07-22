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
        VStack(alignment: .center, spacing: 20) {
            // 제목 헤더
            titleHeader
            
            // 영상 포멧 선택 안내문구
            VStack(alignment: .center, spacing: 4){
                Text("저장 방식을 선택해주세요")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.gray900)
                    .padding(.bottom, 8)
                Text("GIF는 작은 용량으로 어디든 쉽게 공유할 수 있어요")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.gray500)
                Text("MOV는 고화질로 오래 보관하기 좋아요.")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.gray500)
            }
            .padding(.horizontal, 20)
            
            // 액션 버튼들
            actionButtons
                .padding(.horizontal, 31)
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
        Text("영상 공유하기")
            .font(.system(size: 16, weight: .bold))
            .multilineTextAlignment(.center)
            .foregroundColor(.gray0)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(.green500)
            .clipShape(.rect(topLeadingRadius: 14, topTrailingRadius: 14))
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

}
