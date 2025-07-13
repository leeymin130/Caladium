//
//  CameraService.swift
//  Caladium
//
//  Created by yoomin on 6/9/25.
//

import AVFoundation

class CameraService {
    
    private let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    
    // Preview Layer 생성
    var previewLayer: AVCaptureVideoPreviewLayer {
        return AVCaptureVideoPreviewLayer(session: captureSession)
    }
    
    
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
    
    // 카메라 셋업 - 1.Input 2.Output 3.Preview
    func setupCamera() {
        captureSession.beginConfiguration() // 설정 시작
        
        // Input 설정
        // 후면 카메라 찾기
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            return
        }
        
        // 카메라를 입력으로 변환
        guard let input = try? AVCaptureDeviceInput(device: camera) else {
            return
        }
        
        // 세션에 입력 추가
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        // Output 설정
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        captureSession.commitConfiguration() // 설정종료
        
        // Preview Layer는 프로퍼티로 제공
    }
    
}
