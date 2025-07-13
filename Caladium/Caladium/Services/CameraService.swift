//
//  CameraService.swift
//  Caladium
//
//  Created by yoomin on 6/9/25.
//

import Foundation
import AVFoundation
import UIKit

class CameraService {
    @Published var permissionGranted = false
    
    // 카메라 권한 요청 및 확인 로직
    func requestCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        if status == .authorized {
            // 이미 권한 있음
            DispatchQueue.main.async {
                self.permissionGranted = true
            }
        } else {
            // 권한 없음 → 요청
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.permissionGranted = granted
                }
            }
        }
    }
    
}
