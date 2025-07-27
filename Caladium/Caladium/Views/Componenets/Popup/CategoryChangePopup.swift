//
//  CategoryChangePopup.swift
//  Caladium
//
//  Created by yoomin on 6/24/25.
//

import SwiftUI

struct CategoryChangePopup: View {
    @State private var selectedCategory: Category = .jungle
    
    private let categories = Category.allCases
    let cancelButtonAction: () -> Void
    let confirmButtonAction: (Category) -> Void
    
    init(selectedCategory: Category, cancelButtonAction: @escaping () -> Void, confirmButtonAction: @escaping (Category) -> Void) {
        _selectedCategory = .init(initialValue: selectedCategory)
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
                VStack(alignment: .center, spacing: 0) {
                    // 카테고리 선택 영역
                    categorySelector
                        .padding(.top, 24)
                    
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
            Text("카테고리 변경")
                .customFont(.popupTitle)
                .foregroundColor(.gray0)
        )
    }
    
    // MARK: - 카테고리 선택 영역
    private var categorySelector: some View {
        HStack(spacing: 50) {
            Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                
                withAnimation(.easeInOut(duration: 0.1)) {
                    let currentIndex = categories.firstIndex(of: selectedCategory) ?? 0
                    if currentIndex > 0 {
                        selectedCategory = categories[currentIndex - 1]
                    } else {
                        selectedCategory = categories.last! // 마지막으로 이동
                    }
                }
            }) {
                Image("arrow-back-green700")

            }
            
            Text("\(selectedCategory.displayName)")
                .customFont(.popupCategory)
                .foregroundColor(.gray900)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
            Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                
                withAnimation(.easeInOut(duration: 0.1)) {
                    let currentIndex = categories.firstIndex(of: selectedCategory) ?? 0
                    if currentIndex < categories.count - 1 {
                        selectedCategory = categories[currentIndex + 1]
                    } else {
                        selectedCategory = categories.first! // 처음으로 이동
                    }
                }
            }) {
                Image("arrow-back-green700")
                    .scaleEffect(x: -1)
            }
            
        }
        .padding(.horizontal, 17)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(.gray0)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray300, lineWidth: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray300, lineWidth: 1)
                .shadow(color: .gray900.opacity(0.25), radius: 2, x: 1, y: 1)
                .clipShape(RoundedRectangle(cornerRadius: 10))
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
                backgroundColor: .green500,
                borderColor: .green700,
                action: {
                    confirmButtonAction(selectedCategory)
                }
            )
        }
    }
}

#Preview {
    CategoryChangePopup(selectedCategory: Category.desert, cancelButtonAction: {}, confirmButtonAction: {_ in })
        .padding()
}
