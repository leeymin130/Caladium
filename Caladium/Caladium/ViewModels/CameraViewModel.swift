//
//  CameraViewModel.swift
//  Caladium
//
//  Created by yoomin on 6/9/25.
//

import SwiftUI
import Combine
import AVFoundation

final class CameraViewModel: ObservableObject {
    
    var coordinator: AppCoordinator
    let cameraService: CameraService
    
    @Published var isOverlayOn = false
    @Published var overlayImage: UIImage?
    @Published var isShowingAlert: Bool = true
    @Published var isLoading = false
    
    var currentContext: CameraContext
    private var cancellables = Set<AnyCancellable>()
    
    init(coordinator: AppCoordinator, cameraService: CameraService, context: CameraContext, latestPhoto: Photo? = nil) {
        self.coordinator = coordinator
        self.cameraService = cameraService
        self.currentContext = context
        
        // 기존 프로젝트에서 촬영할 때 최신 사진을 오버레이로 설정
        if case .existingProject = context, let photo = latestPhoto {
            setupOverlayImage(from: photo)
            self.isOverlayOn = true  // 자동으로 오버레이 켜기
        }
        
        setupBindings()
    }
    
    private func setupOverlayImage(from photo: Photo) {
        guard let fileURL = photo.getFileURL(),
              let imageData = try? Data(contentsOf: fileURL),
              let image = UIImage(data: imageData) else {
            return
        }
        self.overlayImage = image
    }
    
    private func setupBindings() {
        cancellables.removeAll()
        cameraService.capturedImageSubject
            .sink { [weak self] image in
                self?.handleCapturedImage(image)
            }
            .store(in: &cancellables)
    }
    
    func setContext(_ context: CameraContext) {
        self.currentContext = context
    }
    
    func cancel() {
        cameraService.stopSession()
        coordinator.dismissFullScreen()
    }
    
    func capturePhoto() {
        guard !isLoading else { return }
        
        isLoading = true
        cameraService.capturePhoto()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.isLoading = false
        }
    }
    
    private func handleCapturedImage(_ image: UIImage) {
        isLoading = false
        coordinator.pushToPhotoConfirm(image, context: currentContext)
    }
    
    func switchOverlay() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isOverlayOn.toggle()
        }
    }
    
    func confirmAlert() {
        isShowingAlert = false
    }
    
    func cancelAlert() {
        isShowingAlert = false
        coordinator.dismissFullScreen()
    }
    
    // MARK: - 권한 관련 메서드
    func requestCameraPermission() {
        cameraService.requestCameraPermission()
    }
    
    func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        UIApplication.shared.open(settingsUrl)
    }
    
    func recheckPermissionOnForeground() {
        cameraService.recheckPermission()
    }
    
    // 권한 상태에 따른 UI 표시 여부 - 권한 거부시에만 오버레이 표시
    var shouldShowPermissionDeniedView: Bool {
        return cameraService.permissionStatus == .denied || cameraService.permissionStatus == .restricted
    }
    
    deinit {
        cameraService.stopSession()
        cancellables.removeAll()
    }
}
