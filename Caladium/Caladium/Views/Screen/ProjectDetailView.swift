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
    @Environment(\.dismiss) private var dismiss
    @State private var isCameraButtonPressed = false
    
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
            // 상단 툴바 영역
            customToolbar

            photoGrid
                .overlay(alignment: .bottomTrailing){
                    if case .normal = vm.editMode {
                        cameraButton
                            .padding()
                    }
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
                        .ignoresSafeArea()
                        .onTapGesture {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            
                            vm.isShowingFormatSelectAlert = false
                        }
                }
            
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
        .navigationBarHidden(true)
        .ignoresSafeArea(.container, edges: .bottom)
        
    }
    
    // MARK: - Custom Toolbar
        private var customToolbar: some View {
            HStack {
                // 뒤로가기 버튼
                Button {
                    // 햅틱 피드백 추가
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    
                    // 뒤로가기
                    dismiss()
                } label: {
                    Image("arrow-back-green700")
                        .padding(.horizontal, 24)
                }
                
                // 날짜 범위 텍스트 (일반 모드일 때만 표시)
                if case .normal = vm.editMode {
                    Text(dateRangeText)
                        .customFont(.photoDate)
                        .foregroundColor(.gray900)
                }
                
                Spacer()
            }
            .frame(height: 68)
            .background(Color.gray0)
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
                        text: "삭제할 사진을 선택해주세요"
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
        VStack(alignment: .leading, spacing: 0) {
            Text(text)
                .customFont(.navigationBarTitle)
                .foregroundStyle(.gray900)
            
            if let guideText = guideText {
                Text(guideText)
                    .customFont(.navigationBarBody)
                    .foregroundStyle(.gray500)
                    .padding(.top, 5)
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
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
            Image("camera")
                .background{
                    Rectangle()
                        .fill(Color.green500)
                        .frame(width: 60, height: 60)
                    
                }
                .padding(.leading, 8)
            
            VStack(spacing: 0){
                Text("새로운 사진")
                    .customFont(.categoryButtonTitle)
                    .foregroundStyle(.gray900)
                Text("촬영하기")
                    .customFont(.categoryButtonBody)
                    .foregroundStyle(.gray400)
            }
            .padding(.leading,10)
            
            
        }
        .opacity(isCameraButtonPressed ? 0.3 : 1.0)
        .onTapGesture {
            // 버튼 눌림 효과
            withAnimation(.easeInOut(duration: 0.05)) {
                isCameraButtonPressed = true
            }
            
            // 햅틱
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            // 버튼 원상복구 후 액션 실행
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isCameraButtonPressed = false
                }
                
                // 최신 사진을 찾아서 카메라에 전달
                let latestPhoto = getLatestPhoto()
                vm.addNewPhoto(currentProject: project, latestPhoto: latestPhoto)
            }
        }
        .frame(width: 158, height: 58, alignment: .leading)
        .background{
            Rectangle()
                .fill(Color.gray0)
            
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .gray900.opacity(0.25), radius: 1.5, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray400, lineWidth: 1)
        )
  
    }
    
    // 최신 사진을 가져오는 helper 함수 추가
    private func getLatestPhoto() -> Photo? {
        return photos.last // photos는 이미 capturedDate로 정렬되어 있음 (ascending: true)
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
