//
//  CameraService.swift
//  Caladium
//
//  Created by yoomin on 6/9/25.
//

import AVFoundation
import SwiftUI
import Combine

class CameraService: NSObject, ObservableObject {
    
    private let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    
    // Preview Layer 생성
    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.videoGravity = .resizeAspectFill
        return layer
    }()
    
    @Published var permissionGranted = false
    @Published var permissionStatus: AVAuthorizationStatus = .notDetermined
    @Published var isSessionRunning = false
    let capturedImageSubject = PassthroughSubject<UIImage, Never>()

    // 세션 정리용 큐
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    override init() {
        super.init()
        // 초기 권한 상태 설정
        permissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
        permissionGranted = (permissionStatus == .authorized)
        setupNotifications()
    }
    
    // MARK: - 생명주기 관리
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillTerminate),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
    }
    
    @objc private func appDidEnterBackground() {
        print("📱 앱이 백그라운드로 이동")
        stopSessionSafely()
    }
    
    @objc private func appWillTerminate() {
        print("📱 앱 종료 시작")
        stopSessionSafely()
    }
    
    @objc private func appWillEnterForeground() {
        print("📱 포그라운드 복귀 - 권한 및 카메라 상태 확인")
        
        // 포그라운드 복귀 시 권한 상태 재확인
        let currentStatus = AVCaptureDevice.authorizationStatus(for: .video)
        DispatchQueue.main.async {
            self.permissionStatus = currentStatus
            self.permissionGranted = (currentStatus == .authorized)
        }
        
        if permissionGranted {
            sessionQueue.async { [weak self] in
                guard let self = self else { return }
                
                if !self.captureSession.isRunning {
                    self.captureSession.startRunning()
                    
                    DispatchQueue.main.async {
                        self.isSessionRunning = true
                        print("✅ 포그라운드 복귀 후 세션 재시작됨")
                    }
                }
            }
        }
    }
    
    // 카메라 권한 요청 및 확인 로직
    func requestCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        DispatchQueue.main.async {
            self.permissionStatus = status
        }
        
        switch status {
        case .authorized:
            DispatchQueue.main.async {
                self.permissionGranted = true
                self.setupCamera()
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.permissionStatus = granted ? .authorized : .denied
                    self.permissionGranted = granted
                    if granted {
                        self.setupCamera()
                    } else {
                        print("❌ 카메라 권한이 거부되었습니다")
                    }
                }
            }
        case .denied:
            DispatchQueue.main.async {
                self.permissionGranted = false
                print("❌ 카메라 권한이 거부된 상태입니다")
            }
        case .restricted:
            DispatchQueue.main.async {
                self.permissionGranted = false
                print("❌ 카메라 접근이 제한된 상태입니다")
            }
        @unknown default:
            DispatchQueue.main.async {
                self.permissionGranted = false
                print("❌ 알 수 없는 권한 상태입니다")
            }
        }
    }
    
    // 권한 상태 재확인 (설정에서 돌아올 때 사용)
    func recheckPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        DispatchQueue.main.async {
            self.permissionStatus = status
            self.permissionGranted = (status == .authorized)
            
            if self.permissionGranted {
                self.setupCamera()
            }
        }
    }
    
    // 카메라 셋업
    func setupCamera() {
        guard permissionGranted else {
            print("❌ 카메라 권한이 없어 셋업할 수 없습니다")
            return
        }
        
        guard !isSessionRunning else { return }
        
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.captureSession.beginConfiguration()
            
            if self.captureSession.canSetSessionPreset(.photo) {
                self.captureSession.sessionPreset = .photo
            }
            
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let input = try? AVCaptureDeviceInput(device: camera) else {
                self.captureSession.commitConfiguration()
                print("❌ 카메라 디바이스를 설정할 수 없습니다")
                return
            }
            
            self.captureSession.inputs.forEach { self.captureSession.removeInput($0) }
            if self.captureSession.canAddInput(input) {
                self.captureSession.addInput(input)
            }
            
            self.captureSession.outputs.forEach { self.captureSession.removeOutput($0) }
            if self.captureSession.canAddOutput(self.photoOutput) {
                self.captureSession.addOutput(self.photoOutput)
            }
            
            self.captureSession.commitConfiguration()
            
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
                
                DispatchQueue.main.async {
                    self.isSessionRunning = true
                    print("✅ 카메라 세션 시작됨")
                }
            }
        }
    }
    
    // 사진 촬영 메서드
    func capturePhoto() {
        guard isSessionRunning && permissionGranted else {
            print("❌ 카메라가 준비되지 않음 (권한: \(permissionGranted), 세션: \(isSessionRunning))")
            return
        }
        
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            let settings = AVCapturePhotoSettings()
            
            // 메인 스레드에서 delegate 호출 보장
            DispatchQueue.main.async {
                self.photoOutput.capturePhoto(with: settings, delegate: self)
            }
        }
    }
    
    // 촬영된 사진 처리
    private func handleCapturedPhoto(_ image: UIImage) {
        DispatchQueue.main.async {
            self.capturedImageSubject.send(image)
        }
    }
    
    // MARK: - 안전한 세션 관리
    private func startSession() {
        if !captureSession.isRunning {
            captureSession.startRunning()
            
            DispatchQueue.main.async {
                self.isSessionRunning = true
                print("✅ 카메라 세션 시작됨")
            }
        }
    }
    
    // 일반적인 세션 정지 (UI에서 호출)
    func stopSession() {
        print("🛑 세션 정지 요청됨")
        stopSessionSafely()
    }
    
    // 안전한 세션 정지 (내부적으로 사용)
    private func stopSessionSafely() {
        guard isSessionRunning else { return }
        
        // 상태를 먼저 false로 설정하여 중복 호출 방지
        DispatchQueue.main.async {
            self.isSessionRunning = false
        }
        
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            // 세션이 실제로 실행 중인지 다시 확인
            if self.captureSession.isRunning {
                print("📹 카메라 세션 중지 중...")
                self.captureSession.stopRunning()
                print("✅ 카메라 세션 중지 완료")
            }
        }
    }
    
    // 즉시 세션 정지 (앱 종료 시)
    private func stopSessionImmediately() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
        isSessionRunning = false
        print("⚡ 카메라 세션 즉시 정지됨")
    }
    
    // ✅ 가장 안전한 deinit 구현
    deinit {
        print("🗑️ CameraService deinit 시작")
        
        // 1. 상태 플래그 먼저 false로 설정
        isSessionRunning = false
        
        // 2. Notification Observer 제거 (중요!)
        NotificationCenter.default.removeObserver(self)
        
        // 3. 세션이 실행 중이면 즉시 정지 (동기적으로)
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
        
        // 4. 입력/출력 정리
        captureSession.inputs.forEach { captureSession.removeInput($0) }
        captureSession.outputs.forEach { captureSession.removeOutput($0) }
        
        print("✅ CameraService deinit 완료")
    }
}

// MARK: - Photo Capture Delegate
extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if let error = error {
            print("❌ 사진 촬영 오류: \(error)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let uiImage = UIImage(data: imageData) else {
            print("❌ 이미지 데이터 변환 실패")
            return
        }
        
        // ✅ 방향 정보를 고려한 이미지 정규화
        let orientationFixedImage = uiImage.fixedOrientation()
        
        print("✅ 사진 촬영 성공! (방향 수정 완료)")
        handleCapturedPhoto(orientationFixedImage)
    }
}
