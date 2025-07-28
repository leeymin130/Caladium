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
                if case .normal = vm.editMode {
                    categoryHeader
                }
                projectsGrid
                    .alert(isPresented: $vm.isShowingMoveAlert) {
                        /// ALERT CONTENT
                        CategoryChangePopup(selectedCategory: vm.currentCategory, cancelButtonAction: {
                            vm.isShowingMoveAlert = false
                        }, confirmButtonAction: { selectedCategory in
                            vm.moveSelectedProjects(to: selectedCategory)
                        })
                        .padding(.horizontal)
                        
                    } background: {
                        /// BACKGROUND
                        Rectangle()
                            .fill(.primary.opacity(0.35))
                    }
                    .alert(isPresented: $vm.isShowingDeleteAlert) {
                        /// ALERT CONTENT
                        DeleteConfirmPopup {
                            vm.isShowingDeleteAlert = false
                        } confirmButtonAction: {
                            vm.deleteSelectedProjects()
                        }
                        .padding(.horizontal)

                        
                    } background: {
                        /// BACKGROUND
                        Rectangle()
                            .fill(.primary.opacity(0.35))
                    }
                
                Spacer()
                
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
            
            VStack(spacing: 0) {
                // Category dots indicator
                Image(vm.currentCategory.icon)
                
                Text(vm.currentCategory.displayName)
                    .customFont(.categoryTitle)
                    .foregroundColor(.gray900)
                    .padding(.top, 4)
            }
            
            Spacer()
            
            Button(action: vm.nextCategory) {
                Image("btn-right")
                    .padding()
            }
        }
        .padding(.horizontal, -4)
        .padding(.top)
    }
    
    
    // MARK: - Projects Grid
    private var projectsGrid: some View {
        ScrollView {
            // 편집 모드 가이드 배너
            if case .delete = vm.editMode {
                guideBanner(text1: "삭제할 식물을", text2: "선택해주세요")
            } else if case .move = vm.editMode {
                guideBanner(text1: "장소를 옮길 식물을", text2: "선택해주세요")
            }
            
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
            .padding(.horizontal, 24)
            .padding(.top, 20)
        }
    }
    
    // MARK: - Guide Banner
    private func guideBanner(text1: String, text2: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(text1)
                .customFont(.navigationBarTitle)
            Text(text2)
                .customFont(.navigationBarTitle)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 63)
        .transition(.asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        ))
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
}

#Preview {
    HomeView(vm: HomeViewModel(coordinator: AppCoordinator(), coreDataService: CoreDataService()))
        .environment(\.managedObjectContext, CoreDataManager.preview.mainContext)
}
