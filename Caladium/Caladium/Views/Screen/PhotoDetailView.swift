//
//  PhotoDetailView.swift
//  Caladium
//
//  Created by 이종선 on 7/11/25.
//

import SwiftUI
import CoreData

struct PhotoDetailView: View {
    let project: Project
    
    @Environment(\.dismiss) private var dismiss
    @State private var currentPhoto: Photo
    @FetchRequest private var photos: FetchedResults<Photo>
    
    init(photo: Photo, project: Project) {
        self.project = project
        self._currentPhoto = State(initialValue: photo)
        self._photos = FetchRequest(
            entity: Photo.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Photo.capturedDate, ascending: true)],
            predicate: NSPredicate(format: "project == %@", project)
        )
    }

    var body: some View {
        ZStack(alignment: .leading) {
            Image("bg-picture")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 0){
                HStack {
                    Button {
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
                
                PhotoFrame(photo: currentPhoto)
                    .id(currentPhoto.objectID)
                    .padding(.top, 20)
                    .padding(.horizontal, 18)
                    .padding(.bottom, 51)
                
                thumbnailScrollView
                    .padding(.bottom, 32)
            }
            .ignoresSafeArea(.all)
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Thumbnail Scroll View
    private var thumbnailScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 3) {
                ForEach(photos, id: \.objectID) { photo in
                    thumbnailItem(photo: photo)
                }
            }
            .padding(.vertical, 14)
        }
        .background(
            Rectangle()
                .fill(Color.gray0)
                .shadow(color: .gray900.opacity(0.25), radius: 1.5, x: 0, y: 2)
                .border(Color.gray400, width: 1)
        )
        
        
    }
    
    // MARK: - Thumbnail Item
    private func thumbnailItem(photo: Photo) -> some View {
        Button {
            currentPhoto = photo
            
        } label: {
            if case .normal = thumbnailState(for: photo) {
                AsyncPhotoImage(photo: photo)
                    .clipShape(Rectangle())
                    .frame(width: 57, height: 77)
                
            } else if case .selected = thumbnailState(for: photo) {
                ZStack {
                    AsyncPhotoImage(photo: photo)
                        .clipShape(Rectangle())
                        .frame(width: 57, height: 77)
                    Rectangle()
                        .foregroundColor(.gray900.opacity(0.5))
                        .frame(width: 57, height: 77)
                    Text("now")
                        .customFont(.categoryButtonTitle)
                        .foregroundColor(.gray0)
                    
                }
            }
        }
    }
    
    // MARK: - Thumbnail State
    private func thumbnailState(for photo: Photo) -> PhotoThumbnailState {
        // 현재 선택된 사진은 selected 상태로 표시
        return photo.objectID == currentPhoto.objectID ? .selected : .normal
    }
    
    // MARK: - Current Photo Index
//    private var currentPhotoIndex: Int {
//        photos.firstIndex { $0.objectID == currentPhoto.objectID } ?? 0
//    }
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
    
    var mockPhotos: [Photo] = []
        for i in 1...5 {
            // Mock 사진 생성
            let mockPhoto = Photo(context: previewContext,
                                fileName: "sample\(i).jpg",
                                project: mockProject)
            mockPhoto.capturedDate = Date().addingTimeInterval(TimeInterval(i * 3600 * 24)) // 1시간씩 간격
            mockPhotos.append(mockPhoto)
        }
    
    // ✅ 컨텍스트에 저장
    do {
        try previewContext.save()
    } catch {
        print("Preview context save failed: \(error)")
    }
    
    // Mock coordinator (실제 구현에서는 적절한 coordinator 전달)
    let mockCoordinator = AppCoordinator()
    
    // 첫 번째 사진을 초기 사진으로 설정
    return PhotoDetailView(photo: mockPhotos[0], project: mockProject)
        .previewLayout(.sizeThatFits)
        .environment(\.managedObjectContext, previewContext) // ✅ 컨텍스트 환경 설정
}
