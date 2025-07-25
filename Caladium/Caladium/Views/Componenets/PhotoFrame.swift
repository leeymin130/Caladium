//
//  PhotoFrame.swift
//  Caladium
//
//  Created by yoomin on 6/25/25.
//

import SwiftUI

struct PhotoFrame: View {
    let photo: Photo
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale.current // 시스템 현재 언어 설정 사용
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 사진 표시 영역
            AsyncPhotoImage(photo: photo, ContentMode: .fit)
                .cornerRadius(5)
                .frame(maxWidth: 320, maxHeight: 420)
            
            // 사진 촬영 날짜
            Text(formatDate(photo.capturedDate))
                .customFont(.photoDate)
                .foregroundColor(.gray900)
        }
        .padding(.horizontal, 18)
        .padding(.top, 18)
        .padding(.bottom, 48)
        .background(.gray0)
        .cornerRadius(14)
        .shadow(color: .gray900.opacity(0.25), radius: 2, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .inset(by: 0.5)
                .stroke(Color.gray400, lineWidth: 1)
        )
        
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else {
            return NSLocalizedString("date_info_unavailable", value: "날짜 정보 없음", comment: "날짜 정보가 없을 때 표시되는 메시지")
        }
        return dateFormatter.string(from: date)
    }
}

// MARK: - Preview

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
    
    return PhotoFrame(photo: mockPhoto)
        .previewLayout(.sizeThatFits)
        .padding()
}
