//
//  TestViewModel.swift
//  Caladium
//
//  Created by yoomin on 6/12/25.
//

import Foundation
import CoreData
import Combine

class TestViewModel: ObservableObject {
    // @Published: projects 배열이 바뀌면 View에 자동으로 알림
    @Published var projects: [Project] = []
    
    // Core Data의 컨텍스트. 저장, fetch 등 모든 작업에 필요
    private var context: NSManagedObjectContext
    
    // ViewModel 생성자: 외부에서 context를 주입받음 (테스트, 모듈화 용이)
    // 의존성 주입 패턴으로 테스트하기 용이한 구조
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchProjects()  // 생성 시 바로 데이터를 fetch
    }
    
    // 프로젝트 목록 불러오기
    func fetchProjects() {
        let request: NSFetchRequest<Project> = Project.fetchRequest()
        // createdDate를 기준으로 오름차순 정렬
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Project.createdDate, ascending: true)]
        do {
            // Core Data에서 fetch 시도 → 성공하면 projects에 할당 → View에 반영됨
            projects = try context.fetch(request)
        } catch {
            // 오류 발생 시 디버그용 출력
            print("프로젝트 fetch 실패: \(error.localizedDescription)")
        }
    }
    
    // 새 프로젝트 생성
    func createProject() {
        let newProject = Project(context: context)
        newProject.id = UUID()
        newProject.name = "새 프로젝트 \(projects.count + 1)"
        newProject.category = Category.allCases.randomElement()?.rawValue ?? "garden"
        newProject.createdDate = Date()
        newProject.updatedDate = Date()
        saveContext()  // context에 저장
        fetchProjects()  // 최신 데이터로 다시 불러옴: context.save()를 호출하지 않으면 실제로 변경사항이 저장되지 않음 -> 저장 후 다시 fetch하면 ViewModel의 projects 배열이 최신상태가 됨 -> 뷰가 자동으로 리렌더링
    }
    
    // 프로젝트 이름 변경
    func updateProjectName(_ project: Project) {
        project.name = "수정된 \(project.name ?? "")"
        project.updatedDate = Date()
        saveContext()
        fetchProjects()
    }
    
    // 특정 프로젝트 삭제
    func deleteProject(_ project: Project) {
        context.delete(project)
        saveContext()
        fetchProjects()
    }
    
    // 전체 프로젝트 삭제
    func deleteAllProjects() {
        for project in projects {
            context.delete(project)
        }
        saveContext()
        fetchProjects()
    }
    
    // 특정 프로젝트에 사진 추가
    func addPhoto(to project: Project) {
        let newPhoto = Photo(context: context)
        newPhoto.id = UUID()
        newPhoto.fileName = "photo_\(UUID().uuidString.prefix(6)).jpg"
        newPhoto.capturedDate = Date()
        newPhoto.project = project  // Project의 photos Set에 newPhoto를 자동으로 추가하도록 Core Data가 처리
        saveContext()
        fetchProjects()
    }
    
    // 특정 사진 삭제
    func deletePhoto(_ photo: Photo) {
        let projectId = photo.project?.id // 삭제 전 프로젝트의 ID를 저장
        
        context.delete(photo)  // photo 객체 삭제
        saveContext()  // 변경사항 저장
        fetchProjects()  // 배열 갱신 및 UI 업데이트
        
        // 디버깅 로그: 삭제 후 해당 프로젝트의 사진 수 확인
        if let id = projectId,
           let updatedProject = projects.first(where: { $0.id == id }) {
            print("프로젝트 '\(updatedProject.name ?? "이름 없음")'의 남은 사진 수: \(updatedProject.photos?.count ?? 0)")
        } else {
            print("삭제된 사진의 프로젝트를 찾을 수 없거나 프로젝트가 삭제되었습니다.")
        }
    }
    
    // Core Data context를 저장하는 공통 함수
    private func saveContext() {
        do {
            try context.save()
            print("Context 저장 성공!")
        } catch {
            print("저장 실패: \(error.localizedDescription)")
            // 더 자세한 오류 정보 출력
            let nsError = error as NSError
            print("🔴 userInfo: \(nsError.userInfo)")
        }
    }
}
