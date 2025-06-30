//
//  CameraView.swift
//  Caladium
//
//  Created by 이종선 on 6/22/25.
//

import SwiftUI

// MARK: - Camera View
struct CameraView: View {
    @StateObject private var vm: CameraViewModel
    let context: CameraContext
    
    init(vm: CameraViewModel, context: CameraContext) {
        self._vm = StateObject(wrappedValue: vm)
        self.context = context
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 20) {
                Text("📷 카메라")
                    .font(.largeTitle)
                    .bold()
                
                Text(contextDescription)
                    .foregroundColor(.secondary)
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(4/3, contentMode: .fit)
                    .overlay {
                        Text("카메라 뷰 영역")
                            .foregroundColor(.gray)
                    }
            }
            
            Spacer()
            
            // 촬영 버튼
            Button {
                // 임시 이미지로 다음 단계로
                let tempImage = UIImage(systemName: "photo") ?? UIImage()

            } label: {
                Circle()
                    .fill(Color.white)
                    .frame(width: 80, height: 80)
                    .overlay {
                        Circle()
                            .stroke(Color.black, lineWidth: 3)
                            .frame(width: 70, height: 70)
                    }
            }
            .padding(.bottom, 50)
        }
        .background(Color.black)
        .foregroundColor(.white)
        .navigationBarHidden(true)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button("취소") {
                    vm.cancel()
                }
                .font(.headline)
                .foregroundColor(.white)
            }
        }
    }
    
    private var contextDescription: String {
        switch context {
        case .newProject:
            return "새로운 식물의 첫 번째 사진을 찍어보세요"
        case .existingProject(let project):
            return "\(project.categoryEnum.displayName) 프로젝트에 사진을 추가합니다"
        }
    }
}


#Preview {
    CameraView(vm: CameraViewModel(coordinator: AppCoordinator()), context: .newProject)
}
