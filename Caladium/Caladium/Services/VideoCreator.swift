//
//  VideoCreator.swift
//  Caladium
//
//  Created by 이종선 on 7/3/25.
//

import AVKit

class VideoCreator {
    static func createVideo(from images: [UIImage], outputURL: URL, duration: Double, completion: @escaping (Bool) -> Void) {
        guard !images.isEmpty else {
            completion(false)
            return
        }
        
        // ✅ 모든 이미지의 방향을 먼저 수정
        let fixedImages = images.map { $0.fixedOrientation() }
        
        // 기존 파일이 있다면 삭제
        if FileManager.default.fileExists(atPath: outputURL.path) {
            try? FileManager.default.removeItem(at: outputURL)
        }
        
        let videoWriter: AVAssetWriter
        do {
            videoWriter = try AVAssetWriter(outputURL: outputURL, fileType: .mov)
        } catch {
            print("VideoWriter 생성 실패: \(error)")
            completion(false)
            return
        }
        
        // ✅ 방향이 수정된 첫 번째 이미지의 크기를 기준으로 비디오 설정
        let firstImage = fixedImages[0]
        let videoSize = firstImage.size
        
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: Int(videoSize.width),
            AVVideoHeightKey: Int(videoSize.height)
        ]
        
        let videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        videoWriterInput.expectsMediaDataInRealTime = false
        
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: videoWriterInput,
            sourcePixelBufferAttributes: [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
                kCVPixelBufferWidthKey as String: Int(videoSize.width),
                kCVPixelBufferHeightKey as String: Int(videoSize.height)
            ]
        )
        
        guard videoWriter.canAdd(videoWriterInput) else {
            print("VideoWriterInput을 추가할 수 없습니다")
            completion(false)
            return
        }
        
        videoWriter.add(videoWriterInput)
        
        videoWriter.startWriting()
        videoWriter.startSession(atSourceTime: .zero)
        
        let frameDuration = CMTime(seconds: duration / Double(fixedImages.count), preferredTimescale: 600)
        var frameCount = 0
        
        let serialQueue = DispatchQueue(label: "videoWriterQueue")
        
        videoWriterInput.requestMediaDataWhenReady(on: serialQueue) {
            while videoWriterInput.isReadyForMoreMediaData && frameCount < fixedImages.count {
                let presentationTime = CMTimeMultiply(frameDuration, multiplier: Int32(frameCount))
                
                // ✅ 방향이 수정된 이미지들 사용
                if let pixelBuffer = self.pixelBuffer(from: fixedImages[frameCount], size: videoSize) {
                    if !pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime) {
                        print("PixelBuffer 추가 실패")
                        break
                    }
                }
                
                frameCount += 1
            }
            
            if frameCount >= fixedImages.count {
                videoWriterInput.markAsFinished()
                videoWriter.finishWriting {
                    DispatchQueue.main.async {
                        completion(videoWriter.status == .completed)
                        if videoWriter.status != .completed {
                            print("비디오 작성 실패: \(String(describing: videoWriter.error))")
                        }
                    }
                }
            }
        }
    }
    
    private static func pixelBuffer(from image: UIImage, size: CGSize) -> CVPixelBuffer? {
        let attributes = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue!,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue!
        ] as CFDictionary
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(size.width),
            Int(size.height),
            kCVPixelFormatType_32ARGB,
            attributes,
            &pixelBuffer
        )
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            print("PixelBuffer 생성 실패")
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: pixelData,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )
        
        guard let cgContext = context else {
            CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
            return nil
        }
        
        // 배경을 흰색으로 채우기
        cgContext.setFillColor(UIColor.white.cgColor)
        cgContext.fill(CGRect(origin: .zero, size: size))
        
        // ✅ 이미지는 이미 방향이 수정되었으므로 그대로 그리기
        if let cgImage = image.cgImage {
            // 이미지를 적절한 크기로 조정하여 그리기 (aspect ratio 유지)
            let aspectRatio = image.size.width / image.size.height
            let targetAspectRatio = size.width / size.height
            
            var drawRect: CGRect
            if aspectRatio > targetAspectRatio {
                // 이미지가 더 넓음 - 높이에 맞춤
                let drawWidth = size.height * aspectRatio
                drawRect = CGRect(x: (size.width - drawWidth) / 2, y: 0, width: drawWidth, height: size.height)
            } else {
                // 이미지가 더 높음 - 너비에 맞춤
                let drawHeight = size.width / aspectRatio
                drawRect = CGRect(x: 0, y: (size.height - drawHeight) / 2, width: size.width, height: drawHeight)
            }
            
            cgContext.draw(cgImage, in: drawRect)
        }
        
        CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
}
