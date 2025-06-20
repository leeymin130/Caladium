//
//  HomeView.swift
//  Caladium
//
//  Created by 이종선 on 6/20/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var vm: HomeViewModel
    
    init(vm: HomeViewModel) {
        self._vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    HomeView(vm: HomeViewModel(coordinator: AppCoordinator()))
}


//// MARK: - Home View
//struct HomeView: View {
//    @EnvironmentObject var coordinator: AppCoordinator
//    @Environment(\.managedObjectContext) private var context
//    
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Project.updatedDate, ascending: false)],
//        animation: .default)
//    private var allProjects: FetchedResults<Project>
//    
//    // 현재 선택된 카테고리의 프로젝트들
//    private var filteredProjects: [Project] {
//        allProjects.filter { $0.categoryEnum == coordinator.currentCategory }
//    }
//    
//    var body: some View {
//        VStack {
//            // 카테고리 선택
//            categorySelector
//            
//            // 메인 컨텐츠
//            if filteredProjects.isEmpty {
//                emptyStateView
//            } else {
//                projectGridView
//            }
//            
//            Spacer()
//        }
//        .navigationTitle(coordinator.currentCategory.displayName)
//        .navigationBarTitleDisplayMode(.large)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                if coordinator.homeEditMode == .normal {
//                    Menu {
//                        Button("새 프로젝트", systemImage: "plus") {
//                            coordinator.startNewProject()
//                        }
//                        Button("편집", systemImage: "pencil") {
//                            coordinator.startDeleteMode()
//                        }
//                        Button("이동", systemImage: "arrow.right") {
//                            coordinator.startMoveMode()
//                        }
//                    } label: {
//                        Image(systemName: "ellipsis.circle")
//                    }
//                } else {
//                    HStack {
//                        Button("취소") {
//                            coordinator.cancelEditMode()
//                        }
//                        
//                        if case .delete(let selected) = coordinator.homeEditMode, !selected.isEmpty {
//                            Button("삭제") {
//                                coordinator.deleteSelectedProjects()
//                            }
//                            .foregroundColor(.red)
//                        }
//                        
//                        if case .move(let selected) = coordinator.homeEditMode, !selected.isEmpty {
//                            Button("이동") {
//                                coordinator.moveSelectedProjects()
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    private var categorySelector: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack(spacing: 15) {
//                ForEach(Category.allCases, id: \.self) { category in
//                    Button {
//                        coordinator.changeCategory(to: category)
//                    } label: {
//                        VStack {
//                            Image(systemName: category.icon)
//                                .font(.title2)
//                            Text(category.displayName)
//                                .font(.caption)
//                        }
//                        .foregroundColor(coordinator.currentCategory == category ? .white : .primary)
//                        .padding(.horizontal, 16)
//                        .padding(.vertical, 12)
//                        .background(
//                            RoundedRectangle(cornerRadius: 12)
//                                .fill(coordinator.currentCategory == category ? Color.blue : Color.gray.opacity(0.2))
//                        )
//                    }
//                    .buttonStyle(.plain)
//                }
//            }
//            .padding(.horizontal)
//        }
//    }
//    
//    private var emptyStateView: some View {
//        VStack(spacing: 20) {
//            Image(systemName: coordinator.currentCategory.icon)
//                .font(.system(size: 60))
//                .foregroundColor(.gray)
//            
//            Text("아직 \(coordinator.currentCategory.displayName) 프로젝트가 없습니다")
//                .font(.title3)
//                .multilineTextAlignment(.center)
//            
//            Text("새로운 식물을 추가해보세요!")
//                .foregroundColor(.secondary)
//            
//            Button {
//                coordinator.startNewProject()
//            } label: {
//                Label("첫 프로젝트 시작하기", systemImage: "plus")
//            }
//            .buttonStyle(.borderedProminent)
//        }
//        .padding()
//    }
//    
//    private var projectGridView: some View {
//        ScrollView {
//            LazyVGrid(columns: [
//                GridItem(.flexible()),
//                GridItem(.flexible())
//            ], spacing: 15) {
//                ForEach(filteredProjects, id: \.id) { project in
//                    ProjectCardView(project: project)
//                }
//            }
//            .padding(.horizontal)
//        }
//    }
//}
