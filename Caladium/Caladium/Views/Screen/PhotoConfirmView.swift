//
//  PhotoConfirmView.swift
//  Caladium
//
//  Created by yoomin on 7/17/25.
//

import SwiftUI

// MARK: - Photo Confirm View
struct PhotoConfirmView: View {
    let image: UIImage
    let context: CameraContext
    @EnvironmentObject var coordinator: AppCoordinator
    @ObservedObject private var vm: CameraViewModel
    
    init(image: UIImage, vm: CameraViewModel, context: CameraContext) {
        self.image = image
        self._vm = ObservedObject(wrappedValue: vm)
        self.context = context
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
                        coordinator.popCameraView()
                    } label: {
                        Image("arrow-back-green700")
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 77)
                .padding(.bottom, 10)
                
                HStack{
                    VStack(alignment: .leading){
                        Text("이 사진으로 할까요?")
                            .font(.title2)
                            .bold()
                            .padding(.bottom, 5)
                        Text(contextDescription)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                }
                .padding(.horizontal,24)
                .padding(.bottom, 21)
                
                // 촬영된 이미지
//                PhotoFrame(photo: Photo)
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(4/3, contentMode: .fit)
                    .clipped()
                    .padding(.horizontal, 18)
                
                Spacer()
                
                bottomToolbar
                    .padding(.bottom, 14)
                
            }
            .navigationBarHidden(true)
        }
        
    }
    
    private var contextDescription: String {
        switch context {
        case .newProject:
            return "이 사진으로 새 프로젝트를 시작하시겠습니까?"
        case .existingProject:
            return "이 사진을 프로젝트에 추가하시겠습니까?"
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
                    coordinator.confirmPhoto(image, context: context)
                } label: {
                    Image("btn-select-0")
                }

            }
            .background(Color.gray0)
        }
    }
}

#Preview {
    PhotoConfirmView(image: UIImage(named: "sample") ?? UIImage(), vm: CameraViewModel(coordinator: AppCoordinator()), context: .newProject)
}
