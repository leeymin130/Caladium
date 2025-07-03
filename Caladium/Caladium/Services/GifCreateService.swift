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
        
        let gifData = NSMutableData()
        let destination = CGImageDestinationCreateWithData(gifData, UTType.gif.identifier as CFString, images.count, nil)
        
        guard let cgImageDestination = destination else { return nil }
        
        // GIF 속성 설정 ( loopCount: 0이면 무한반복, 양수면 해당 횟수만큼 반복 )
        let gifProperties = [
            kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFLoopCount: loopCount
            ]
        ]
        CGImageDestinationSetProperties(cgImageDestination, gifProperties as CFDictionary)
        
        // 각 프레임 추가
        let frameDuration = duration / Double(images.count)
        let frameProperties = [
            kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFDelayTime: frameDuration
            ]
        ]
        
        for image in images {
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
