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
    
    @State private var currentPhotoIndex: Int = 0
    
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
            Color.green50
                .ignoresSafeArea()
            
            Image("bg-picture")
                .resizable()
                //MARK: - 현재 배경이 아이폰 pro 비율을 기준으로 되어 있어, 아이폰 SE 기기에서는 배경이 꽉차지 않음, 그래서 그걸 맞추려고 .scaledFill을 사용하니 뒤에 배경에 맞춰 전체 화면이 크기가 증가하여 레이아웃이 깨지는 현상 발생
                // 지금 상태에서 이 화면 뿐만 아니라 배경이 깔리는 모든 뷰는 아이폰 SE 대응 안됨
                .scaledToFit()
                .ignoresSafeArea()
            
            // MARK: - HeaderView
            VStack(spacing: 0){
                HStack {
                    Button {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        
                        dismiss()
                    } label: {
                        Image("arrow-back-green700")
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 18)
                .padding(.horizontal)
                
                // MARK: - Photo TabView with Paging
                TabView(selection: $currentPhotoIndex) {
                    ForEach(Array(photos.enumerated()), id: \.element.objectID) { index, photo in
                        PhotoFrame(photo: photo)
                            .tag(index)
                            .padding()
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .onChange(of: currentPhotoIndex) { _, newIndex in
                    if newIndex < photos.count {
                        currentPhoto = photos[newIndex]
                    }
                }
                
                thumbnailScrollView
                    .padding(.bottom)
            }
        }
        .onAppear {
            // 초기 인덱스 설정
            if let index = photos.firstIndex(where: { $0.objectID == currentPhoto.objectID }) {
                currentPhotoIndex = index
            }
        }
    }
    
    // MARK: - Thumbnail Scroll View
    private var thumbnailScrollView: some View {
        ScrollViewReader { proxy in
            GeometryReader { geometry in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 3) {
                        ForEach(photos, id: \.objectID) { photo in
                            thumbnailItem(photo: photo)
                                .id(photo.objectID)
                        }
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, geometry.size.width / 2 - 28.5)
                }
            }
            .frame(maxHeight: 105)
            .background(
                Rectangle()
                    .fill(Color.gray0)
                    .shadow(color: .gray900.opacity(0.25), radius: 1.5, x: 0, y: 2)
                    .border(Color.gray400, width: 1)
            )
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 1.0)) {
                        proxy.scrollTo(currentPhoto.objectID, anchor: .center)
                    }
                }
            }
            .onChange(of: currentPhoto) {_, newPhoto in
                withAnimation(.spring(response: 0.3, dampingFraction: 1.0)) {
                    proxy.scrollTo(newPhoto.objectID, anchor: .center)
                }
            }
        }
    }
    
    // MARK: - Thumbnail Item
    private func thumbnailItem(photo: Photo) -> some View {
        Button {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            currentPhoto = photo
            
            if let index = photos.firstIndex(where: { $0.objectID == photo.objectID }) {
                currentPhotoIndex = index
            }
            
        } label: {
            if case .normal = thumbnailState(for: photo) {
                AsyncPhotoImage(photo: photo)
                    .clipShape(Rectangle())
                    .frame(width: 57)
                
            } else if case .selected = thumbnailState(for: photo) {
                ZStack {
                    AsyncPhotoImage(photo: photo)
                        .clipShape(Rectangle())
                        .frame(width: 57)
                    Rectangle()
                        .foregroundColor(.gray900.opacity(0.5))
                        .frame(width: 57)
                    Text("now")
                        .customFont(.categoryButtonTitle)
                        .foregroundColor(.gray0)
                }
            }
        }
    }
    
    // MARK: - Thumbnail State
    private func thumbnailState(for photo: Photo) -> PhotoThumbnailState {
        return photo.objectID == currentPhoto.objectID ? .selected : .normal
    }
}

#Preview {
    let previewContext = CoreDataManager.shared.mainContext
    
    let mockProject = Project(context: previewContext)
    mockProject.id = UUID()
    mockProject.category = "garden"
    mockProject.createdDate = Date()
    mockProject.updatedDate = Date()
    
    var mockPhotos: [Photo] = []
    for i in 1...5 {
        let mockPhoto = Photo(context: previewContext,
                              fileName: "sample\(i).jpg",
                              project: mockProject)
        mockPhoto.capturedDate = Date().addingTimeInterval(TimeInterval(i * 3600 * 24))
        mockPhotos.append(mockPhoto)
    }
    
    do {
        try previewContext.save()
    } catch {
        print("Preview context save failed: \(error)")
    }
    
    let mockCoordinator = AppCoordinator()
    
    return PhotoDetailView(photo: mockPhotos[0], project: mockProject)
        .previewLayout(.sizeThatFits)
        .environment(\.managedObjectContext, previewContext)
}
