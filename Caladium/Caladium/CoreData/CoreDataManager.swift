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
