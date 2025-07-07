//
//  HomeViewModel.swift
//  Caladium
//
//  Created by yoomin on 6/9/25.
//

import Foundation

final class HomeViewModel: ObservableObject {
    
    @Published var currentCategory: Category
    @Published var editMode: HomeEditMode = .normal
    @Published var isShowingDeleteAlert: Bool = false
    @Published var isShowingMoveAlert: Bool = false
    
    private let coordinator: AppCoordinator
    private let coreDataService: CoreDataService
    
    init(coordinator: AppCoordinator, coreDataService: CoreDataService) {
        self.coordinator = coordinator
        self.currentCategory = coordinator.currentCategory
        self.coreDataService = coreDataService
    }
    
    // MARK: - Category Navigation
    func previousCategory() {
        let allCases = Category.allCases
        if let currentIndex = allCases.firstIndex(of: currentCategory) {
            let previousIndex = currentIndex > 0 ? currentIndex - 1 : allCases.count - 1
            changeCategory(to: allCases[previousIndex])
        }
    }
    
    func nextCategory() {
        let allCases = Category.allCases
        if let currentIndex = allCases.firstIndex(of: currentCategory) {
            let nextIndex = (currentIndex + 1) % allCases.count
            changeCategory(to: allCases[nextIndex])
        }
    }
    
    private func changeCategory(to category: Category) {
        currentCategory = category
        coordinator.changeCategory(to: category)
        // 카테고리 변경시 편집모드 해제
        exitEditMode()
    }
    
    // MARK: -  Project Actions
    func startNewProject() {
        coordinator.presentFullScreen(.camera(.newProject))
    }
    
    func selectProject(selectedProject: Project) {
        // 선택한 프로젝트로 네비게이션
        coordinator.navigate(to: .projectDetail(selectedProject))
    }
    
    // MARK: - Edit Mode
    func startDeleteMode() {
        editMode = .delete(selectedProject: [])
    }
    
    func startMoveMode() {
        editMode = .move(selectedProject: [])
    }
    
    func exitEditMode() {
        editMode = .normal
    }
    
    func toggleProjectSelection(_ project: Project) {
        switch editMode {
        case .delete(var selected):
            if selected.contains(project) {
                selected.remove(project)
            } else {
                selected.insert(project)
            }
            editMode = .delete(selectedProject: selected)
        case .move(var selected):
            if selected.contains(project) {
                selected.remove(project)
            } else {
                selected.insert(project)
            }
            editMode = .move(selectedProject: selected)
            
        case .normal:
            break
        }
    }
    
    // View에서 각 프로젝트 선택상태 표시할 때 사용
    func isProjectSelected(_ project: Project) -> Bool {
        switch editMode {
        case .delete(let selected), .move(let selected):
            return selected.contains(project)
        case .normal:
            return false
        }
    }
    
    // TODO: Coordinator에서 화면 전환 로직 제외한 편집 모드 or 삭제 관련 로직 모두 제거
    func deleteSelectedProjects() {
        guard case .delete(let projects) = editMode else { return }
        
        self.isShowingDeleteAlert = false
    }
    
    func moveSelectedProjects() {
        guard case .move(let projects) = editMode else { return }
        
        self.isShowingMoveAlert = false
    }
    
    // MARK: - Private Methods
    private func performDelete(projects: Set<Project>) {
        // CoreData 삭제 로직
        // TODO: 실제 Core Data 삭제 구현 / CoreDataService 주입
    }
    
    private func performMove(projects: Set<Project>, to category: Category) {
        // CoreData 카테고리 이동 로직
        // TODO: 실제 Core Data 업데이트 구현 / CoreDataService 주입 
    }
    
    var isEditMode: Bool {
        switch editMode {
        case .normal:
            return false
        case .delete, .move:
            return true
        }
    }
    
    var selectedProjectsCount: Int {
        switch editMode {
        case .delete(let projects), .move(let projects):
            return projects.count
        case .normal:
            return 0
        }
    }

}


extension HomeViewModel {
    func addMockData() {
        coreDataService.createMockData()
    }
}
