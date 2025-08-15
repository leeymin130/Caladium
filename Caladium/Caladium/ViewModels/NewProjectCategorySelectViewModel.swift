//
//  NewProjectCategorySelectViewModel.swift
//  Caladium
//
//  Created by 이종선 on 7/25/25.
//

import SwiftUI
import Combine

final class NewProjectCategorySelectViewModel: ObservableObject {
    
    var coordinator: AppCoordinator
    let coreDataService: CoreDataService
    
    @Published var selectedCategory: Category = .garden
    let categories = Category.allCases
    let image: UIImage
    
    init(
        coordinator: AppCoordinator,
        coreDataService: CoreDataService,
        image: UIImage
    ) {
        self.coordinator = coordinator
        self.coreDataService = coreDataService
        self.image = image
    }
    
    
    func back(){
//        coordinator.popCameraView()
        coordinator.popToPreviousCameraView()
    }
    
    func saveNewProject(){
        coreDataService.createNewProject(category: selectedCategory, image: image)
        coordinator.dismissFullScreen()
    }
}
