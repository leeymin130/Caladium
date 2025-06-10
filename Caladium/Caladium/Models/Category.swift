//
//  Category.swift
//  Caladium
//
//  Created by yoomin on 6/9/25.
//

import Foundation

enum Category: String, CaseIterable {
    case garden = "garden"
    case jungle = "jungle"
    case desert = "desert"
    case rooftop = "rooftop"
    
    var displayName: String {
        switch self {
        case .garden:
            return "정원"
        case .jungle:
            return "정글"
        case .desert:
            return "사막"
        case .rooftop:
            return "옥상"
        }
    }
}
