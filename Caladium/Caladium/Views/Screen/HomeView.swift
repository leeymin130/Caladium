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
        VStack(spacing: 0) {
            // Header with category navigation
            categoryHeader
            
            projectsGrid
                .alert(isPresented: $vm.isShowingDeleteAlert) {
                    /// ALERT CONTENT
                    DeleteConfirmPopup {
                        vm.isShowingDeleteAlert = false
                    } confirmButtonAction: {
                        // TODO: 선택한 프로젝트들 삭제 로직 호출
                        vm.deleteSelectedProjects()
                    }
                    .padding(.horizontal)

                } background: {
                    /// BACKGROUND
                    Rectangle()
                        .fill(.primary.opacity(0.35))
                }
                .alert(isPresented: $vm.isShowingMoveAlert) {
                    /// ALERT CONTENT
                    CategoryChangePopup(selectedCategory: vm.currentCategory, cancelButtonAction: {
                        vm.isShowingMoveAlert = false
                    }, confirmButtonAction: {
                        // TODO: 선택한 프로젝트들 옮기기 로직 호출
                        vm.moveSelectedProjects()
                    })
                    .padding(.horizontal)

                } background: {
                    /// BACKGROUND
                    Rectangle()
                        .fill(.primary.opacity(0.35))
                }
            
            
            Spacer()
            
            Button {
                vm.addMockData()
            } label: {
                Text("Mock Data Add")

            }
            .padding()

            
            bottomToolbar
        }
        .navigationTitle("") // 빈 문자열로 설정
    }
    
    // MARK: - Category Header
    private var categoryHeader: some View {
        HStack {
            Button(action: vm.previousCategory) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.green)
                    .padding()
            }
            
            Spacer()
            
            VStack {
                // Category dots indicator
                HStack(spacing: 8) {
                    ForEach(Category.allCases, id: \.self) { category in
                        Circle()
                            .fill(category == vm.currentCategory ? Color.green : Color.gray.opacity(0.3))
                            .frame(
                                width: category == vm.currentCategory ? 10 : 8,
                                height: category == vm.currentCategory ? 10 : 8)
                    }
                }
                
                
                Text(vm.currentCategory.displayName)
                    .font(.headline)
                    .padding(.top, 4)
            }
            
            Spacer()
            
            Button(action: vm.nextCategory) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(.green)
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
        HStack {
            
            switch vm.editMode {
            case .normal:
                Button {
                    vm.startDeleteMode()
                } label: {
                    VStack {
                        Image(systemName: "trash")
                            .font(.title2)
                        Text("지우기")
                            .font(.caption)
                    }
                    .foregroundColor(.red)
                }
                .disabled(projects.isEmpty)
                
                Spacer()
                
                Button {
                    vm.startMoveMode()
                } label: {
                    VStack {
                        Image(systemName: "folder")
                            .font(.title2)
                        Text("옮기기")
                            .font(.caption)
                    }
                }
                .disabled(projects.isEmpty)

            case .delete(_):
                Button {
                    vm.exitEditMode()
                } label: {
                    VStack{
                        Image(systemName: "xmark")
                            .font(.title2)
                        Text("취소")
                            .font(.caption)
                    }
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
                } label: {
                    VStack{
                        Image(systemName: "checkmark")
                            .font(.title2)
                        Text("확인")
                            .font(.caption)
                    }
                }

            case .move(_):
                Button {
                    vm.exitEditMode()
                } label: {
                    VStack{
                        Image(systemName: "xmark")
                            .font(.title2)
                        Text("취소")
                            .font(.caption)
                    }
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
                    VStack{
                        Image(systemName: "checkmark")
                            .font(.title2)
                        Text("확인")
                            .font(.caption)
                    }
                }
            }
            
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: -1)
        
    }
}

#Preview {
    HomeView(vm: HomeViewModel(coordinator: AppCoordinator(), coreDataService: CoreDataService()))
        .environment(\.managedObjectContext, CoreDataManager.preview.mainContext)
}

