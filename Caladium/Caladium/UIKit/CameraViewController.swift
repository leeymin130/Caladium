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
    
    func makeUIViewController(context: Context) -> UIViewController {
        return CameraPreviewViewController(cameraService: cameraService)
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // 필요시 업데이트 로직 추가
    }
}

class CameraPreviewViewController: UIViewController {
    private let cameraService: CameraService
    private var previewLayer: AVCaptureVideoPreviewLayer
    
    init(cameraService: CameraService) {
        self.cameraService = cameraService
        self.previewLayer = cameraService.previewLayer
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        view.layer.addSublayer(previewLayer)
        // 여기서는 videoGravity 설정하지 않음 (이미 CameraService에서 설정됨)
    }
    
    // 레이아웃 변경 시마다 프레임 업데이트
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        previewLayer.frame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.previewLayer.frame = self.view.bounds
        }
    }
}
