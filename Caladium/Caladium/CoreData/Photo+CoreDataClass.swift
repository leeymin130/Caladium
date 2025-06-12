//
//  Photo+CoreDataClass.swift
//  Caladium
//
//  Created by yoomin on 6/10/25.
//
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {
    
    // 편의 초기화
    convenience init(context: NSManagedObjectContext, fileName: String, project: Project) {
        self.init(context: context)
        self.id = UUID()
        self.fileName = fileName
        self.capturedDate = Date()
        self.project = project
    }
    
    // 파일 경로 생성
    func getFileURL() -> URL? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return documentsDirectory?.appendingPathComponent("Photos").appendingPathComponent(fileName ?? "")
    }
    
}
