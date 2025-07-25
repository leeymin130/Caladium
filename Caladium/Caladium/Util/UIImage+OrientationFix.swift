//
//  UIImage+OrientationFix.swift
//  Caladium
//
//  이미지 방향 문제 해결을 위한 Extension
//

import UIKit

extension UIImage {
    
    /// 이미지의 방향을 올바르게 수정하여 반환
    func fixedOrientation() -> UIImage {
        // 이미 올바른 방향이면 그대로 반환
        if imageOrientation == .up {
            return self
        }
        
        // 더 간단하고 확실한 방법 사용
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage ?? self
    }
    
    /// 이미지를 정사각형으로 크롭 (중앙 기준)
    func cropToSquare() -> UIImage {
        let originalSize = self.size
        let sideLength = min(originalSize.width, originalSize.height)
        
        let cropRect = CGRect(
            x: (originalSize.width - sideLength) / 2,
            y: (originalSize.height - sideLength) / 2,
            width: sideLength,
            height: sideLength
        )
        
        guard let cgImage = self.cgImage?.cropping(to: cropRect) else { return self }
        return UIImage(cgImage: cgImage, scale: self.scale, orientation: self.imageOrientation)
    }
    
    /// 지정된 크기로 리사이즈
    func resized(to targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
