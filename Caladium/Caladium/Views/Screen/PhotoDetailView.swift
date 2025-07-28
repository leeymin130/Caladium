//
//  PhotoDetailView.swift
//  Caladium
//
//  Created by 이종선 on 7/11/25.
//

import SwiftUI

struct PhotoDetailView: View {
    let photo: Photo
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .leading) {
            Image("bg-picture")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 0){
                // 상단 툴바 영역
                HStack {
                    Button {
                        // 햅틱 피드백 추가
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        
                        dismiss()
                    } label: {
                        Image("arrow-back-green700")
                            .padding(.horizontal, 24)
                    }
                    
                    Spacer()
                }
                .frame(height: 68)
                .padding(.top, 54)
                
                PhotoFrame(photo: photo)
                    .padding(.top, 20)
                    .padding(.horizontal, 18)
                
                Spacer()
            }
            .ignoresSafeArea(.all)
            .navigationBarHidden(true)
        }
        
    }
}

#Preview {
    // Preview를 위한 임시 컨텍스트 생성
    let previewContext = CoreDataManager.shared.mainContext
    
    // Mock 프로젝트 생성 (Category enum이 필요하므로 기본값 사용)
    let mockProject = Project(context: previewContext)
    mockProject.id = UUID()
    mockProject.category = "garden" // Category의 기본값으로 가정
    mockProject.createdDate = Date()
    mockProject.updatedDate = Date()
    
    // Mock 사진 생성
    let mockPhoto = Photo(context: previewContext,
                         fileName: "sample.jpg",
                         project: mockProject)
    
    return PhotoDetailView(photo: mockPhoto)
        .previewLayout(.sizeThatFits)
}


