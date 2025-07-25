//
//  CameraViewModel.swift
//  Caladium
//
//  Created by yoomin on 6/9/25.
//

import SwiftUI
import Combine

final class CameraViewModel: ObservableObject {
    
    private let coordinator: AppCoordinator
    let cameraService = CameraService()
    
    @Published var isOverlayOn = false
    @Published var overlayImage: UIImage?
    @Published var isShowingAlert: Bool = false  
    @Published var isLoading = false
    
    private var currentContext: CameraContext?
    private var cancellables = Set<AnyCancellable>()
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        setupBindings()
    }
    
    private func setupBindings() {
        cameraService.$capturedImage
            .compactMap { $0 }
            .sink { [weak self] image in
                self?.handleCapturedImage(image)
            }
            .store(in: &cancellables)
        
        cameraService.$permissionGranted
            .sink { [weak self] granted in
                if !granted {
                    self?.isShowingAlert = true
                }
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
        }
    }
    
    private func handleCapturedImage(_ image: UIImage) {
        isLoading = false
        
        guard let context = currentContext else { return }
        coordinator.pushToPhotoConfirm(image, context: context)
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
    }
}
