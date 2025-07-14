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
    }
    
    func switchOverlay() {
        print("오버레이")
        isOverlayOn.toggle()
    }
    
}
