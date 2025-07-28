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
    
    let project: Project
    let state: ProjectThumbnailState
    let action: () -> Void
    
    var stateColor: Color {
        switch state {
        case .active:
            return .gray0
        case .inactive:
            return .gray0
        case .selectedForMove:
            return .green500
        case .selectedForDelete:
            return .pink300
        }
    }
    
    var isSelected: Bool {
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
                    .fill(stateColor)
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: .gray900.opacity(0.25), radius: 1.5, x: 0, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.gray400, lineWidth: 1)
                    )
                
                // 이미지 있나요?
                // AsyncPhotoImage 또는 기본 아이콘
                Group {
                    if let latestPhoto = project.latestPhoto {
                        AsyncPhotoImage(photo: latestPhoto)
                            .frame(width: 90, height: 90)
                            .cornerRadius(7)
                            .clipped()
                    } else {
                        // 사진이 없을 때 기본 아이콘
                        Image(systemName: "leaf.fill")
                            .customFont(.categoryButtonTitle)
                            .foregroundColor(.green500)
                    }
                }
                
                // 선택 모드
                if isSelected{
                    ZStack {
                        Rectangle()
                            .foregroundStyle(Color.gray900.opacity(0.5))
                            .frame(width: 90, height: 90)
                            .cornerRadius(7)
                        VStack(spacing: 0){
                            Image("shovel")
                                .frame(width: 40, height: 40)
                            
                            Text("선택")
                                .customFont(.categoryButtonTitle)
                                .foregroundColor(.gray0)
                                .padding(4)
                        }
                        
                    }
                }
                
            }
            .frame(width: 100, height: 100)
            .cornerRadius(10)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        // 활성
        ProjectThumbnail(
            project: PreviewData.sampleProject,
            state: .active,
            action: { print("active") }
        )
        
        // 비활성
        ProjectThumbnail(
            project: PreviewData.sampleProject,
            state: .inactive,
            action: { print("inactive") }
        )
        
        // 이동 선택
        ProjectThumbnail(
            project: PreviewData.sampleProject,
            state: .selectedForMove,
            action: { print("selectedForMove") }
        )
        
        // 삭제 선택
        ProjectThumbnail(
            project: PreviewData.sampleProject,
            state: .selectedForDelete,
            action: { print("selectedForDelete") }
        )
    }
    .padding()
    .environment(\.managedObjectContext, CoreDataManager.preview.mainContext)
    .environment(\.dependencies, DependencyContainer.shared)
}

// MARK: - Preview Data Helper
struct PreviewData {
    static var sampleProject: Project {
        let context = CoreDataManager.preview.mainContext
        let project = Project(context: context, category: .garden)
        
        // Mock photo 추가 (선택사항)
        let photo = Photo(context: context, fileName: "preview", project: project)
        
        return project
    }
}
