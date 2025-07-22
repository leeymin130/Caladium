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
    
    // 가장 최근의 Photo 가져오기
    var latestPhoto: Photo? {
        guard let photos = photos as? Set<Photo> else { return nil }
        return photos.max { photo1, photo2 in
            guard let date1 = photo1.capturedDate,
                  let date2 = photo2.capturedDate else {
                return false
            }
            return date1 < date2
        }
    }
}
