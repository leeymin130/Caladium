//
//  ProjectDetailView.swift
//  Caladium
//
//  Created by 이종선 on 6/22/25.
//

import SwiftUI
import CoreData

// MARK: - Project Detail View
struct ProjectDetailView: View {
    
    @StateObject private var vm: ProjectDetailViewModel
    
    let project: Project
    @FetchRequest private var photos: FetchedResults<Photo>
    
    init(vm: ProjectDetailViewModel, project: Project) {
        self._vm = StateObject(wrappedValue: vm)
        self.project = project
        self._photos = FetchRequest(
            entity: Photo.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Photo.capturedDate, ascending: true)],
            predicate: NSPredicate(format: "project == %@", project)
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            photoGrid
                .overlay(alignment: .bottomTrailing){
                    cameraButton
                        .padding()
                }
            
            //            bottomToolbar
            BottomToolbar(
                projectEditMode: vm.editMode,
                style: .projectDetail,
                hasItems: !photos.isEmpty,
                onDeleteStart: vm.startDeleteMode,
                onMoveStart: {}, // ProjectDetail에서는 사용하지 않음
                onCancel: vm.exitEditMode,
                onDeleteConfirm: {
                    // TODO: 선택한 사진들 삭제 로직 호출
                },
                onMoveConfirm: {}, // ProjectDetail에서는 사용하지 않음
                onVideoStart: vm.startVideoMode,
                onVideoConfirm: {
                    // TODO: 비디오 만들기 로직 호출
                }
            )
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(.container, edges: .bottom)
        //        .toolbar {
        //            ToolbarItem(placement: .principal) {
        //                Text(dateRangeText)
        //                    .font(.subheadline) // 또는 .caption, .footnote
        //                    .foregroundColor(.primary)
        //            }
        //        }
        
    }
    
    // MARK: - Photo Grid
    
    private var photoGrid: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: 3), spacing: 3) {
                ForEach(photos, id: \.objectID) { photo in
                    photoGridItem(photo: photo)
                }
            }
            .padding(.horizontal, 1)
            
        }
    }
    
    private func photoGridItem(photo: Photo) -> some View {
        ZStack {
            AsyncPhotoImage(photo: photo)
                .frame(width:128, height: 128)
                .clipped()
                .onTapGesture {
                    if vm.isEditMode {
                        vm.togglePhotoSelection(photo)
                    } else {
                        // TODO: 사진 상세보기로 이동
                        vm.navigateToPhotoDetail(photo: photo, project: project)
                    }
                }
            
            // 선택 표시
            if vm.isEditMode {
                VStack {
                    HStack {
                        Spacer()
                        Circle()
                            .fill(vm.isPhotoSelected(photo) ? Color.blue : Color.clear)
                            .stroke(Color.white, lineWidth: 2)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .opacity(vm.isPhotoSelected(photo) ? 1 : 0)
                            )
                            .padding(8)
                    }
                    Spacer()
                }
            }
        }
    }
    
    private var cameraButton: some View {
        HStack(alignment: .center,spacing: 18){
            Image(systemName: "camera.fill")
                .font(.system(size: 30, weight: .medium))
                .foregroundColor(.white)
                .background{
                    Rectangle()
                        .fill(Color.green500)
                        .frame(width: 60, height: 60)
                    
                }
                .padding(.leading, 8)
            
            VStack(spacing: 4){
                Text("새로운 사진")
                    .font(.caption)
                    .foregroundStyle(.primary)
                Text("촬영하기")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.leading,10)
            
            
        }
        .onTapGesture {
            vm.addNewPhoto(currentProject: project)
        }
        .frame(width: 158, height: 58, alignment: .leading)
        .background{
            Rectangle()
                .fill(Color.white)
            
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray400, lineWidth: 2)
        )
        
        
    }
    
    
    //    private var bottomToolbar: some View {
    //        HStack {
    //            
    //            switch vm.editMode {
    //            case .normal:
    //                Button {
    //                    vm.startDeleteMode()
    //                } label: {
    //                    VStack {
    //                        Image(systemName: "trash")
    //                            .font(.title2)
    //                        Text("지우기")
    //                            .font(.caption)
    //                    }
    //                    .foregroundColor(.red)
    //                }
    //                .disabled(photos.isEmpty)
    //                
    //                Spacer()
    //                
    //                Button {
    //                    vm.startVideoMode()
    //                } label: {
    //                    VStack {
    //                        Image(systemName: "folder")
    //                            .font(.title2)
    //                        Text("옮기기")
    //                            .font(.caption)
    //                    }
    //                }
    //                .disabled(photos.isEmpty)
    //
    //            case .delete(_):
    //                Button {
    //                    vm.exitEditMode()
    //                } label: {
    //                    VStack{
    //                        Image(systemName: "xmark")
    //                            .font(.title2)
    //                        Text("취소")
    //                            .font(.caption)
    //                    }
    //                }
    //                
    //                Spacer()
    //                
    //                if vm.selectedProjectsCount > 0 {
    //                    Text("\(vm.selectedProjectsCount)개 선택됨")
    //                        .font(.caption)
    //                        .foregroundColor(.secondary)
    //                }
    //                
    //                Spacer()
    //                
    //                Button {
    //                   // TODO: 선택한 프로젝트들 삭제 로직 호출
    //                } label: {
    //                    VStack{
    //                        Image(systemName: "checkmark")
    //                            .font(.title2)
    //                        Text("확인")
    //                            .font(.caption)
    //                    }
    //                }
    //
    //            case .makeVideo(_):
    //                Button {
    //                    vm.exitEditMode()
    //                } label: {
    //                    VStack{
    //                        Image(systemName: "xmark")
    //                            .font(.title2)
    //                        Text("취소")
    //                            .font(.caption)
    //                    }
    //                }
    //                
    //                Spacer()
    //                
    //                if vm.selectedProjectsCount > 0 {
    //                    Text("\(vm.selectedProjectsCount)개 선택됨")
    //                        .font(.caption)
    //                        .foregroundColor(.secondary)
    //                }
    //                
    //                Spacer()
    //                
    //                Button {
    //                    // TODO: 비디오 만들기 로직 호출
    //                } label: {
    //                    VStack{
    //                        Image(systemName: "checkmark")
    //                            .font(.title2)
    //                        Text("확인")
    //                            .font(.caption)
    //                    }
    //                }
    //            }
    //            
    //        }
    //        .padding(.horizontal, 40)
    //        .padding(.vertical, 16)
    //        .background(Color(.systemBackground))
    //        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: -1)
    //        
    //    }
    
    
    private var dateRangeText: String {
        let formatter = Date.FormatStyle()
            .year()
            .month(.wide)
            .day()
            .locale(Locale(identifier: "ko_KR"))
        
        let startDate = project.createdDate?.formatted(formatter) ?? ""
        let endDate = project.updatedDate?.formatted(formatter) ?? ""
        
        return "\(startDate) ~ \(endDate)"
    }
}




#Preview {
    let context = CoreDataManager.preview.mainContext
    let sampleProject = getSampleProject(from: context)
    
    return ProjectDetailView(
        vm: ProjectDetailViewModel(coordinator: AppCoordinator()),
        project: sampleProject
    )
    .environment(\.managedObjectContext, context)
}


// Preview 밖에서 helper 함수 정의
private func getSampleProject(from context: NSManagedObjectContext) -> Project {
    let fetchRequest: NSFetchRequest<Project> = Project.fetchRequest()
    fetchRequest.fetchLimit = 1
    
    if let existingProject = try? context.fetch(fetchRequest).first {
        return existingProject
    }
    
    // 없으면 새로 생성
    let project = Project(context: context)
    project.id = UUID()
    project.createdDate = Date()
    project.updatedDate = Date()
    project.category = Category.rooftop.rawValue
    return project
}
