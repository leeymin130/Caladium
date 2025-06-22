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
    
    func cancel() {
        coordinator.dismissFullScreen()
    }
    
}
