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
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            // 제목 헤더
            titleHeader
            
            // 카테고리 선택 영역
            categorySelector
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
        Text("카테고리 변경")
            .font(.system(size: 16, weight: .bold))
            .multilineTextAlignment(.center)
            .foregroundColor(.gray0)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(.green500)
            .clipShape(.rect(topLeadingRadius: 14, topTrailingRadius: 14))
    }
    
    // MARK: - 카테고리 선택 영역
    private var categorySelector: some View {
        HStack(spacing: 70) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.1)) {
                    let currentIndex = categories.firstIndex(of: selectedCategory) ?? 0
                    if currentIndex > 0 {
                        selectedCategory = categories[currentIndex - 1]
                    } else {
                        selectedCategory = categories.last! // 마지막으로 이동
                    }
                }
            }) {
                Image(systemName: "chevron.left")
                    .frame(width: 20, height: 20)
                    .foregroundColor(.green700)
            }
            
            Text("칼라디움의 \(selectedCategory.displayName)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.gray900)
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.1)) {
                    let currentIndex = categories.firstIndex(of: selectedCategory) ?? 0
                    if currentIndex < categories.count - 1 {
                        selectedCategory = categories[currentIndex + 1]
                    } else {
                        selectedCategory = categories.first! // 처음으로 이동
                    }
                }
            }) {
                Image(systemName: "chevron.right")
                    .frame(width: 20, height: 20)
                    .foregroundColor(.green700)
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
    }
    
    // MARK: - 액션 버튼들
    private var actionButtons: some View {
        HStack(spacing: 78) {
            ActionButton(
                title: "취소",
                backgroundColor: .gray200,
                borderColor: .gray300,
                action: {
                    print("취소")
                }
            )
            
            ActionButton(
                title: "확인",
                backgroundColor: .green500,
                borderColor: .green700,
                action: {
                    print("확인")
                }
            )
        }
    }
}

#Preview {
    CategoryChangePopup()
        .padding()
}
