//
//  Project+CoreDataClass.swift
//  Caladium
//
//  Created by yoomin on 6/10/25.
//
//

import Foundation
import CoreData

@objc(Project)
public class Project: NSManagedObject {
    
    // Category enum 연동
    var categoryEnum: Category {
        get {
            return Category(rawValue: category ?? "") ?? .garden
        }
        set {
            category = newValue.rawValue
        }
    }
    
    // 편의 초기화
    convenience init(context: NSManagedObjectContext, category: Category) {
        self.init(context: context)
        self.id = UUID()
        self.category = category.rawValue
        self.createdDate = Date()
        self.updatedDate = Date()
    }
    
    // 업데이트 메서드
    func updateTimestamp() {
        self.updatedDate = Date()
    }
    
    // 사진 개수
    var photoCount: Int {
        return photos?.count ?? 0
    }
    
}
