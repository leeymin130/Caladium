//
//  CaladiumApp.swift
//  Caladium
//
//  Created by yoomin on 6/3/25.
//

import SwiftUI

@main
struct CaladiumApp: App {
    let dependencyContainer: DependencyContainer = .shared

    var body: some Scene {
        WindowGroup {
            ContentView(coordinator: dependencyContainer.appCoordinator)
                .environment(
                    \.managedObjectContext,
                     dependencyContainer.coreDataManager.mainContext
                )
                .environment(\.dependencies, dependencyContainer)
                .preferredColorScheme(.light)
        }
    }
}
