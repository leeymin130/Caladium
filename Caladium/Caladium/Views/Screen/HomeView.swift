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
                
                bottomToolbar
            }
            .navigationTitle("") // 빈 문자열로 설정
        }
        
    }
    
    // MARK: - Category Header
    private var categoryHeader: some View {
        HStack {
            Button(action: vm.previousCategory) {
                Image("btn-left1")
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
                Image("btn-right1")
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
                //                newProjectButton
                ProjectAddButton(isEnabled: .constant(!vm.isEditMode)) {
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
        Button(action: {
            if vm.isEditMode {
                vm.toggleProjectSelection(project)
            } else {
                // Navigate to selected Project
                vm.selectProject(selectedProject: project)
            }
        }) {
            ZStack {
                // Project thumbnail (placeholder)
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "leaf.fill")
                            .font(.title)
                            .foregroundColor(.green)
                    )
                
                // Selection indicator
                if vm.isProjectSelected(project) {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue, lineWidth: 3)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(12)
                }
                
                // Selection checkbox
                if vm.isEditMode {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: vm.isProjectSelected(project) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(vm.isProjectSelected(project) ? .blue : .white)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .padding(8)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
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
                    // TODO: 선택한 프로젝트들 삭제 로직 호출
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
                    // TODO: 선택한 프로젝트들 옮기기 로직 호출
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
    HomeView(vm: HomeViewModel(coordinator: AppCoordinator()))
        .environment(\.managedObjectContext, CoreDataManager.preview.mainContext)
}

