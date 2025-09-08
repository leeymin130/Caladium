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
    
    @State private var dragOffset: CGFloat = 0
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
                
                GeometryReader { geometry in
                    HStack(spacing: 18) {
                        ForEach(Array(photos.enumerated()), id: \.element.objectID) { index, photo in
                            PhotoFrame(photo: photo)
                                .frame(width: geometry.size.width)
                                .id(photo.objectID)
                        }
                    }
                    .offset(x: -CGFloat(currentPhotoIndex) * (geometry.size.width + 18) + dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation.width
                            }
                            .onEnded { value in
                                let threshold: CGFloat = 50
                                
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    if value.translation.width > threshold && currentPhotoIndex > 0 {
                                        // 이전 사진
                                        currentPhotoIndex -= 1
                                    } else if value.translation.width < -threshold && currentPhotoIndex < photos.count - 1 {
                                        // 다음 사진
                                        currentPhotoIndex += 1
                                    }
                                    
                                    currentPhoto = photos[currentPhotoIndex]
                                    dragOffset = 0
                                }
                            }
                    )
                }
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
            .frame(height: 105)
            .background(
                Rectangle()
                    .fill(Color.gray0)
                    .shadow(color: .gray900.opacity(0.25), radius: 1.5, x: 0, y: 2)
                    .border(Color.gray400, width: 1)
            )
            .onAppear {
                if let index = photos.firstIndex(where: { $0.objectID == currentPhoto.objectID }) {
                    currentPhotoIndex = index
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 1.0)) {
                        proxy.scrollTo(currentPhoto.objectID, anchor: .center)
                    }
                }
            }
            .onChange(of: currentPhoto) { newPhoto in
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
