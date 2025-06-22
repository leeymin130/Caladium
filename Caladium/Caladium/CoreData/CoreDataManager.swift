//
//  CoreDataStack.swift
//  Caladium
//
//  Created by yoomin on 6/10/25.
//

import CoreData
import Foundation

final class CoreDataManager {
    
    static let shared = CoreDataManager()
    private init(){}
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Caladium")
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Failed to load persistent stores: \(error.localizedDescription)")
            }
        }
        return container
    }()
    
    lazy var mainContext: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    func saveContext() {
        saveContext(mainContext)
    }
    
    func saveContext(_ context: NSManagedObjectContext) {
        if context.parent == mainContext {
            saveDerivedContext(context)
            return
        }
        
        context.perform {
            do {
                try context.save()
            } catch let error as NSError {
                //TODO: 에러 처리
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    func saveDerivedContext(_ context: NSManagedObjectContext) {
        context.perform { [self] in
            do {
                try context.save()
            } catch let error as NSError {
                //TODO: 에러 처리 
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            
            saveContext(mainContext)
        }
    }
    
    func saveInBackground(context: NSManagedObjectContext, completion: ((Error?) -> Void)? = nil) {
        if context.hasChanges {
            do {
                try context.save()
                DispatchQueue.main.async {
                    completion?(nil)
                }
            } catch {
                let nsError = error as NSError
                print("Background save error \(nsError), \(nsError.userInfo)")
                DispatchQueue.main.async {
                    completion?(error)
                }
            }
        } else {
            DispatchQueue.main.async {
                completion?(nil)
            }
        }
    }
}


extension CoreDataManager {
    
    // 프리뷰용 인메모리 컨테이너
    static var preview: CoreDataManager = {
        let manager = CoreDataManager()
        
        // 인메모리 스토어로 설정
        let container = NSPersistentContainer(name: "Caladium")
        container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        container.persistentStoreDescriptions.first?.type = NSInMemoryStoreType
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Preview Core Data error: \(error)")
            }
        }
        
        manager.persistentContainer = container
        
        // 프리뷰용 샘플 데이터 생성
        manager.generatePreviewData()
        
        return manager
    }()
    
    // 프리뷰용 샘플 데이터 생성
    private func generatePreviewData() {
        let context = mainContext
        
        // 각 카테고리별로 프로젝트 생성
        for category in Category.allCases {
            for i in 1...10 {
                let project = Project(context: context, category: category)
                project.id = UUID()
                project.category = category.rawValue
                project.createdDate = Date().addingTimeInterval(-Double(i * 3600))
                project.updatedDate = Date().addingTimeInterval(-Double(i * 1800))
                
                // 각 프로젝트에 사진 몇 개 추가 (메타데이터만)
                for j in 1...3 {
                    let photo = Photo(context: context)
                    photo.id = UUID()
                    photo.fileName = "preview_photo_\(i)_\(j).jpg"
                    photo.capturedDate = Date().addingTimeInterval(-Double(j * 3600))
                    photo.project = project
                }
            }
        }
        
        do {
            try context.save()
        } catch {
            print("Preview data creation failed: \(error)")
        }
    }
}
