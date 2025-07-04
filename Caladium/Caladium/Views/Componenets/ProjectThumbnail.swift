//
//  ProjectThumbnail.swift
//  Caladium
//
//  Created by yoomin on 6/26/25.
//

import SwiftUI

enum ProjectThumbnailState {
    case active
    case inactive
    case selectedForMove
    case selectedForDelete
}

struct ProjectThumbnail: View {
    //    let photo: Photo
    
    let state: ProjectThumbnailState
    let thumbnailImage: Image?
    let action: () -> Void
    
    var stateColor: Color {
        switch state {
        case .active:
            return .gray0
        case .inactive:
            return .gray300
        case .selectedForMove:
            return .green500
        case .selectedForDelete:
            return .pink300
        }
    }
    
    var selectedMode: Bool {
        switch state {
        case .selectedForMove, .selectedForDelete:
            return true
        default:
            return false
        }
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
                    .foregroundColor(stateColor)
                    .frame(width: 100, height: 100)
                    .shadow(color: .gray900.opacity(0.25), radius: 1.5, x: 0, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray400, lineWidth: 1)
                    )
                
                // 이미지 있나요?
                if let image = thumbnailImage {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 90, height: 90)
                        .cornerRadius(7)
                        .clipped()
                        .overlay(
                            RoundedRectangle(cornerRadius: 7)
                                .stroke(Color.gray0.opacity(0.25), lineWidth: 1)
                        )
                }
                
                // 선택 모드
                if state == .inactive || selectedMode {
                    ZStack {
                        Rectangle()
                            .foregroundStyle(Color.gray900.opacity(0.5))
                            .frame(width: 90, height: 90)
                            .cornerRadius(7)
                        
                        if selectedMode {
                            VStack(spacing: 0){
                                Image("shovel")
                                    .frame(width: 40, height: 40)
                                
                                Text("선택")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(6)
                                    .cornerRadius(8)
                            }
                            
                        }
                    }
                    
                }
                
            }
            .frame(width: 100, height: 100)
            .cornerRadius(10)
            
        }
        .disabled(state == .inactive)
    }
}

#Preview {
    VStack(spacing: 20) {
        // 활성
        ProjectThumbnail(
            state: .active, thumbnailImage: Image("preview"), action:      { print("active") }
        )
        // 비활성
        ProjectThumbnail(
            state: .inactive, thumbnailImage: Image("preview"), action:      { print("inactive") }
        )
        // 삭제 선택
        ProjectThumbnail(
            state: .selectedForMove, thumbnailImage: Image("preview"), action:      { print("selectedForMove") }
        )
        // 이동 선택
        ProjectThumbnail(
            state: .selectedForDelete, thumbnailImage: Image("preview"), action:      { print("selectedForDelete") }
        )
        
    }
    .padding()
    
}
