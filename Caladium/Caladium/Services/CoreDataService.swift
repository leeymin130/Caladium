//
//  CoreDataService.swift
//  Caladium
//
//  Created by yoomin on 6/10/25.
//

import CoreData
import Foundation
import UIKit

final class CoreDataService {
    
    // MARK: 의존성 주입시 각 ViewModel에서 동일한 인스턴스 공유하도록 설계
    let context: NSManagedObjectContext
    let coreDataManager: CoreDataManager
    
    init(coreDataManager: CoreDataManager = .shared){
        self.context = coreDataManager.mainContext
        self.coreDataManager = coreDataManager
    }
    
    // MARK: -  Project & Photo 메서드
    /// ViewModel 계층에서 엔티티 업데이트에 따른 별도의 상태관리 하지 않도록
    /// Fetch 같은 경우 @FetchRequest 활용해서 View 단에서 처리게 함

    // 새 프로젝트 생성
    func createProject(category: Category) {
        _ = Project(context: context, category: category)
        coreDataManager.saveContext()
        print("프로젝트 생성")
    }
    
    // 프로젝트 삭제
    func deleteProject(_ project: Project) {
        // 연관된 사진 먼저 모두 삭제
        if let photos = project.photos as? Set<Photo>{
            try? deletePhotos(Array(photos))
        }
        context.delete(project)
        coreDataManager.saveContext()
    }
    
    // 새 사진 생성 (파일과 함께)
    func createPhoto(image: UIImage, fileName: String? = nil, project: Project) throws {
        // 고유한 파일명 생성
        let uniqueFileName = fileName ?? "\(UUID().uuidString).jpg"
        
        // 파일 저장
        try saveImageToFile(image, fileName: uniqueFileName)
        
        // CoreData에 메타데이터 저장
        _ = Photo(context: context, fileName: uniqueFileName, project: project)
        project.updateTimestamp() // 프로젝트의 업데이트 시간도 갱신
        
        coreDataManager.saveContext()
    }
    
    // 사진 삭제 (파일 함께 삭제)
    func deletePhotos(_ photos: [Photo]) throws {
        guard let project = photos.first?.project else {return}
        
        for photo in photos {
            // 파일 삭제
            if let fileURL = photo.getFileURL() {
                try? FileManager.default.removeItem(at: fileURL)
            }
            
            // 프로젝트 업데이트 시간 갱신
            project.updateTimestamp()
            
            // CoreData에서 삭제
            context.delete(photo)
        }
        
        coreDataManager.saveContext()
    }
    
    /// 사진을 다른 프로젝트로 이동
    func movePhoto(_ photo: Photo, to project: Project) {
        let oldProject = photo.project
        photo.project = project
        
        // 양쪽 프로젝트의 업데이트 시간 갱신
        oldProject?.updateTimestamp()
        project.updateTimestamp()
        
        coreDataManager.saveContext()
    }
    
    // MARK: - FileManager 이미지 파일 매니저 저장을 위한 메서드
    private func saveImageToFile(_ image: UIImage, fileName: String) throws {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw CoreDataServiceError.imageConversionFailed
        }
        
        let fileURL = try getPhotosDirectoryURL().appendingPathComponent(fileName)
        
        // 디렉토리가 존재하지 않으면 생성
        let directoryURL = fileURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: directoryURL.path) {
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        }
        
        try imageData.write(to: fileURL)
    }
    
    /// 파일에서 이미지 로드
    func loadImageFromFile(fileName: String) -> UIImage? {
        guard let fileURL = try? getPhotosDirectoryURL().appendingPathComponent(fileName) else { return nil }
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    /// 사진 디렉토리 URL 반환
    private func getPhotosDirectoryURL() throws -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("Photos")
    }
    
    // MARK: - Custom Errors

    enum CoreDataServiceError: Error, LocalizedError {
        case imageConversionFailed
        case fileNotFound
        case directoryCreationFailed
        
        var errorDescription: String? {
            switch self {
            case .imageConversionFailed:
                return "이미지를 데이터로 변환하는데 실패했습니다."
            case .fileNotFound:
                return "파일을 찾을 수 없습니다."
            case .directoryCreationFailed:
                return "디렉토리 생성에 실패했습니다."
            }
        }
    }
}
// MARK: - Data Validation & Mock data
extension CoreDataService {
    
    /// 데이터 무결성 검사 (파일과 CoreData 동기화 체크)
    func validateDataIntegrity() throws {
        let allPhotos = try fetchAllPhotos()
        var orphanedFiles: [URL] = []
        var missingFiles: [Photo] = []
        
        // CoreData 레코드는 있지만 파일이 없는 경우 찾기
        for photo in allPhotos {
            if let fileURL = photo.getFileURL() {
                if !FileManager.default.fileExists(atPath: fileURL.path) {
                    missingFiles.append(photo)
                }
            }
        }
        
        // 파일은 있지만 CoreData 레코드가 없는 경우 찾기
        let photosDirectory = try getPhotosDirectoryURL()
        if FileManager.default.fileExists(atPath: photosDirectory.path) {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: photosDirectory, includingPropertiesForKeys: nil)
            let registeredFileNames = Set(allPhotos.compactMap { $0.fileName })
            
            for fileURL in fileURLs {
                let fileName = fileURL.lastPathComponent
                if !registeredFileNames.contains(fileName) {
                    orphanedFiles.append(fileURL)
                }
            }
        }
        
        // 로그 출력
        if !missingFiles.isEmpty {
            print("Missing files for \(missingFiles.count) photos")
        }
        if !orphanedFiles.isEmpty {
            print("Found \(orphanedFiles.count) orphaned files")
        }
    }
    
    /// 고아 파일들 정리
    func cleanupOrphanedFiles() throws {
        let allPhotos = try fetchAllPhotos()
        let registeredFileNames = Set(allPhotos.compactMap { $0.fileName })
        
        let photosDirectory = try getPhotosDirectoryURL()
        guard FileManager.default.fileExists(atPath: photosDirectory.path) else { return }
        
        let fileURLs = try FileManager.default.contentsOfDirectory(at: photosDirectory, includingPropertiesForKeys: nil)
        
        for fileURL in fileURLs {
            let fileName = fileURL.lastPathComponent
            if !registeredFileNames.contains(fileName) {
                try FileManager.default.removeItem(at: fileURL)
                print("Deleted orphaned file: \(fileName)")
            }
        }
    }
    
    /// 모든 프로젝트 조회
    private func fetchAllProjects() throws -> [Project] {
        let request: NSFetchRequest<Project> = Project.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "updatedDate", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        return try context.fetch(request)
    }
    
    /// 모든 사진 조회
    private func fetchAllPhotos() throws -> [Photo] {
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "capturedDate", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        return try context.fetch(request)
    }
    
    /// entity 초기화 메서드
    func deleteAllData() {
        let container = coreDataManager.persistentContainer
        
        // 모든 엔티티 이름 가져오기
        let entityNames = container.managedObjectModel.entities.compactMap { $0.name }
        
        for entityName in entityNames {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try container.persistentStoreCoordinator.execute(batchDeleteRequest, with: context)
            } catch {
                print("Error deleting \(entityName) records: \(error)")
            }
        }
        
        // 메모리의 컨텍스트 상태 초기화
        context.reset()
    }
    
    /// Mock data
    func createMockData() {
        // 각 카테고리별로 프로젝트 생성
        for category in Category.allCases {
            for _ in 1...3 {
                createProject(category: category)
            }
        }
        
        // 모든 프로젝트에 사진 추가
        if let allProjects = try? fetchAllProjects() {
            for project in allProjects {
                // 각 프로젝트마다 3-7개의 랜덤한 수의 사진 추가
                let photoCount = Int.random(in: 3...7)
                
                for i in 1...photoCount {
                    // 다양한 색상의 샘플 이미지 생성
                    let mockImage = UIImage(systemName: "photo") ?? UIImage()

                    do {
                        try createPhoto(image: mockImage, project: project)
                        print("Added photo \(i) to project \(project.categoryEnum.rawValue)")
                    } catch {
                        print("Failed to create photo for project \(project.categoryEnum.rawValue): \(error)")
                    }
                }
            }
        }
    }
    
}
