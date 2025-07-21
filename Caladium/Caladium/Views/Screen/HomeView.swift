//
//  HomeView.swift
//  Caladium
//
//  Created by 이종선 on 6/20/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var vm: HomeViewModel
    
    @FetchRequest var projects: FetchedResults<Project>
    
    init(vm: HomeViewModel) {
        self._vm = StateObject(wrappedValue: vm)
        self._projects = FetchRequest(
            entity: Project.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Project.createdDate, ascending: false)],
            predicate: NSPredicate(format: "category == %@", vm.currentCategory.rawValue)
        )
    }
    
    var body: some View {
        ZStack(alignment: .leading){
            Image(vm.currentCategory.background)
                .resizable()
                .scaledToFit()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with category navigation
                categoryHeader
                
                projectsGrid
                
                Spacer()
                
                Button {
                    vm.addMockData()
                } label: {
                    Text("Mock Data Add")
                    
                }
                .padding()
                
                //                bottomToolbar
                BottomToolbar(
                    homeEditMode: vm.editMode,
                    style: .home,
                    hasItems: !projects.isEmpty,
                    onDeleteStart: vm.startDeleteMode,
                    onMoveStart: vm.startMoveMode,
                    onCancel: vm.exitEditMode,
                    onDeleteConfirm: { vm.isShowingDeleteAlert = true },
                    onMoveConfirm: { vm.isShowingMoveAlert = true }
                )
            }
            .navigationTitle("") // 빈 문자열로 설정
            .ignoresSafeArea(.container, edges: .bottom)
        }
        
    }
    
    // MARK: - Category Header
    private var categoryHeader: some View {
        HStack {
            Button(action: vm.previousCategory) {
                Image("btn-left")
                    .padding()
            }
            
            Spacer()
            
            VStack {
                // Category dots indicator
                Image(vm.currentCategory.icon)
                
                Text(vm.currentCategory.displayName)
                    .font(.headline)
                    .padding(.top, 4)
            }
            
            Spacer()
            
            Button(action: vm.nextCategory) {
                Image("btn-right")
                    .padding()
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    
    // MARK: - Projects Grid
    private var projectsGrid: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 24), count: 3), spacing: 12) {
                // Add new project button (always first)
                // newProjectButton
                ProjectAddButton(isEnabled: !vm.isEditMode) {
                    vm.startNewProject()
                }
                
                // Existing projects
                ForEach(projects, id: \.id) { project in
                    projectGridItem(project)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
        }
    }
    
    
    // MARK: - Project Grid Item
    private func projectGridItem(_ project: Project) -> some View {
        ProjectThumbnail(
            project: project,
            state: projectThumbnailState(for: project),
            action: {
                if vm.isEditMode {
                    vm.toggleProjectSelection(project)
                } else {
                    vm.selectProject(selectedProject: project)
                }
            }
        )
        .shadow(color: .gray900.opacity(0.25), radius: 1.5, x: 0, y: 2)
    }
    
    private func projectThumbnailState(for project: Project) -> ProjectThumbnailState {
        switch vm.editMode {
        case .normal:
            return .active
        case .delete(let selectedProjects):
            return selectedProjects.contains(project) ? .selectedForDelete : .inactive
        case .move(let selectedProjects):
            return selectedProjects.contains(project) ? .selectedForMove : .inactive
        }
    }
    
    // MARK: - Bottom Toolbar
    private var bottomToolbar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.green500)
                .frame(height: 5)
                .frame(maxWidth: .infinity)
            
            HStack {
                switch vm.editMode {
                case .normal:
                    Button {
                        vm.startDeleteMode()
                    } label: {
                        Image("btn-delete-0")
                    }
                    .disabled(projects.isEmpty)
                    
                    Spacer()
                    
                    Button {
                        vm.startMoveMode()
                    } label: {
                        Image("btn-move-0")
                    }
                    .disabled(projects.isEmpty)
                    
                case .delete(_):
                    Button {
                        vm.exitEditMode()
                    } label: {
                        Image("btn-cancel-0")
                    }
                    
                    Spacer()
                    
                    if vm.selectedProjectsCount > 0 {
                        Text("\(vm.selectedProjectsCount)개 선택됨")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        vm.isShowingDeleteAlert = true
                        // TODO: 선택한 프로젝트들 삭제 로직 호출
                    } label: {
                        Image("btn-select-0")
                    }
                    
                case .move(_):
                    Button {
                        vm.exitEditMode()
                    } label: {
                        Image("btn-cancel-0")
                    }
                    
                    Spacer()
                    
                    if vm.selectedProjectsCount > 0 {
                        Text("\(vm.selectedProjectsCount)개 선택됨")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        vm.isShowingMoveAlert = true
                    } label: {
                        Image("btn-select-0")
                    }
                }
                
            }
            .background(Color.gray0)
        }
        
    }
}

#Preview {
    HomeView(vm: HomeViewModel(coordinator: AppCoordinator()))
        .environment(\.managedObjectContext, CoreDataManager.preview.mainContext)
}
