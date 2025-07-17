//
//  ProjectDetailViewModel.swift
//  Caladium
//
//  Created by yoomin on 6/9/25.
//

import Foundation

final class ProjectDetailViewModel: ObservableObject {
    
    @Published var editMode: ProjectEditMode = .normal
    @Published var isShowingDeleteAlert: Bool = false
    @Published var isShowingFormatSelectAlert: Bool = false
    
    private let coordinator: AppCoordinator
    private let coreDataService: CoreDataService
    // 사진 만들기 서비스
    private let gifService: GIFCreator
    private let videoService: VideoCreator
    
    init(coordinator: AppCoordinator, coreDataService: CoreDataService, gifService: GIFCreator, videoService: VideoCreator) {
        self.coordinator = coordinator
        self.coreDataService = coreDataService
        self.gifService = gifService
        self.videoService = videoService
    }
    
    // 선택한 사진 상세뷰 네비게이션
    func navigateToPhotoDetail(photo: Photo, project: Project) {
        coordinator.navigate(to: .photoDetail(photo, project))
    }
    
    // 새로운 사진 찍기
    func addNewPhoto(currentProject: Project) {
        coordinator.presentFullScreen(.camera(.existingProject(currentProject)))
    }
    
    // 지우기 모드 들어가기 -> 사진선택 -> 취소 or 삭제
    func startDeleteMode() {
        editMode = .delete(selectedPhoto: [])
    }
    
    // 영상 만들기 모드 들어가기 -> 사진선택 -> 취소 or 만들기
    func startVideoMode() {
        editMode = .makeVideo(selectedPhoto: [])
    }
    
    func exitEditMode() {
        editMode = .normal
    }
    
    func togglePhotoSelection(_ photo: Photo) {
        switch editMode {
        case .delete(var selectedPhoto):
            if selectedPhoto.contains(photo) {
                selectedPhoto.remove(photo)
            } else {
                selectedPhoto.insert(photo)
            }
            editMode = .delete(selectedPhoto: selectedPhoto)
        case .makeVideo(var selectedPhoto):
            if selectedPhoto.contains(photo) {
                selectedPhoto.remove(photo)
            } else {
                selectedPhoto.insert(photo)
            }
            editMode = .makeVideo(selectedPhoto: selectedPhoto)
        case .normal:
            break
        }
    }
    
    func isPhotoSelected(_ photo: Photo) -> Bool {
        switch editMode {
        case .delete(let selected), .makeVideo(let selected):
            return selected.contains(photo)
        case .normal:
            return false
        }
    }
    
    // 선택된 사진들 삭제하기 로직
    func deleteSelectedPhotos() {
        guard case .delete(let selectedPhoto) = editMode else { return }
        
        performDelete(photos: selectedPhoto)
        exitEditMode()
        self.isShowingDeleteAlert = false
    }
    
    
    // 선택된 사진들로 영상 만들기 로직
    func makeVideoSelectedPhotos() {
        guard case .makeVideo(let selectedPhoto) = editMode else { return }
    }
    
    private func performDelete(photos: Set<Photo>) {
        try? coreDataService.deletePhotos(Array(photos))
    }
    
    var isEditMode: Bool {
        switch editMode {
        case .normal:
            return false
        case .delete, .makeVideo:
            return true
        }
    }
    
    var selectedProjectsCount: Int {
        switch editMode {
        case .delete(let photos), .makeVideo(let photos):
            return photos.count
        case .normal:
            return 0
        }
    }

}
