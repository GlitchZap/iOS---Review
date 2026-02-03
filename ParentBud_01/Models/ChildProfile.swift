//
//  ChildProfile.swift
//  ParentBud_01
//
//  Created by Aayush Kumar on 2025-11-17
//

import Foundation

struct ChildProfile: Codable, Identifiable {
    let id: UUID
    var name: String
    var age: Int?
    var temperament: [String]?
    var ageGroup: String?
    var supportAreas: [String]?
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(),
         name: String,
         age: Int? = nil,
         temperament: [String]? = nil,
         ageGroup: String? = nil,
         supportAreas: [String]? = nil,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.age = age
        self.temperament = temperament
        self.ageGroup = ageGroup
        self.supportAreas = supportAreas
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
