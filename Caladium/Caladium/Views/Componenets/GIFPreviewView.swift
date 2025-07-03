//
//  GIFPreviewView.swift
//  Caladium
//
//  Created by 이종선 on 7/2/25.
//

import SwiftUI

struct GIFPreviewView: UIViewRepresentable {
    let gifData: Data
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // GIF 데이터로부터 애니메이션 이미지 생성
        if let source = CGImageSourceCreateWithData(gifData as CFData, nil) {
            let count = CGImageSourceGetCount(source)
            var images: [UIImage] = []
            var totalDuration: Double = 0
            
            for i in 0..<count {
                if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                    let image = UIImage(cgImage: cgImage)
                    images.append(image)
                    
                    // 프레임 지속시간 가져오기
                    if let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any],
                       let gifInfo = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any],
                       let delayTime = gifInfo[kCGImagePropertyGIFDelayTime as String] as? Double {
                        totalDuration += delayTime
                    }
                }
            }
            
            if !images.isEmpty {
                imageView.animationImages = images
                imageView.animationDuration = totalDuration
                imageView.animationRepeatCount = 0 // 무한 반복
                imageView.startAnimating()
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // 업데이트 로직이 필요한 경우
    }
}
