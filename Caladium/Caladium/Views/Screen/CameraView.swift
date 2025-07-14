//
//  CameraView.swift
//  Caladium
//
//  Created by 이종선 on 6/22/25.
//

import SwiftUI
import AVFoundation

// MARK: - Camera View
struct CameraView: View {
    @StateObject private var vm: CameraViewModel
    let context: CameraContext
    
    init(vm: CameraViewModel, context: CameraContext) {
        self._vm = StateObject(wrappedValue: vm)
        self.context = context
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단 툴바 영역
            HStack {
                Button {
                    vm.cancel()
                } label: {
                    Image("arrow-back-w")
                }
                
                Spacer()
            }
            .padding(24)
            .background(Color.gray900)
            
            // 카메라 프리뷰 영역
            CameraViewController(cameraService: vm.cameraService)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.gray900)
            
            
            // 하단 조작부
            HStack(spacing: 0){
                Spacer()
                
                Button {
                    // 가짜 버튼
                } label: {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 75, height: 78)
                    
                }
                
                // 촬영 버튼
                Button {
                    vm.capturePhoto()
                    // 임시 이미지로 다음 단계로
                    //                    let tempImage = UIImage(systemName: "photo") ?? UIImage()
                    
                } label: {
                    Circle()
                        .fill(Color.green500)
                        .frame(width: 78, height: 78)
                        .overlay {
                            Circle()
                                .fill(Color.gray0)
                                .frame(width: 64, height: 64)
                        }
                        .padding(.horizontal, 50)
                }
                
                // 오버레이 토글
                VStack(alignment: .center, spacing: 9) {
                    Button{
                        vm.switchOverlay()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 100)
                                .fill(vm.isOverlayOn ? Color.green400 : Color.gray500)
                                .frame(width: 51, height: 31)
                            
                            Circle()
                                .fill(Color.white)
                                .frame(width: 27, height: 27)
                                .offset(x: vm.isOverlayOn ? 10 : -10)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Text("최근 사진 필터")
                        .font(.caption)
                }
                
                Spacer()
                
            }
            .padding(.top, 54)
            .padding(.bottom, 20) // 하단 패딩값 확인
            .background(Color.gray900)
            
        }
        .foregroundColor(.gray0)
        .navigationBarHidden(true)
        .onAppear {
            print("🔥 onAppear 호출됨")
            vm.cameraService.requestCameraPermission()
        }
        
    }
}


#Preview {
    CameraView(vm: CameraViewModel(coordinator: AppCoordinator()), context: .newProject)
}
