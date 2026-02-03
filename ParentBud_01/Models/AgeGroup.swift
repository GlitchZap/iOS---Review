//
//  AgeGroup.swift
//  ParentBud_01
//
//  Created by Aayush Kumar on 13/11/25.
//


import Foundation

enum AgeGroup: String, Codable, CaseIterable {
    case toddler = "Toddler (1-3 years)"
    case preschool = "Preschool (3-5 years)"
    case schoolAge = "School Age (5-12 years)"
    
    var displayName: String {
        return self.rawValue
    }
    
    var shortName: String {
        switch self {
        case .toddler:
            return "Toddler"
        case .preschool:
            return "Preschool"
        case .schoolAge:
            return "School Age"
        }
    }
}
