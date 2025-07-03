//
//  CaladiumApp.swift
//  Caladium
//
//  Created by yoomin on 6/3/25.
//

import SwiftUI

@main
struct CaladiumApp: App {
    let coreDataService = CoreDataService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(
                    \.managedObjectContext,
                    CoreDataManager.shared.mainContext
                )
                .environment(\.coreDataService, coreDataService) // 동일한 인스턴스 공유
        }
    }
}
