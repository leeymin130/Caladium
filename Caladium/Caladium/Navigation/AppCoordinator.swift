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
    @Published var cameraPath = NavigationPath()
    
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
        // 카메라 풀스크린 닫을 때 카메라 내부 네비게이션도 초기화
        cameraPath = NavigationPath()
        presentedFullScreen = nil
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
    func pushToPhotoConfirm(_ image: UIImage, context: CameraContext) {
        // 카메라 내부 네비게이션 스택에 PhotoConfirm 추가
        DispatchQueue.main.async {
            self.cameraPath.append(AppRoute.photoConfirm(image, context))
        }
    }
    
    func pushToCategorySelectView(_ image: UIImage){
        cameraPath.append(AppRoute.saveNewProject(image))
    }
    
    func popCameraView() {
        if !cameraPath.isEmpty {
            cameraPath.removeLast()
        }
    }
    
}
