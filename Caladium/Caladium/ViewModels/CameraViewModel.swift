//
//  CameraViewModel.swift
//  Caladium
//
//  Created by yoomin on 6/9/25.
//

import SwiftUI

final class CameraViewModel: ObservableObject {
    
    private let coordinator: AppCoordinator
    let cameraService = CameraService()
    
    @Published var isOverlayOn = false
    @Published var overlayImage: UIImage?
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }
    
    func cancel() {
        print("취소")
        coordinator.dismissFullScreen()
    }
    
    func capturePhoto() {
        print("촬영")
        cameraService.capturePhoto()
        
        // 사진 촬영 -> cameraService.capturedImage에 값이 할당 -> overlayImage에 저장
        if let image = cameraService.capturedImage {
            self.overlayImage = image
        }
    }
    
    func switchOverlay() {
        print("오버레이")
        isOverlayOn.toggle()
    }
    
}
