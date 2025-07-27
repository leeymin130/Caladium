//
//  NewProjectCategorySelectView.swift
//  Caladium
//
//  Created by 이종선 on 7/25/25.
//


import SwiftUI

// MARK: - Photo Confirm View
struct NewProjectCategorySelectView: View {
    
    @State private var isButtonPressed = false
    @StateObject private var vm: NewProjectCategorySelectViewModel
    
    init(vm: NewProjectCategorySelectViewModel) {
        self._vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        ZStack {
            Image("bg-picture")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 상단 툴바 영역
                HStack {
                    Button {
                        // 햅틱 피드백 추가
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        
                        vm.back()
                        
                    } label: {
                        Image("arrow-back-green700")
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 77)
                .padding(.bottom, 10)
                
                // 촬영된 이미지
                VStack(alignment: .center, spacing: 0) {
                    // 사진 표시 영역
                    Image(uiImage: vm.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: 246, maxHeight: 246)
                        .clipped()
                        .cornerRadius(5)
                    
                }
                .padding(18)
                .background(.gray0)
                .cornerRadius(14)
                .shadow(color: .gray900.opacity(0.25), radius: 2, x: 0, y: 3)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .inset(by: 0.5)
                        .stroke(Color.gray400, lineWidth: 1)
                )
                .padding(.top, 32)
                .padding(.bottom, 86)
                
                
                Text("이 식물을 어디에 보관할까요?")
                    .customFont(.popupCategory)
                    .padding(.bottom, 35)
                
                categorySelector
                    .padding(.horizontal)
                
                Spacer()
                
                bottomToolbar
                    .padding(.bottom, 14)
                
            }
            .navigationBarHidden(true)
        }
        
    }
    private var categorySelector: some View {
        HStack(spacing: 70) {
            Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                
                withAnimation(.easeInOut(duration: 0.1)) {
                    let currentIndex = vm.categories.firstIndex(of: vm.selectedCategory) ?? 0
                    if currentIndex > 0 {
                        vm.selectedCategory = vm.categories[currentIndex - 1]
                    } else {
                        vm.selectedCategory = vm.categories.last! // 마지막으로 이동
                    }
                }
            }) {
                Image("arrow-back-green700")
            }
            
            Text("\(vm.selectedCategory.displayName)")
                .customFont(.popupCategory)
                .foregroundColor(.gray900)
            
            Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                
                withAnimation(.easeInOut(duration: 0.1)) {
                    let currentIndex = vm.categories.firstIndex(of:vm.selectedCategory) ?? 0
                    if currentIndex < vm.categories.count - 1 {
                        vm.selectedCategory = vm.categories[currentIndex + 1]
                    } else {
                        vm.selectedCategory = vm.categories.first! // 처음으로 이동
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
        .background(.gray0, in: RoundedRectangle(cornerRadius: 10))
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
    
    private var bottomToolbar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.green500)
                .frame(height: 5)
                .frame(maxWidth: .infinity)
            
            HStack {
                Spacer()
                Button {
                    vm.saveNewProject()
                } label: {
                    Image(isButtonPressed ? "btn-select-1" : "btn-select-0")
                }
                .buttonStyle(PlainButtonStyle())
                .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                    isButtonPressed = pressing
                }, perform: {})
                
            }
            .background(Color.gray0)
        }
    }
}

#Preview {
    NewProjectCategorySelectView(vm: NewProjectCategorySelectViewModel(coordinator: AppCoordinator(), coreDataService: CoreDataService(), image: UIImage()))
}
