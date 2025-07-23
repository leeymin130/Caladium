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
    
    private var currentContext: CameraContext?
    private var cancellables = Set<AnyCancellable>()
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        
        // CameraService의 capturedImage 변경 감지
        cameraService.$capturedImage
            .compactMap { $0 } // nil이 아닌 값만 통과
            .sink { [weak self] image in
                print("📸 ViewModel: 새로운 이미지 수신됨")
                self?.handleCapturedImage(image)
            }
            .store(in: &cancellables)
    }
    
    func setContext(_ context: CameraContext) {
        print("🔥 setContext 호출됨: \(context)")
        self.currentContext = context
    }
    
    
    func cancel() {
        print("취소")
        coordinator.dismissFullScreen()
    }
    
    func capturePhoto() {
        print("촬영")
        cameraService.capturePhoto()
    }
    
    func handleCapturedImage(_ image: UIImage) {
        print("이미지 처리 시작")
        self.overlayImage = image
        
//        if let context = currentContext {
//            print("네비게이션 실행")
//            coordinator.presentFullScreen(.photoConfirm(image, context))
//        } else {
//            print("context가 nil")
//        }
    }
    
    func switchOverlay() {
        print("오버레이")
        isOverlayOn.toggle()
    }
    
}
