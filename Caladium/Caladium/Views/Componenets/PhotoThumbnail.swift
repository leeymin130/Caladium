//
//  PhotoThumbnail.swift
//  Caladium
//
//  Created by 이종선 on 7/13/25.
//

import SwiftUI

enum PhotoThumbnailState {
    case normal
    case selected
}

struct PhotoThumbnail: View {
    
    let photo: Photo
    let state: PhotoThumbnailState
    let size: CGFloat
    let action: () -> Void
    
    var isSelected: Bool {
        return state == .selected
    }
    
    var body: some View {
        Button(action: {
            // 햅틱 피드백 추가
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            action()
        }) {
            ZStack {
                Rectangle()
                    .foregroundColor(.gray0)
                    .frame(width: size, height: size)
                    .shadow(color: .gray900.opacity(0.25), radius: 1.5, x: 0, y: 2)
                
                AsyncPhotoImage(photo: photo)
                    .frame(width: size, height: size)
                    .clipped()
                
                // 선택 모드
                if isSelected{
                    ZStack {
                        Rectangle()
                            .foregroundStyle(Color.gray900.opacity(0.5))
                            .frame(width: size , height: size )
                            
                        VStack(spacing: 0){
                            Image("shovel")
                                .frame(width: size * 0.3, height: size * 0.3)
                            
                            Text("선택")
                                .customFont(.categoryButtonTitle)
                                .foregroundColor(.gray0)
                                .padding(6)
                        }
                        
                    }
                }
                
            }
            .frame(width: size, height: size)
        }
    }
}
