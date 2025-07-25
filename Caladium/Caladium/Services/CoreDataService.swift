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
    func createNewProject(category:Category, image: UIImage){
        let newProject = Project(context: context, category: category)
        do {
            let fixedImage = image.fixedOrientation()
            try createPhoto(image: fixedImage, project: newProject)
        } catch(let error) {
            print(error.localizedDescription)
        }
        
    }
    
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
        let fixedImage = image.fixedOrientation()

        // 고유한 파일명 생성
        let uniqueFileName = fileName ?? "\(UUID().uuidString).jpg"
        
        // 파일 저장
        try saveImageToFile(fixedImage, fileName: uniqueFileName)
        
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
    
    /// 프로젝트를 다른 카테고리로 변경
    func moveCategory(_ project: Project, to category: Category) {
        project.categoryEnum = category
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
    
    /// Mock data 생성 - 다양한 이미지로 애니메이션 테스트 가능
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
                // 각 프로젝트마다 5-8개의 다양한 사진 추가
                let photoCount = Int.random(in: 5...8)
                
                for i in 1...photoCount {
                    // 다양한 스타일의 Mock 이미지 생성
                    let mockImage = MockImageGenerator.createSFSymbolImage(
                        index: i,
                        category: project.categoryEnum
                    )
                    
                    do {
                        try createPhoto(image: mockImage, project: project)
                        print("Added varied photo \(i) to project \(project.categoryEnum.rawValue)")
                    } catch {
                        print("Failed to create photo for project \(project.categoryEnum.rawValue): \(error)")
                    }
                }
            }
        }
    }
    
}


// MARK: - SF Symbol Mock Image Generator
struct MockImageGenerator {
    
    /// SF Symbol을 사용한 Mock 이미지 생성
    static func createSFSymbolImage(index: Int, category: Category) -> UIImage {
        let symbols = getSFSymbolsForCategory(category)
        let colors = getColorsForCategory(category)
        
        // 인덱스에 따라 다른 심볼과 색상 선택
        let symbolName = symbols[index % symbols.count]
        let color = colors[index % colors.count]
        
        // SF Symbol 이미지 생성
        let config = UIImage.SymbolConfiguration(pointSize: 200, weight: .medium)
        let image = UIImage(systemName: symbolName, withConfiguration: config)?
            .withTintColor(color, renderingMode: .alwaysOriginal)
        
        // 배경이 있는 이미지로 변환
        return createImageWithBackground(symbol: image, backgroundColor: getBackgroundColor(for: index), index: index)
    }
    
    // MARK: - 카테고리별 SF Symbol 목록
    private static func getSFSymbolsForCategory(_ category: Category) -> [String] {
        switch category {
        case .garden:
            return [
                "leaf", "leaf.fill", "tree", "tree.fill",
                "sun.max", "sun.max.fill", "cloud.rain",
                "drop", "drop.fill", "sparkles"
            ]
        case .desert:
            return [
                "heart", "heart.fill", "star", "star.fill",
                "circle", "circle.fill", "diamond", "diamond.fill",
                "crown", "crown.fill"
            ]
        case .rooftop:
            return [
                "tree", "tree.fill", "leaf", "leaf.fill",
                "rectangle", "rectangle.fill", "triangle", "triangle.fill",
                "circle", "oval.fill"
            ]
        case .jungle:
            return [
                "leaf", "leaf.fill", "drop", "drop.fill",
                "circle", "oval", "diamond", "square",
                "heart", "star"
            ]
        }
    }
    
    // MARK: - 카테고리별 색상 목록
    private static func getColorsForCategory(_ category: Category) -> [UIColor] {
        switch category {
        case .garden:
            return [.systemGreen, .systemYellow, .systemOrange, .systemBrown]
        case .rooftop:
            return [.systemPink, .systemPurple, .systemRed, .systemIndigo]
        case .desert:
            return [.systemGreen, .systemBrown, .systemYellow, .systemOrange]
        case .jungle:
            return [.systemGreen, .systemMint, .systemTeal, .systemCyan]
        }
    }
    
    // MARK: - 배경 색상
    private static func getBackgroundColor(for index: Int) -> UIColor {
        let backgrounds: [UIColor] = [
            .systemGray6, .systemGray5, .systemGray4,
            UIColor(white: 0.95, alpha: 1.0),
            UIColor(white: 0.92, alpha: 1.0),
            UIColor(white: 0.88, alpha: 1.0)
        ]
        return backgrounds[index % backgrounds.count]
    }
    
    // MARK: - 배경이 있는 이미지 생성
    private static func createImageWithBackground(
        symbol: UIImage?,
        backgroundColor: UIColor,
        index: Int
    ) -> UIImage {
        let size = CGSize(width: 300, height: 400)
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let cgContext = context.cgContext
            
            // 배경색 칠하기
            cgContext.setFillColor(backgroundColor.cgColor)
            cgContext.fill(CGRect(origin: .zero, size: size))
            
            // SF Symbol 그리기
            if let symbol = symbol {
                let symbolSize = symbol.size
                let x = (size.width - symbolSize.width) / 2
                let y = (size.height - symbolSize.height) / 2
                
                symbol.draw(at: CGPoint(x: x, y: y))
            }
            
            // 인덱스 번호 추가
            addIndexText(context: cgContext, index: index, size: size)
        }
    }
    
    // MARK: - 인덱스 텍스트 추가
    private static func addIndexText(context: CGContext, index: Int, size: CGSize) {
        let text = "\(index)"
        let font = UIFont.systemFont(ofSize: 28, weight: .bold)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.white,
            .strokeColor: UIColor.black,
            .strokeWidth: -3
        ]
        
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        let textSize = attributedText.size()
        
        let textRect = CGRect(
            x: size.width - textSize.width - 15,
            y: 15,
            width: textSize.width,
            height: textSize.height
        )
        
        attributedText.draw(in: textRect)
    }
}
