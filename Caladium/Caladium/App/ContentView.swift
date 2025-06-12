//
//  ContentView.swift
//  Caladium
//
//  Created by yoomin on 6/3/25.
//

import SwiftUI
import CoreData


struct ContentView: View {
    var body: some View {
        CoreDataTestView()
    }
}

// MARK: - ViewModel
class TestViewModel: ObservableObject {
    private let coreDataService = CoreDataService()
    
    func createProject() {
        coreDataService.createProject(category: .garden)
    }
    
    func deleteProject(_ project: Project) {
        coreDataService.deleteProject(project)
    }
     
    func addPhoto(to project: Project) {
        let mockImage = UIImage(systemName: "photo.fill") ?? UIImage()
        try? coreDataService.createPhoto(image: mockImage, project: project)
    }
    
    func deletePhotos(_ photos: [Photo]) {
        print("=== deletePhotos 호출됨 ===")
        print("삭제 요청된 사진 수: \(photos.count)")
        photos.forEach { photo in
            print("삭제 대상: \(photo.fileName ?? "Unknown")")
        }
        
        // 스택 트레이스 출력
        print("호출 스택:")
        Thread.callStackSymbols.forEach { print($0) }
        
        try? coreDataService.deletePhotos(photos)
    }
}

// MARK: - Main Test View
struct CoreDataTestView: View {
    @StateObject private var viewModel = TestViewModel()
    
    // @FetchRequest로 프로젝트 가져오기
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Project.updatedDate, ascending: false)]
    ) var projects: FetchedResults<Project>
    
    var body: some View {
        NavigationView {
            VStack {
                // 프로젝트 생성 버튼
                Button("프로젝트 생성") {
                    viewModel.createProject()
                }
                .buttonStyle(.borderedProminent)
                .padding()
                
                // 총 개수 표시
                Text("총 프로젝트: \(projects.count)개")
                    .font(.headline)
                    .padding()
                
                // 프로젝트 목록
                List {
                    ForEach(projects) { project in
                        ProjectTestRow(project: project, viewModel: viewModel)
                    }
                    .onDelete(perform: deleteProjects)
                }
            }
            .navigationTitle("CoreData 테스트")
        }
    }
    
    private func deleteProjects(offsets: IndexSet) {
        for index in offsets {
            viewModel.deleteProject(projects[index])
        }
    }
}

// MARK: - Project Row
struct ProjectTestRow: View {
    let project: Project
    let viewModel: TestViewModel
    @State private var selectedPhotoID: NSManagedObjectID?
    
    // 해당 프로젝트의 사진들만 가져오기
    @FetchRequest var photos: FetchedResults<Photo>
    
    init(project: Project, viewModel: TestViewModel) {
        self.project = project
        self.viewModel = viewModel
        
        let predicate = NSPredicate(format: "project == %@", project)
        self._photos = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Photo.capturedDate, ascending: false)],
            predicate: predicate
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 프로젝트 정보
            HStack {
                VStack(alignment: .leading) {
                    Text("프로젝트 ID: \(project.id?.uuidString.prefix(8) ?? "Unknown")")
                        .font(.headline)
                    Text("카테고리: \(project.categoryEnum.displayName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text("사진 \(photos.count)개")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // 사진 추가 버튼
            Button("사진 추가") {
                viewModel.addPhoto(to: project)
            }
            .buttonStyle(.bordered)
            
            // 사진 목록 - LazyVStack 사용
            if !photos.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("사진 목록:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    // ForEach 대신 개별 뷰로 분리
                    LazyVStack(alignment: .leading, spacing: 2) {
                        ForEach(photos, id: \.objectID) { photo in
                            PhotoRowView(
                                photo: photo,
                                onDelete: {
                                    viewModel.deletePhotos([photo])
                                }
                            )
                        }
                    }
                }
                .padding(.leading, 10)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Photo Row (분리된 뷰)
struct PhotoRowView: View {
    let photo: Photo
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Text(photo.fileName ?? "Unknown")
                .font(.caption)
            Spacer()
            Button(action: onDelete) {
                Text("삭제")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle()) // 터치 영역 명시
        }
        .background(Color.clear) // 배경 추가로 터치 영역 격리
    }
}
