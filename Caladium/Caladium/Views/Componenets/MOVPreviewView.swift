//
//  MOVPreviewView.swift
//  Caladium
//
//  Created by 이종선 on 7/3/25.
//

import SwiftUI
import AVKit

struct MOVPreviewView: UIViewRepresentable {
    let videoURL: URL
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        // AVPlayer 설정
        let player = AVPlayer(url: videoURL)
        let playerLayer = AVPlayerLayer(player: player)
        
        playerLayer.videoGravity = .resizeAspect
        view.layer.addSublayer(playerLayer)
        
        // 무한 반복 설정
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            player.seek(to: .zero)
            player.play()
        }
        
        // 자동 재생 시작
        player.play()
        
        // 레이어 크기 조정을 위한 레이아웃 콜백
        DispatchQueue.main.async {
            playerLayer.frame = view.bounds
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let playerLayer = uiView.layer.sublayers?.first as? AVPlayerLayer {
            playerLayer.frame = uiView.bounds
        }
    }
}
