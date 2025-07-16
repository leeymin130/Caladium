//
//  PhotoFrame.swift
//  Caladium
//
//  Created by yoomin on 6/25/25.
//

import SwiftUI

struct PhotoFrame: View {
    let photo: Photo?
        let previewImage: UIImage?
    @State private var loadedImage: UIImage?
    @State private var isImageLoading = true
    
    // CoreDataService 인스턴스
    private let coreDataService = CoreDataService()
    
    // 날짜 포맷터
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
    
    // 기존 Photo 이니셜라이저
    init(photo: Photo) {
        self.photo = photo
        self.previewImage = nil
    }
    
    // UIImage용 이니셜라이저
    init(image: UIImage) {
        self.photo = nil
        self.previewImage = image
    }

    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 사진 표시 영역
            photoImageView
                .cornerRadius(5)
            
            // 사진 촬영 날짜
            Text(formatDate(photo?.capturedDate ?? Date()))
                .fontWeight(.semibold)
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
        .onAppear {
            loadImage()
        }
    }
    
    // MARK: - Views
    
    @ViewBuilder
    private var photoImageView: some View {
        if isImageLoading {
            // 로딩 상태
            Rectangle()
                .foregroundColor(.gray200)
                .frame(width: 321, height: 423)
                .overlay(
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .gray600))
                )
        } else if let image = loadedImage {
            // 이미지 로드 성공
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 321, height: 423)
                .clipped()
        } else {
            // 이미지 로드 실패 - 플레이스홀더
            Rectangle()
                .foregroundColor(.gray300)
                .frame(width: 321, height: 423)
                .overlay(
                    VStack(spacing: 8) {
                        Image(systemName: "photo")
                            .font(.system(size: 50))
                            .foregroundColor(.gray600)
                        Text("이미지를 불러올 수 없습니다")
                            .font(.caption)
                            .foregroundColor(.gray600)
                    }
                )
        }
    }
    
    // MARK: - Methods
    
    /// 이미지 비동기 로딩
    private func loadImage() {
           guard let photo = photo,
                 let fileName = photo.fileName else {
               self.isImageLoading = false
               return
           }
        
        // 백그라운드에서 이미지 로딩
        DispatchQueue.global(qos: .userInitiated).async {
            let image = coreDataService.loadImageFromFile(fileName: fileName)
            
            DispatchQueue.main.async {
                self.loadedImage = image
                self.isImageLoading = false
            }
        }
    }
    
    /// 날짜 포맷 함수
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else {
            return "날짜 정보 없음"
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
