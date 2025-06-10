//
//  Photo+CoreDataProperties.swift
//  Caladium
//
//  Created by yoomin on 6/10/25.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var fileName: String?
    @NSManaged public var capturedDate: Date?
    @NSManaged public var project: Project?

}

extension Photo : Identifiable {

}
