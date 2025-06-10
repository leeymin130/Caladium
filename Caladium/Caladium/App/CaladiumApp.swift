//
//  CaladiumApp.swift
//  Caladium
//
//  Created by yoomin on 6/3/25.
//

import SwiftUI

@main
struct CaladiumApp: App {
    // CoreDataStack을 앱 레벨에서 초기화
    let coreDataStack = CoreDataStack.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, coreDataStack.context)
        }
    }
}
