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
        // 카메라 풀스크린 닫을 때 카메라 내부 네비게이션도 초기화
        cameraPath = NavigationPath()
    }
    
    // MARK: - 카테고리 변경
    func changeCategory(to category: Category) {
        currentCategory = category
    }
    
    // MARK: - 온보딩 완료
    func completeOnboarding() {
        isOnboardingComplete = true  // @AppStorage가 자동으로 저장
    }
    
    // MARK: - 촬영 플로우 (카메라 내부 네비게이션)
    @Published var cameraPath = NavigationPath()
    
    func pushToPhotoConfirm(_ image: UIImage, context: CameraContext) {
        // 카메라 내부 네비게이션 스택에 PhotoConfirm 추가
        cameraPath.append(AppRoute.photoConfirm(image, context))
    }
    
    func popCameraView() {
        if !cameraPath.isEmpty {
            cameraPath.removeLast()
        }
    }
    
    func confirmPhoto(_ image: UIImage, context: CameraContext) {
        switch context {
        case .newProject:
            // 새 프로젝트 생성 후 홈으로
            dismissFullScreen()
            popToRoot()
            
        case .existingProject(let project):
            // 기존 프로젝트에 사진 추가 후 프로젝트 상세로
            dismissFullScreen()
        }
    }
    
    func retakePhoto() {
        popCameraView()  // 카메라 내부 네비게이션에서 뒤로가기
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
}
