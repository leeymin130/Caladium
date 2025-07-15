//
//  CameraService.swift
//  Caladium
//
//  Created by yoomin on 6/9/25.
//

import AVFoundation
import SwiftUI

class CameraService: NSObject, ObservableObject {
    
    private let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    
    // Preview Layer 생성
    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.videoGravity = .resizeAspectFill  // 설정 한 번만
        return layer
    }()
    // 첫 번째 호출 시에만 생성, 이후엔 같은 객체 재사용
    
    
    @Published var capturedImage: UIImage?
    @Published var permissionGranted = false
    
    // 카메라 권한 요청 및 확인 로직
    func requestCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        if status == .authorized {
            // 이미 권한 있음
            DispatchQueue.main.async {
                self.permissionGranted = true
                self.setupCamera()
            }
        } else {
            // 권한 없음 → 요청
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.permissionGranted = granted
                    if granted {
                        self.setupCamera()
                    }
                }
            }
        }
    }
    
    // 카메라 셋업 - 1.Input 2.Output 3.Preview
    func setupCamera() {
        print("🎬 setupCamera 호출됨")
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
        
        // 세션 시작하기
        captureSession.startRunning()
    }
    
    // 사진 촬영 메서드 - 카메라 버튼을 눌렀을때 실행되는 함수
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)  // 비동기
    }

    // 촬영된 사진 처리
    private func handleCapturedPhoto(_ image: UIImage) {
        DispatchQueue.main.async {
            self.capturedImage = image
        }
    }
    
    
}

// Photo Capture Delegate 구현
extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if let error = error {
            print("사진 촬영 오류: \(error)")
            return
        }
        
        // 사진 데이터 추출
        guard let imageData = photo.fileDataRepresentation(),
              let uiImage = UIImage(data: imageData) else {
            print("이미지 데이터 변환 실패")
            return
        }
        
        print("📸 사진 촬영 성공!")
        
        // 촬영된 이미지 처리
        handleCapturedPhoto(uiImage)
    }
}
