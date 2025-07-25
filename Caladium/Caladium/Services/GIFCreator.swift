//
//  GifCreateService.swift
//  Caladium
//
//  Created by 이종선 on 7/2/25.
//

import SwiftUI
import ImageIO
import UniformTypeIdentifiers

// MARK: - GIF Creator
class GIFCreator {
    static func createGIF(from images: [UIImage], duration: Double, loopCount: Int = 0) -> Data? {
        guard !images.isEmpty else { return nil }
        
        // ✅ 모든 이미지의 방향을 먼저 수정
        let fixedImages = images.map { $0.fixedOrientation() }
        
        let gifData = NSMutableData()
        let destination = CGImageDestinationCreateWithData(gifData, UTType.gif.identifier as CFString, fixedImages.count, nil)
        
        guard let cgImageDestination = destination else { return nil }
        
        // GIF 속성 설정 ( loopCount: 0이면 무한반복, 양수면 해당 횟수만큼 반복 )
        let gifProperties = [
            kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFLoopCount: loopCount
            ]
        ]
        CGImageDestinationSetProperties(cgImageDestination, gifProperties as CFDictionary)
        
        // 각 프레임 추가
        let frameDuration = duration / Double(fixedImages.count)
        let frameProperties = [
            kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFDelayTime: frameDuration
            ]
        ]
        
        // ✅ 방향이 수정된 이미지들 사용
        for image in fixedImages {
            if let cgImage = image.cgImage {
                CGImageDestinationAddImage(cgImageDestination, cgImage, frameProperties as CFDictionary)
            }
        }
        
        if CGImageDestinationFinalize(cgImageDestination) {
            return gifData as Data
        }
        
        return nil
    }
}
