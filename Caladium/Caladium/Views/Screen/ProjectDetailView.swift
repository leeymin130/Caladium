//
//  ProjectDetailView.swift
//  Caladium
//
//  Created by 이종선 on 6/22/25.
//

import SwiftUI
import CoreData

// MARK: - Project Detail View
struct ProjectDetailView: View {
    
    @StateObject private var vm: ProjectDetailViewModel
    
    let project: Project
    @FetchRequest private var photos: FetchedResults<Photo>
    
    init(vm: ProjectDetailViewModel, project: Project) {
        self._vm = StateObject(wrappedValue: vm)
        self.project = project
        self._photos = FetchRequest(
            entity: Photo.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Photo.capturedDate, ascending: true)],
            predicate: NSPredicate(format: "project == %@", project)
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            photoGrid
                .overlay(alignment: .bottomTrailing){
                    cameraButton
                        .padding()
                }
                .alert(isPresented: $vm.isShowingDeleteAlert) {
                    /// ALERT CONTENT
                    PhotoDeleteConfirmPopup(cancelButtonAction: {
                        vm.isShowingDeleteAlert = false
                    }, confirmButtonAction: {
                        vm.deleteSelectedPhotos()
                    })
                    .padding(.horizontal)

                } background: {
                    /// BACKGROUND
                    Rectangle()
                        .fill(.primary.opacity(0.35))
                }
                .alert(isPresented: $vm.isShowingFormatSelectAlert) {
                    FormatSelectPopupView {
                        /// mov로 애니메이션 만들기 로직
                        vm.selectMovFormat()
                    } confirmButtonAction: {
                        /// gif로 애니메이션 만들기 로직
                        vm.selectGifFormat()
                    }
                    .padding(.horizontal)

                } background: {
                    Rectangle()
                        .fill(.primary.opacity(0.35))
                }
            
            //            bottomToolbar
            BottomToolbar(
                projectEditMode: vm.editMode,
                style: .projectDetail,
                hasItems: !photos.isEmpty,
                onDeleteStart: vm.startDeleteMode,
                onMoveStart: {}, // ProjectDetail에서는 사용하지 않음
                onCancel: vm.exitEditMode,
                onDeleteConfirm: {
                    // TODO: 선택한 사진들 삭제 로직 호출
                    vm.isShowingDeleteAlert = true
                },
                onMoveConfirm: {}, // ProjectDetail에서는 사용하지 않음
                onVideoStart: vm.startVideoMode,
                onVideoConfirm: {
                    // TODO: 비디오 만들기 로직 호출
                    vm.isShowingFormatSelectAlert = true
                }
            )
        }
        .overlay {
            // 로딩 오버레이
            if vm.isGeneratingAnimation {
                LoadingView()
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(vm.isGeneratingAnimation) // 로딩 중에는 네비게이션 바 숨기기
        .toolbar {
            if case .normal = vm.editMode {
                ToolbarItem(placement: .principal) {
                    Text(dateRangeText)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
            }
        }
        .ignoresSafeArea(.container, edges: .bottom)
        
    }
    
    // MARK: - Photo Grid
    
    private var photoGrid: some View {
        GeometryReader { geo in
            let spacing: CGFloat = 3
            let totalSpacing = spacing * 2
            let availableWidth = geo.size.width - totalSpacing - 2
            let itemSize = availableWidth / 3
            
            ScrollView {
                // 편집 모드 가이드 배너
                if case .delete = vm.editMode {
                    guideBanner(
                        text: "삭제할 식물을 선택해주세요"
                    )
                } else if case .makeVideo = vm.editMode {
                    guideBanner(text: "영상에 추가할 사진을 고르세요", guideText : "사진을 많이 선택할수록 영상이 풍성해져요")
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: 3), spacing: 3) {
                    ForEach(photos, id: \.objectID) { photo in
                        photoGridItem(photo: photo, size: itemSize)
                    }
                }
                .padding(.horizontal, 1)
                
            }
        }
    }
    
    // MARK: - Guide Banner
    private func guideBanner(text: String, guideText: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(text)
                .font(.system(size: 24, weight: .semibold))
            
            if let guideText = guideText {
                Text(guideText)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.secondary)
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .transition(.asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        ))
    }
    
    private func photoGridItem(photo: Photo, size: CGFloat) -> some View {
        PhotoThumbnail(
            photo: photo,
            state: photoThumbnailState(for: photo),
            size: size,
            action: {
                if vm.isEditMode {
                    vm.togglePhotoSelection(photo)
                } else {
                    vm.navigateToPhotoDetail(photo: photo, project: project)
                }
            }
        )
    }
    
    private func photoThumbnailState(for photo: Photo) -> PhotoThumbnailState {
        switch vm.editMode {
        case .normal:
            return .normal
        case .delete(let selectedPhotos), .makeVideo(let selectedPhotos):
            return selectedPhotos.contains(photo) ? .selected : .normal
        }
    }

    private var cameraButton: some View {
        HStack(alignment: .center,spacing: 18){
            Image(systemName: "camera.fill")
                .font(.system(size: 30, weight: .medium))
                .foregroundColor(.white)
                .background{
                    Rectangle()
                        .fill(Color.green500)
                        .frame(width: 60, height: 60)
                    
                }
                .padding(.leading, 8)
            
            VStack(spacing: 4){
                Text("새로운 사진")
                    .font(.caption)
                    .foregroundStyle(.primary)
                Text("촬영하기")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.leading,10)
            
            
        }
        .onTapGesture {
            vm.addNewPhoto(currentProject: project)
        }
        .frame(width: 158, height: 58, alignment: .leading)
        .background{
            Rectangle()
                .fill(Color.white)
            
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray400, lineWidth: 2)
        )
        
        
    }
    
    private var dateRangeText: String {
        let formatter = Date.FormatStyle()
            .year()
            .month(.wide)
            .day()
            .locale(Locale(identifier: "ko_KR"))
        
        let startDate = project.createdDate?.formatted(formatter) ?? ""
        let endDate = project.updatedDate?.formatted(formatter) ?? ""
        
        return "\(startDate) ~ \(endDate)"
    }
}
