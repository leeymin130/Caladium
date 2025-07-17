//
//  DependencyContainer.swift
//  Caladium
//
//  Created by 이종선 on 7/7/25.
//

import SwiftUI

struct DependencyContainerKey: EnvironmentKey {
    static let defaultValue = DependencyContainer.shared
}

extension EnvironmentValues {
    var dependencies: DependencyContainer {
        get { self[DependencyContainerKey.self] }
        set { self[DependencyContainerKey.self] = newValue }
    }
}

final class DependencyContainer: ObservableObject {
    static let shared = DependencyContainer()
    
    // MARK: - App Coordinator
    lazy var appCoordinator: AppCoordinator = {
        return AppCoordinator()
    }()
    
    // MARK: - CoreData Services
    lazy var coreDataManager: CoreDataManager = {
        return CoreDataManager.shared
    }()
    
    lazy var coreDataService: CoreDataService = {
        return CoreDataService(coreDataManager: coreDataManager)
    }()
    
    // MARK: - GIF/Mov Creator Service
    lazy var gifCreatorService: GIFCreator = {
        return GIFCreator()
    }()
    
    lazy var movCreatorService: VideoCreator = {
        return VideoCreator()
    }()
    
    // MARK: - Preview/Test Container
    static var preview: DependencyContainer = {
        let container = DependencyContainer()
        // Preview용 CoreDataManager 사용
        container.coreDataManager = CoreDataManager.preview
        return container
    }()
    
    private init() {}
    
    // MARK: - ViewModel Factory Methods
    func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel(coordinator: appCoordinator, coreDataService: coreDataService)
    }
    
    func makeProjectDetailViewModel() -> ProjectDetailViewModel {
        return ProjectDetailViewModel(coordinator: appCoordinator, coreDataService: coreDataService, gifService: gifCreatorService, videoService: movCreatorService)
    }
    
}
