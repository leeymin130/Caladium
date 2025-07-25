//
//  ProjectDetailViewModel.swift
//  Caladium
//
//  Created by yoomin on 6/9/25.
//

import Foundation
import SwiftUI

enum AnimationFormat: String {
    case gif 
    case mov
}

final class ProjectDetailViewModel: ObservableObject {
    
    @Published var editMode: ProjectEditMode = .normal
    @Published var isShowingDeleteAlert: Bool = false
    @Published var isShowingFormatSelectAlert: Bool = false
    @Published var isGeneratingAnimation = false
    private var selectedAnimationFormat : AnimationFormat = .gif
    
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
    func addNewPhoto(currentProject: Project, latestPhoto: Photo?) {
        coordinator.presentFullScreen(.camera(.existingProject(currentProject), latestPhoto))
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
    
    // 포멧 선택
    func selectGifFormat() {
        selectedAnimationFormat = .gif
        makeAnimationWithSelectedPhotos()
    }
    
    func selectMovFormat() {
        selectedAnimationFormat = .mov
        makeAnimationWithSelectedPhotos()
    }
    
    // 선택된 사진들로 애니메이션 만들기
    func makeAnimationWithSelectedPhotos() {
        guard case .makeVideo(let selectedPhotos) = editMode else { return }
        
        exitEditMode()
        isShowingFormatSelectAlert = false
        isGeneratingAnimation = true
        
        // 실제 애니메이션 생성 작업
        Task {
            let startTime = Date()
            let minimumDuration: TimeInterval = 2.0
            
            var resultData: Data?
            var resultURL: URL?
            
            // 백그라운드에서 실제 생성 작업 수행
            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    await self.performAnimationGeneration(
                        photos: Array(selectedPhotos)
                    ) { data, url in
                        resultData = data
                        resultURL = url
                    }
                }
            }
            
            // 최소 시간 보장
            let elapsedTime = Date().timeIntervalSince(startTime)
            let remainingTime = max(0, minimumDuration - elapsedTime)
            
            if remainingTime > 0 {
                try? await Task.sleep(nanoseconds: UInt64(remainingTime * 1_000_000_000))
            }
            
            // 완료 처리
            await MainActor.run {
                self.isGeneratingAnimation = false
                
                // 날짜 범위 계산
                let dateRange = self.getDateRange(from: Array(selectedPhotos))
                
                // 적절한 결과 전달 (날짜 정보 포함)
                switch self.selectedAnimationFormat {
                case .gif:
                    self.coordinator.navigate(to: .animationResult(
                        data: resultData,
                        url: nil,
                        format: .gif,
                        startDate: dateRange.start,
                        endDate: dateRange.end
                    ))
                case .mov:
                    self.coordinator.navigate(to: .animationResult(
                        data: nil,
                        url: resultURL,
                        format: .mov,
                        startDate: dateRange.start,
                        endDate: dateRange.end
                    ))
                }
            }
        }
    }
    
    private func getDateRange(from photos: [Photo]) -> (start: Date?, end: Date?) {
        let sortedPhotos = photos.sorted { photo1, photo2 in
            guard let date1 = photo1.capturedDate,
                  let date2 = photo2.capturedDate else {
                return false
            }
            return date1 < date2
        }
        
        return (
            start: sortedPhotos.first?.capturedDate,
            end: sortedPhotos.last?.capturedDate
        )
    }
    
    private func performAnimationGeneration(
        photos: [Photo],
        completion: @escaping (Data?, URL?) -> Void
    ) async {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let images = self.loadImagesFromPhotos(photos)
                
                switch self.selectedAnimationFormat {
                case .gif:
                    // GIF 생성
                    let gifData = GIFCreator.createGIF(
                        from: images,
                        duration: 3.0,
                        loopCount: 0
                    )
                    completion(gifData, nil)
                    
                case .mov:
                    // 비디오 생성
                    let tempURL = self.createTempVideoURL()
                    VideoCreator.createVideo(
                        from: images,
                        outputURL: tempURL,
                        duration: 3.0
                    ) { success in
                        completion(nil, success ? tempURL : nil)
                    }
                }
                
                continuation.resume()
            }
        }
    }
    
    private func loadImagesFromPhotos(_ photos: [Photo]) -> [UIImage] {
        // capturedDate 기준으로 오래된 것부터 최신 순으로 정렬
        let sortedPhotos = photos.sorted { photo1, photo2 in
            guard let date1 = photo1.capturedDate,
                  let date2 = photo2.capturedDate else {
                return false
            }
            return date1 < date2  // 오래된 것이 먼저
        }
        
        return sortedPhotos.compactMap { photo in
            guard let fileURL = photo.getFileURL(),
                  let imageData = try? Data(contentsOf: fileURL) else { return nil }
            return UIImage(data: imageData)
        }
    }
    
    private func createTempVideoURL() -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let filename = "animation_\(UUID().uuidString).mov"
        return tempDir.appendingPathComponent(filename)
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
    
    var selectedPhotosCount: Int {
        switch editMode {
        case .delete(let photos), .makeVideo(let photos):
            return photos.count
        case .normal:
            return 0
        }
    }

}
