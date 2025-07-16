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
    
    var body: some View {
        ZStack {
            Image("bg-picture")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("📸 사진 확인")
                    .font(.title2)
                    .bold()
                
                // 촬영된 이미지 (임시)
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(4/3, contentMode: .fit)
                    .overlay {
                        VStack {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                            Text("촬영 완료!")
                        }
                    }
                
                Text(contextDescription)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                // 액션 버튼들
                VStack(spacing: 12) {
                    Button {
                        coordinator.confirmPhoto(image, context: context)
                    } label: {
                        Text("사용하기")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button {
                        coordinator.retakePhoto()
                    } label: {
                        Text("다시 찍기")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(40)
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
}

#Preview {
    PhotoConfirmView(image: UIImage(named: "sample") ?? UIImage(), context: .newProject)
}
