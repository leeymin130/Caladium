//
//  CameraView.swift
//  Caladium
//
//  Created by 이종선 on 6/22/25.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject private var vm: CameraViewModel
    @Environment(\.dependencies) private var dependencies
    @Environment(\.scenePhase) private var scenePhase
    
    init(vm: CameraViewModel) {
        self._vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        NavigationStack(path: $vm.coordinator.cameraPath) {
            ZStack {
                // 전체 배경을 검정으로
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 상단 툴바 영역
                    topToolbar
                    
                    // 가운데 카메라 프리뷰 영역
                    cameraPreviewArea
                    
                    // 하단 컨트롤 영역
                    bottomControls
                }
                
                // 촬영 장소 안내 팝업
                if vm.isShowingAlert {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    CameraPopup(
                        cancelButtonAction: {
                            vm.cancelAlert()
                        },
                        confirmButtonAction: {
                            vm.confirmAlert()
                        })
                    .padding(.horizontal, 20)
                }
                
                // 카메라 권한 요청 오버레이
                if vm.shouldShowPermissionDeniedView {
                    Color.black.opacity(0.8)
                        .ignoresSafeArea()
                    
                    CameraPermissionDeniedView(
                        onSettingsPressed: {
                            vm.openSettings()
                        },
                        onCancelPressed: {
                            vm.cancel()
                        }
                    )
                    .padding(.horizontal, 20)
                }
            }
            .foregroundColor(.gray0)
            .navigationBarHidden(true)
            .navigationDestination(for: AppRoute.self) { route in
                destinationView(for: route)
            }
            .onAppear {
                vm.showPopUp()
                vm.requestCameraPermission()
            }
            .onChange(of: scenePhase) { _, newPhase in
                // 앱이 포그라운드로 돌아올 때 권한 상태 재확인
                if newPhase == .active {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        vm.recheckPermissionOnForeground()
                    }
                }
            }
        }
    }
    
    // MARK: - 상단 툴바
    private var topToolbar: some View {
        HStack {
            Button {
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                vm.cancel()
            } label: {
                Image("arrow-back-gray0")
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .frame(height: 80) // 상단 영역 높이 고정
        .background(Color.black)
    }
    
    // MARK: - 카메라 프리뷰 영역 (커스터마이징 가능)
    private var cameraPreviewArea: some View {
        ZStack {
            // 카메라 프리뷰
            CameraViewController(cameraService: vm.cameraService)
                .frame(minHeight: 530)
                .clipped()
            
            // 오버레이 이미지
            if vm.isOverlayOn, let uiImage = vm.overlayImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minHeight: 530)
                    .opacity(0.5)
                    .clipped()
            }
        }
    }
    
    // MARK: - 하단 컨트롤
    private var bottomControls: some View {
        VStack(spacing: 0) {
            // 컨트롤 버튼들
            ZStack {
                // 촬영 버튼 - 항상 정중앙
                Button {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    vm.capturePhoto()
                } label: {
                    Circle()
                        .fill(vm.isLoading ? Color.gray : Color.green500)
                        .frame(width: 78, height: 78)
                        .overlay {
                            if vm.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Circle()
                                    .fill(Color.gray0)
                                    .frame(width: 64, height: 64)
                            }
                        }
                }
                .disabled(vm.isLoading)
                
                // 오버레이 토글 - 우측에 위치
                if vm.currentContext != .newProject {
                    HStack {
                        Spacer()
                        
                        VStack(alignment: .center, spacing: 9) {
                            Button {
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
                                .foregroundColor(.gray0)
                        }
                        .padding(.trailing, 24) // 우측 여백
                    }
                }
            }
            .padding(.top, 30)
            .padding(.bottom, 50) // Safe Area 고려
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.7),
                    Color.black
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .photoConfirm(let image, let context):
            PhotoConfirmView(vm: dependencies.makePhotoConfirmViewModel(image: image , context: context))
        case .saveNewProject(let image):
            NewProjectCategorySelectView(vm: dependencies.makeNewProjectCategorySelectViewModel(image: image))
        default:
            EmptyView()
        }
    }
}


// MARK: - CameraPermissionDeniedView
struct CameraPermissionDeniedView: View {
    let onSettingsPressed: () -> Void
    let onCancelPressed: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 24) {
                // 카메라 아이콘
                Image(systemName: "camera.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.gray400)
                
                VStack(spacing: 12) {
                    Text("카메라 접근 권한이 필요해요")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray0)
                    
                    Text("사진을 촬영하려면\n카메라 접근 권한을 허용해주세요")
                        .font(.body)
                        .foregroundColor(.gray300)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }
            }
            
            // 버튼들
            VStack(spacing: 12) {
                Button {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    onSettingsPressed()
                } label: {
                    HStack {
                        Spacer()
                        Text("설정으로 이동")
                            .font(.headline)
                            .foregroundColor(.gray0)
                        Spacer()
                    }
                    .frame(height: 56)
                    .background(Color.green500)
                    .cornerRadius(12)
                }
                
                Button {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    onCancelPressed()
                } label: {
                    HStack {
                        Spacer()
                        Text("취소")
                            .font(.headline)
                            .foregroundColor(.gray300)
                        Spacer()
                    }
                    .frame(height: 56)
                    .background(Color.gray600)
                    .cornerRadius(12)
                }
            }
        }
        .padding(32)
        .background(Color.black)
        .cornerRadius(16)
    }
}

#Preview {
    CameraView(vm: CameraViewModel(coordinator: AppCoordinator(), cameraService: CameraService(), context: .newProject))
}
