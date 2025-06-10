//
//  CoreDataStack.swift
//  Caladium
//
//  Created by yoomin on 6/10/25.
//
import Foundation
import CoreData

// 영구 컨테이너 초기화
class CoreDataStack: ObservableObject {
    static let shared = CoreDataStack()  // 싱글톤 패턴
    
    // 처음 사용할 때 까지 인스턴스를 연기함
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Caladium")
        
        // Load any persistent stores, which creates a store if none exists.
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Failed to load persistent stores: \(error.localizedDescription)")
            }
        }
        return container
    }()
    
    private init() { }
    
    // 스택에 기능 추가하기
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // 변경사항 저장 메서드: 변경사항을 디스크에 반영
    func saveContext() {
        let context = persistentContainer.viewContext
        
        guard context.hasChanges else { return }
            do {
                try context.save()
            } catch {
                print("Failed to save the context: \(error.localizedDescription)")
            }
        }
    
    // 백그라운드 context 생성기: 비동기/무거운 작업을 위한 thread-safe 처리
    func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
}


