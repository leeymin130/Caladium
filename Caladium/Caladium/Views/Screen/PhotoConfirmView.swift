//
//  PhotoConfirmView.swift
//  Caladium
//
//  Created by yoomin on 7/17/25.
//

import SwiftUI

// MARK: - Photo Confirm View
struct PhotoConfirmView: View {

    @StateObject private var vm: PhotoConfirmViewModel
    
    @State private var isButtonPressed = false
    
    init(vm: PhotoConfirmViewModel) {
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
                        
                        // 카메라 내부 네비게이션에서 뒤로가기
                        vm.retakePhoto()
                    } label: {
                        Image("arrow-back-green700")
                            .padding(.horizontal, 24)
                    }
                    
                    Spacer()
                }
                .frame(height: 68)
                .padding(.top, 54)
                .padding(.bottom, 10)
                
                HStack{
                    VStack(alignment: .leading){
                        Text("이 사진으로 할까요?")
                            .customFont(.navigationBarTitle)
                            .foregroundStyle(.gray900)
                            .padding(.bottom, 5)
                        Text(contextDescription)
                            .customFont(.navigationBarBody)
                            .foregroundStyle(.gray500)
                    }
                    Spacer()
                }
                .padding(.horizontal,24)
                .padding(.bottom, 21)
                
                // 촬영된 이미지
                PhotoConfirmFrame(image: vm.image)
                    .padding(.bottom, 16)
                
                Spacer()
                
                bottomToolbar
                    .padding(.bottom, 14)
                
            }
            .navigationBarHidden(true)
        }
        
    }
    
    private var contextDescription: String {
        switch vm.context {
        case .newProject:
            return "현재 사진으로 새 프로젝트를 시작하시겠습니까?"
        case .existingProject:
            return "현재 사진을 프로젝트에 추가하시겠습니까?"
        }
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
                    vm.confirmPhoto()
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

struct PhotoConfirmFrame: View {
    let image: UIImage
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale =  Locale(identifier: "ko_KR")// 시스템 현재 언어 설정 사용
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 사진 표시 영역
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: 321, maxHeight: 423)
                .clipped()
                .cornerRadius(5)
            
            // 사진 촬영 날짜
            Text(formatDate(.now))
                .customFont(.photoDate)
                .foregroundColor(.gray900)
                .padding(.top, 18)
        }
        .padding(.horizontal, 18)
        .padding(.top, 18)
        .padding(.bottom, 48)
        .background(.gray0)
        .cornerRadius(14)
        .shadow(color: .gray900.opacity(0.25), radius: 2, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .inset(by: 0.5)
                .stroke(Color.gray400, lineWidth: 1)
        )
        
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else {
            return NSLocalizedString("date_info_unavailable", value: "날짜 정보 없음", comment: "날짜 정보가 없을 때 표시되는 메시지")
        }
        return dateFormatter.string(from: date)
    }
}

#Preview {
    PhotoConfirmView(vm: PhotoConfirmViewModel(coordinator: AppCoordinator(), coreDataService: CoreDataService(), imgae: UIImage(), context: .newProject))
}
