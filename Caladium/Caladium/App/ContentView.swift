//
//  ContentView.swift
//  Caladium
//
//  Created by yoomin on 6/3/25.
//

import SwiftUI
import CoreData


struct ContentView: View {
    @StateObject private var coordinator: AppCoordinator
    @Environment(\.dependencies) private var dependencies
    
    init(coordinator: AppCoordinator){
        self._coordinator = StateObject(wrappedValue: coordinator)
    }
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            rootView
                .navigationDestination(for: AppRoute.self) { route in
                    routeView(for: route)
                }
        }
        .sheet(item: $coordinator.presentedSheet) { route in
            routeView(for: route)
                .environment(\.dependencies, dependencies)

        }
        .fullScreenCover(item: $coordinator.presentedFullScreen) { route in
            routeView(for: route)
        }
        .tint(.green500)
    }
    
    @ViewBuilder
    private var rootView: some View {
        if coordinator.isOnboardingComplete {
            HomeView(vm: dependencies.makeHomeViewModel())
        } else {
            OnboardingContainerView(coordinator: coordinator)
        }
    }
    
    @ViewBuilder
    private func routeView(for route: AppRoute) -> some View {
        switch route {
        case .projectDetail(let project):
            ProjectDetailView(vm: dependencies.makeProjectDetailViewModel(), project: project)
            
        case .photoDetail(let photo, let project):
            PhotoDetailView(photo: photo, project: project)
            
        case .camera(let context, let latestPhoto):
            CameraView(vm: dependencies.makeCameraViewModel(context: context, latestPhoto: latestPhoto))
            
        case .animationResult(let data, let url, let format, let startDate, let endDate):
            AnimationResultView(
                data: data,
                url: url,
                format: format,
                startDate: startDate,
                endDate: endDate
            )
        default:
            EmptyView()
        }
        
        
    }
    
}
