//
//  CoreDataTestManager.swift
//  Caladium
//
//  Created by yoomin on 6/11/25.
//

import Foundation
import CoreData
import SwiftUI

class CoreDataTestManager: ObservableObject {
    
    private let coreDataStack = CoreDataStack.shared
    @Published var testResults: [String] = []
    
    private func log(_ message: String) {
        print(message)
        DispatchQueue.main.async {
            self.testResults.append(message)
        }
    }
    
    // MARK: - CREATE 테스트
    
    func createProject(name: String, category: Category) -> Project {
        let project = Project(context: coreDataStack.context, name: name, category: category)
        coreDataStack.saveContext()
        log("✅ Project 생성 완료: \(name)")
        return project
    }
    
    func createPhoto(fileName: String, for project: Project) -> Photo {
        let photo = Photo(context: coreDataStack.context, fileName: fileName, project: project)
        coreDataStack.saveContext()
        print("✅ Photo 생성 완료: \(fileName)")
        return photo
    }
    
    // MARK: - READ 테스트
    
    func fetchAllProjects() -> [Project] {
        let request: NSFetchRequest<Project> = Project.fetchRequest()
        
        do {
            let projects = try coreDataStack.context.fetch(request)
            print("✅ 총 \(projects.count)개의 프로젝트 조회")
            return projects
        } catch {
            print("❌ 프로젝트 조회 실패: \(error)")
            return []
        }
    }
    
    func fetchPhotos(for project: Project) -> [Photo] {
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        request.predicate = NSPredicate(format: "project == %@", project)
        
        do {
            let photos = try coreDataStack.context.fetch(request)
            print("✅ 프로젝트 '\(project.name)'에 \(photos.count)개의 사진 조회")
            return photos
        } catch {
            print("❌ 사진 조회 실패: \(error)")
            return []
        }
    }
    
    func fetchProjectsByCategory(_ category: Category) -> [Project] {
        let request: NSFetchRequest<Project> = Project.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@", category.rawValue)
        
        do {
            let projects = try coreDataStack.context.fetch(request)
            print("✅ '\(category.displayName)' 카테고리에 \(projects.count)개의 프로젝트 조회")
            return projects
        } catch {
            print("❌ 카테고리별 프로젝트 조회 실패: \(error)")
            return []
        }
    }
    
    // MARK: - UPDATE 테스트
    
    func updateProject(_ project: Project, newName: String? = nil, newCategory: Category? = nil) {
        if let newName = newName {
            project.name = newName
        }
        if let newCategory = newCategory {
            project.categoryEnum = newCategory
        }
        project.updateTimestamp()
        coreDataStack.saveContext()
        print("✅ 프로젝트 업데이트 완료: \(project.name)")
    }
    
    // MARK: - DELETE 테스트
    
    func deleteProject(_ project: Project) {
        coreDataStack.context.delete(project)
        coreDataStack.saveContext()
        print("✅ 프로젝트 삭제 완료")
    }
    
    func deletePhoto(_ photo: Photo) {
        coreDataStack.context.delete(photo)
        coreDataStack.saveContext()
        print("✅ 사진 삭제 완료")
    }
    
    // MARK: - 테스트 실행 메서드
    
    func runAllTests() {
        print("🚀 Core Data CRUD 테스트 시작")
        
        // 1. Project 생성
        let project1 = createProject(name: "우리집 정원", category: .garden)
        let project2 = createProject(name: "아마존 정글", category: .jungle)
        
        // 2. Photo 생성
        let photo1 = createPhoto(fileName: "garden_001.jpg", for: project1)
        let photo2 = createPhoto(fileName: "garden_002.jpg", for: project1)
        let photo3 = createPhoto(fileName: "jungle_001.jpg", for: project2)
        
        // 3. 조회 테스트
        let allProjects = fetchAllProjects()
        for project in allProjects {
            print("📁 프로젝트: \(project.name) (\(project.categoryEnum.displayName)) - 사진 \(project.photoCount)개")
        }
        
        let gardenProjects = fetchProjectsByCategory(.garden)
        print("🌱 정원 프로젝트 수: \(gardenProjects.count)")
        
        let project1Photos = fetchPhotos(for: project1)
        print("📸 '\(project1.name)' 프로젝트의 사진들:")
        for photo in project1Photos {
            print("  - \(photo.fileName)")
        }
        
        // 4. 업데이트 테스트
        updateProject(project1, newName: "우리집 예쁜 정원")
        
        // 5. 삭제 테스트 (주석 처리 - 필요시 주석 해제)
        // deletePhoto(photo1)
        // deleteProject(project2)
        
        print("✅ 모든 테스트 완료!")
    }
}
