//
//  CameraViewModel.swift
//  Caladium
//
//  Created by yoomin on 6/9/25.
//

import SwiftUI
import Combine

final class CameraViewModel: ObservableObject {
    
    var coordinator: AppCoordinator
    let cameraService: CameraService
    
    @Published var isOverlayOn = false
    @Published var overlayImage: UIImage?
    @Published var isShowingAlert: Bool = true
    @Published var isLoading = false
    
    var currentContext: CameraContext
    private var cancellables = Set<AnyCancellable>()
    
    init(coordinator: AppCoordinator, cameraService: CameraService, context: CameraContext) {
        self.coordinator = coordinator
        self.cameraService = cameraService
        self.currentContext = context
        setupBindings()
    }
    
    private func setupBindings() {
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
    
    deinit {
        cameraService.stopSession()
        cancellables.removeAll()
    }
}
