//
//  PhotoConfirmView.swift
//  Caladium
//
//  Created by 이종선 on 7/25/25.
//

import SwiftUI

final class PhotoConfirmViewModel: ObservableObject {
    
    private let coordinator: AppCoordinator
    private let coreDataService: CoreDataService
    let image: UIImage
    let context: CameraContext

    
    init(coordinator: AppCoordinator, coreDataService: CoreDataService, imgae:UIImage, context: CameraContext) {
        self.coordinator = coordinator
        self.coreDataService = coreDataService
        self.image = imgae
        self.context = context
    }
    
    
    // 사진 다시 찍기
    func retakePhoto() {
        coordinator.popCameraView()
    }
    

    func confirmPhoto() {
        switch context {
        // 카테고리 선택뷰 이동하기 
        // When: 프로젝트 생성 context일때, coreDataService 이용해서 방금 찍은 사진으로 새로운 프로젝트 생성하기
        case .newProject:
            return
        // When : 사진 찍기 context 일때, coreDataService 이용해서 현재 프로젝트에 사진 추가하기
        case .existingProject(let project):
            return
        }
    }

}
