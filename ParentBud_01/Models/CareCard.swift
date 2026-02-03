//
//  CareCard.swift
//  ParentBud_01
//
//  Created by Aayush Kumar on 2025-11-15
//

import Foundation
import UIKit

// MARK: - Care Card Model

struct CareCard: Codable, Identifiable, Hashable {
    let id: UUID
    let title: String
    let summary: String
    let category: CareCardCategory
    let ageGroups: [AgeGroup]
    let tags: [String]
    
    // Personalization
    let personalizedScore: Double
    let relevanceReason: String?
    
    // Visual
    let imageName: String
    let gradientColors: [String] // Hex colors
    
    // Content (for stacked cards)
    let contentCards: [ContentCard]
    
    // Metadata
    let isTrending: Bool
    var isSaved: Bool
    let readingTimeMinutes: Int
    let createdAt: Date
    
    init(id: UUID = UUID(),
         title: String,
         summary: String,
         category: CareCardCategory,
         ageGroups: [AgeGroup],
         tags: [String],
         personalizedScore: Double = 0.0,
         relevanceReason: String? = nil,
         imageName: String,
         gradientColors: [String],
         contentCards: [ContentCard],
         isTrending: Bool = false,
         isSaved: Bool = false,
         readingTimeMinutes: Int = 5,
         createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.summary = summary
        self.category = category
        self.ageGroups = ageGroups
        self.tags = tags
        self.personalizedScore = personalizedScore
        self.relevanceReason = relevanceReason
        self.imageName = imageName
        self.gradientColors = gradientColors
        self.contentCards = contentCards
        self.isTrending = isTrending
        self.isSaved = isSaved
        self.readingTimeMinutes = readingTimeMinutes
        self.createdAt = createdAt
    }
}

// MARK: - Content Card

struct ContentCard: Codable, Identifiable, Hashable {
    let id: UUID
    let text: String
    let order: Int
    
    init(id: UUID = UUID(), text: String, order: Int) {
        self.id = id
        self.text = text
        self.order = order
    }
}

// MARK: - Suggested Article Model

struct SuggestedArticle: Codable, Identifiable, Hashable {
    let id: UUID
    let title: String
    let summary: String
    let category: CareCardCategory
    let sourceURL: String
    let sourceName: String
    let emoji: String            // keep if other cards still use emo
    let gradientColors: [String]
    let isTrending: Bool
    var isSaved: Bool
    let readingTimeMinutes: Int
    let createdAt: Date
    
    init(id: UUID = UUID(),
         title: String,
         summary: String,
         category: CareCardCategory,
         sourceURL: String,
         sourceName: String,
         emoji: String,
         gradientColors: [String],
         isTrending: Bool = true,
         isSaved: Bool = false,
         readingTimeMinutes: Int = 3,
         createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.summary = summary
        self.category = category
        self.sourceURL = sourceURL
        self.sourceName = sourceName
        self.emoji = emoji
        self.gradientColors = gradientColors
        self.isTrending = isTrending
        self.isSaved = isSaved
        self.readingTimeMinutes = readingTimeMinutes
        self.createdAt = createdAt
    }
}

// MARK: - Care Card Category

enum CareCardCategory: String, Codable, CaseIterable {
    case behavior = "Behavior Management"
    case sleep = "Sleep & Routines"
    case nutrition = "Eating Habits"
    case emotional = "Emotional Regulation"
    case social = "Social Skills"
    case tantrums = "Tantrums"
    case confidence = "Confidence Building"
    case screenTime = "Screen Time"
    case separationAnxiety = "Separation Anxiety"
    
    var color: UIColor {
        switch self {
        case .behavior: return UIColor(red: 0.46, green: 0.36, blue: 0.98, alpha: 1.0)
        case .sleep: return UIColor(red: 0.35, green: 0.34, blue: 0.84, alpha: 1.0)
        case .nutrition: return UIColor(red: 0.20, green: 0.78, blue: 0.35, alpha: 1.0)
        case .emotional: return UIColor(red: 1.0, green: 0.41, blue: 0.71, alpha: 1.0)
        case .social: return UIColor(red: 0.35, green: 0.61, blue: 0.92, alpha: 1.0)
        case .tantrums: return UIColor(red: 1.0, green: 0.41, blue: 0.38, alpha: 1.0)
        case .confidence: return UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        case .screenTime: return UIColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 1.0)
        case .separationAnxiety: return UIColor(red: 0.8, green: 0.5, blue: 0.9, alpha: 1.0)
        }
    }
}
