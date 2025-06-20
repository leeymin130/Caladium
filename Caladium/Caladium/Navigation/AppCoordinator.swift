//
//  AppCoordinator.swift
//  Caladium
//
//  Created by 이종선 on 6/15/25.
//

import SwiftUI

final class AppCoordinator: ObservableObject {
    // Navigation Stack
    @Published var path = NavigationPath()
    
    // Modal Presentaion
    @Published var presentedSheet: AppRoute?
    @Published var presentedFullScreen: AppRoute?
    
    // App State
    @AppStorage("onboarding_completed") var isOnboardingComplete: Bool = false
    @AppStorage("last_selected_category") var currentCategory: Category = .garden
    @Published var homeEditMode: HomeEditMode = .normal
    
    // Alert States
    @Published var showingAlert: AlertType?
    
    // MARK: - Navigation Methods
    func navigate(to route: AppRoute) {
        path.append(route)
    }
    
    func goBack(){
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func popToRoot() {
        path = NavigationPath()
    }
    
    // MARK: - Modal Methods
    func presentSheet(_ route: AppRoute) {
        presentedSheet = route
    }
    
    func presentFullScreen(_ route: AppRoute) {
        presentedFullScreen = route
    }
    
    func dismissSheet() {
        presentedSheet = nil
    }
    
    func dismissFullScreen() {
        presentedFullScreen = nil
    }
    
    // MARK: - 홈 화면 액션들
    func changeCategory(to category: Category) {
        currentCategory = category
        homeEditMode = .normal  // 카테고리 변경시 편집모드 해제
    }
    // MARK: - 온보딩 완료
    func completeOnboarding() {
        isOnboardingComplete = true  // @AppStorage가 자동으로 저장
    }
    
    func startNewProject() {
        // 먼저 카메라 풀스크린으로 띄우기
        presentFullScreen(.camera(.newProject))
        
        // 카메라 화면에 Alert 띄우기
        showingAlert = .cameraEnvironmentCheck(onConfirm: {
            // 확인: Alert 만 닫기( 카메라 창 유지)
            self.dismissAlert()
        }, onCancel: {
            // 취소 : Alert 먼저 닫고 + 카메라 화면 닫기
            self.dismissAlert()
            self.dismissFullScreen()
        })
    }
    
    func startDeleteMode() {
        homeEditMode = .delete(selectedProject: [])
    }
    
    func startMoveMode() {
        homeEditMode = .move(selectedProject: [])
    }
    
    func cancelEditMode() {
        homeEditMode = .normal
    }
    
    func deleteSelectedProjects() {
        guard case .delete(let projects) = homeEditMode else { return }
        
        showingAlert = .confirmDelete(count: projects.count) {
            // CoreData 삭제 로직
            self.homeEditMode = .normal
        }
    }
    
    func moveSelectedProjects() {
        guard case .move(let projects) = homeEditMode else { return }
        
        showingAlert = .selectMoveCategory(projects: projects) { category in
            // 카테고리 이동 로직
            self.homeEditMode = .normal
        }
    }
    
    // MARK: - 촬영 플로우
    func confirmPhoto(_ image: UIImage, context: CameraContext) {
        switch context {
        case .newProject:
            // 새 프로젝트 생성 후 홈으로
            createNewProject(with: image)
            dismissFullScreen()
            popToRoot()
            
        case .existingProject(let project):
            // 기존 프로젝트에 사진 추가 후 프로젝트 상세로
            addPhoto(image, to: project)
            dismissFullScreen()
        }
    }
    
    func retakePhoto() {
        goBack()  // 촬영 화면으로 돌아가기
    }
    
    // MARK: - 프로젝트 상세 액션들
    func addPhotoToProject(_ project: Project) {
        presentFullScreen(.camera(.existingProject(project)))
    }
    
    func startVideoCreation(for project: Project) {
        presentSheet(.videoPhotoSelection(project))
    }
    
    // MARK: - 영상 만들기 플로우
    func createVideoWithPhotos(_ photos: [Photo]) {
        dismissSheet()  // 사진 선택 화면 닫기
        presentSheet(.videoGeneration(photos))  // 영상 생성 화면 열기
    }
    
    func completeVideoGeneration() {
        dismissSheet()
    }
    
    // MARK: - Alert 관리
    func showAlert(_ alertType: AlertType) {
        showingAlert = alertType
    }
    
    func dismissAlert() {
        showingAlert = nil
    }
    
    // MARK: - Private Helper Methods
    private func createNewProject(with image: UIImage) {
        // CoreData 새 프로젝트 생성 로직
    }
    
    private func addPhoto(_ image: UIImage, to project: Project) {
        // CoreData 사진 추가 로직
    }
    
}

enum AlertType: Identifiable {
    case cameraEnvironmentCheck(onConfirm: () -> Void, onCancel: () -> Void)
    case confirmDelete(count: Int, onConfirm: () -> Void)
    case selectMoveCategory(projects: Set<Project>, onSelect: (
    Category) -> Void)
    
    var id: String {
        switch self {
        case .cameraEnvironmentCheck: return "camera_check"
        case .confirmDelete: return "confirm_delete"
        case .selectMoveCategory: return "select_category"
        }
    }
}
