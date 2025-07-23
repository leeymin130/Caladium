//
//  CameraViewController.swift
//  Caladium
//
//  Created by yoomin on 6/9/25.
//

import AVFoundation
import UIKit
import SwiftUI

struct CameraViewController: UIViewControllerRepresentable {
    let cameraService: CameraService
    
    // UIViewController 생성 및 previewLayer 추가
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        // CameraService에서 previewLayer 가져오기
        let previewLayer = cameraService.previewLayer
        
        // viewController의 view에 previewLayer 추가
        viewController.view.layer.addSublayer(previewLayer)
        
        // 화면 전체에 맞춰 프레임 설정
        previewLayer.frame = viewController.view.bounds
        
        return viewController
    }
    
    // UIViewController 업데이트
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // SwiftUI 상태 변경 시 호출
        cameraService.previewLayer.frame = uiViewController.view.bounds
    }
    
}
