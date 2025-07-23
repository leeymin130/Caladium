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
        ZStack {
            // 메인 카메라 화면
            mainCameraView
            
            // 커스텀 팝업 오버레이
            if vm.isShowingAlert {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                CameraPopup(
                    cancelButtonAction: {
                        vm.cancelAlert()
                    },
                    confirmButtonAction: {
                        vm.confirmAlert()
                    }
                )
                .padding(.horizontal, 20)
            }
        }
        .foregroundColor(.gray0)
        .background(Color.gray900)
        .navigationBarHidden(true)
        .onAppear {
            print("🔥 onAppear 호출됨")
            vm.setContext(context)
            vm.cameraService.requestCameraPermission()
        }
    }
    
    // MARK: - 메인 카메라 뷰
    private var mainCameraView: some View {
        VStack(spacing: 0) {
            // 상단 툴바 영역
            HStack {
                Button {
                    // 햅틱 피드백 추가
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    
                    vm.cancel()
                } label: {
                    Image("arrow-back-gray0")
                }
                
                Spacer()
            }
            .padding(24)
            .background(Color.gray900)
            
            // 카메라 프리뷰 영역
            CameraViewController(cameraService: vm.cameraService)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.gray900)
                .overlay(
                    Group {
                        // isOverlayOn이 true일 때만 오버레이 이미지를 표시합니다.
                        if vm.isOverlayOn, let uiImage = vm.overlayImage {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .opacity(0.5)
                        }
                    }
                )
            
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
                    // 햅틱 피드백 추가
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    
                    vm.capturePhoto()
                                        
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
                        // 햅틱 피드백 추가
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        
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
            .padding(.bottom, 20)
            .background(Color.gray900)
        }
    }
}

#Preview {
    CameraView(vm: CameraViewModel(coordinator: AppCoordinator()), context: .newProject)
}
