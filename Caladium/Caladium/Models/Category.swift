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
    case rooftop = "rooftop"
    case desert = "desert"
    
    var displayName: String {
        switch self {
        case .garden:
            return "정원"
        case .jungle:
            return "정글"
        case .rooftop:
            return "옥상"
        case .desert:
            return "사막"
        }
    }
    
    var icon: String {
        switch self {
        case .garden: return "category-garden"
        case .jungle: return "category-jungle"
        case .rooftop: return "category-roof"
        case .desert: return "category-desert"
        }
    }
    
    var background: String {
        switch self {
        case .garden: return "bg-garden"
        case .jungle: return "bg-jungle"
        case .rooftop: return "bg-roof"
        case .desert: return "bg-desert"
        }
    }

}
