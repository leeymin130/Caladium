//
//  ContentView.swift
//  Caladium
//
//  Created by yoomin on 6/3/25.
//

import SwiftUI

// Caladium/ContentView.swift
import SwiftUI
import CoreData // Core Data 관련 클래스 사용을 위해 필요

struct ContentView: View {
    // @Environment를 사용하여 Core Data 컨텍스트를 주입받습니다.
    @Environment(\.managedObjectContext) private var viewContext
    
    // @FetchRequest를 사용하여 Core Data에서 Project 데이터를 자동으로 가져옵니다.
    // sortDescriptors를 통해 정렬 방식을 지정할 수 있습니다.
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Project.createdDate, ascending: true)],
        animation: .default)
    private var projects: FetchedResults<Project> // Project 엔티티의 인스턴스 배열
    
    var body: some View {
        NavigationView {
            List {
                // MARK: - Read (프로젝트 목록 표시)
                ForEach(projects) { project in
                    VStack(alignment: .leading) {
                        Text(project.name ?? "이름 없음").font(.headline)
                        Text("카테고리: \(Category(rawValue: project.category ?? "")?.displayName ?? "알 수 없음")")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("생성일: \(project.createdDate ?? Date(), formatter: dateFormatter)")
                            .font(.caption)
                        Text("수정일: \(project.updatedDate ?? Date(), formatter: dateFormatter)")
                            .font(.caption)
                        
                        // MARK: - Add Photo (사진 추가)
                        Button("사진 추가") {
                            addPhoto(to: project)
                        }
                        .font(.caption)
                        .padding(.vertical, 2)
                        
                        // 해당 프로젝트의 사진 목록
                        if let photos = project.photos as? Set<Photo>, !photos.isEmpty {
                            VStack(alignment: .leading) {
                                Text("📸 사진 목록:")
                                ForEach(Array(photos).sorted(by: { ($0.capturedDate ?? Date()) < ($1.capturedDate ?? Date()) })) { photo in
                                    HStack {
                                        Text(" - \(photo.fileName ?? "파일 없음")")
                                        Spacer()
                                        // MARK: - Delete Photo (사진 삭제)
                                        Button("삭제") {
                                            deletePhoto(photo)
                                        }
                                        .font(.caption)
                                        .foregroundColor(.red)
                                    }
                                }
                            }
                            .padding(.leading, 10)
                        } else {
                            Text("등록된 사진 없음").font(.caption).foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 5)
                    .contextMenu { // 컨텍스트 메뉴를 통한 수정/삭제
                        // MARK: - Update (프로젝트 수정)
                        Button("이름 변경") {
                            updateProjectName(project)
                        }
                        // MARK: - Delete (프로젝트 삭제)
                        Button("삭제") {
                            deleteProject(project)
                        }
                        .foregroundColor(.red)
                    }
                }
                .onDelete(perform: deleteProjects) // 스와이프 투 삭제 (프로젝트)
            }
            .navigationTitle("내 프로젝트")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // MARK: - Create (새 프로젝트 생성)
                    Button("새 프로젝트") {
                        createProject()
                    }
                }
                // MARK: - 모든 데이터 삭제 버튼 추가
                ToolbarItem(placement: .navigationBarLeading) { // 왼쪽에 배치
                    Button("모든 데이터 삭제") {
                        deleteAllProjects()
                    }
                    .foregroundColor(.red) // 삭제 버튼은 빨간색으로
                }
            }
        }
    }
    
    // MARK: - Core Data CRUD Operations
    
    // Create Project
    private func createProject() {
        let newProject = Project(context: viewContext)
        newProject.id = UUID()
        newProject.name = "새 프로젝트 \(projects.count + 1)"
        newProject.category = Category.allCases.randomElement()?.rawValue ?? Category.garden.rawValue // 랜덤 카테고리
        newProject.createdDate = Date()
        newProject.updatedDate = Date()
        
        saveContext()
    }
    
    // Update Project Name
    private func updateProjectName(_ project: Project) {
        // 실제 앱에서는 alert 등을 띄워 사용자 입력을 받겠지만, 테스트를 위해 임의로 변경
        project.name = "수정된 \(project.name ?? "")"
        project.updatedDate = Date() // 수정일 업데이트
        saveContext()
    }
    
    // Delete Project (단일 삭제)
    private func deleteProject(_ project: Project) {
        viewContext.delete(project)
        saveContext()
    }
    
    // Delete Projects (여러 개 삭제, List의 onDelete 용도)
    private func deleteProjects(offsets: IndexSet) {
        offsets.map { projects[$0] }.forEach(viewContext.delete)
        saveContext()
    }
    
    // Add Photo to Project
    private func addPhoto(to project: Project) {
        let newPhoto = Photo(context: viewContext)
        newPhoto.id = UUID()
        newPhoto.fileName = "photo_\(UUID().uuidString.prefix(6)).jpg" // 임의의 파일 이름
        newPhoto.capturedDate = Date()
        newPhoto.project = project // 관계 설정
        
        // project.addToPhotos(newPhoto) // 관계를 직접 추가하는 방법도 있지만, 양방향 관계 설정 시 Core Data가 자동으로 처리
        
        saveContext()
    }
    
    // Delete Photo
    private func deletePhoto(_ photo: Photo) {
        viewContext.delete(photo)
        saveContext()
    }
    
    // 컨텍스트 저장 유틸리티 함수
    private func saveContext() {
        do {
            try viewContext.save()
            print("Context saved successfully!")
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
            // 실제 앱에서는 사용자에게 오류를 알리는 등의 처리가 필요합니다.
        }
    }
    
    // 모든 프로젝트와 연관된 사진 삭제 함수 추가
        private func deleteAllProjects() {
            for project in projects {
                viewContext.delete(project)
            }
            saveContext()
            print("모든 프로젝트 데이터가 삭제되었습니다.") // 삭제 확인 메시지 (필요시 주석 처리)
        }
    
    // 날짜 포맷터 (보기 좋게 표시하기 위함)
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}

// MARK: - Preview Provider (Xcode Canvas 미리보기용)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // 프리뷰에서 Core Data 컨텍스트를 제공하기 위한 설정
        ContentView().environment(\.managedObjectContext, CoreDataStack.shared.context)
    }
}

//#Preview {
//    ContentView()
//}
