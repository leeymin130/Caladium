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
        ScrollView {
            VStack(spacing: 20) {
                // 프로젝트 정보
                VStack(spacing: 10) {
                    Text("📊 프로젝트 정보")
                        .font(.title2)
                        .bold()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("카테고리: \(project.categoryEnum.displayName)")
                        Text("생성일: \(project.createdDate?.formatted() ?? "")")
                        Text("마지막 업데이트: \(project.updatedDate?.formatted() ?? "")")
                        Text("사진 수: \(photos.count)장")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // 액션 버튼들
                VStack(spacing: 12) {
                    Button {
//                        coordinator.addPhotoToProject(project)
                    } label: {
                        Label("사진 추가", systemImage: "camera")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    if photos.count >= 2 {
                        Button {
                        } label: {
                            Label("영상 만들기", systemImage: "video")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                // 사진 그리드
                if !photos.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("📷 사진들")
                            .font(.title2)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 10) {
                            ForEach(photos, id: \.id) { photo in
                                Button {
                                } label: {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.3))
                                        .aspectRatio(1, contentMode: .fit)
                                        .overlay {
                                            VStack {
                                                Image(systemName: "photo")
                                                Text(photo.capturedDate?.formatted(date: .abbreviated, time: .omitted) ?? "")
                                                    .font(.caption2)
                                            }
                                            .foregroundColor(.gray)
                                        }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("프로젝트 상세")
        .navigationBarTitleDisplayMode(.inline)
    }
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

#Preview {
    let context = CoreDataManager.preview.mainContext
    let sampleProject = getSampleProject(from: context)
    
    return ProjectDetailView(
        vm: ProjectDetailViewModel(coordinator: AppCoordinator()),
        project: sampleProject
    )
    .environment(\.managedObjectContext, context)
}
