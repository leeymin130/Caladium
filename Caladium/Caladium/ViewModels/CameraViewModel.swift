//
//  CameraViewModel.swift
//  Caladium
//
//  Created by yoomin on 6/9/25.
//

import SwiftUI

final class CameraViewModel: ObservableObject {
    
    private let coordinator: AppCoordinator
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }
    
//    @Published var isFlashOn = false
    @Published var isOverlayOn = false
    
    func cancel() {
        print("취소")
        coordinator.dismissFullScreen()
    }
    
    func capturePhoto() {
        print("사진찍기")
    }
    
    func switchOverlay() {
        print("오버레이")
        isOverlayOn.toggle()
    }
    
}
