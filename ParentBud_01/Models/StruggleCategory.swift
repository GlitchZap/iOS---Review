//
//  StruggleCategory.swift
//  ParentBud_01
//
//  Created by Aayush Kumar on 08/11/25.
//

import Foundation

struct StruggleCategory: Codable, Identifiable {
    let id: UUID
    let name: String
    let subcategories: [String]
    let ageGroups: [AgeGroup]
    let icon: String
    let color: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, subcategories, ageGroups, icon, color
    }
    
    init(id: UUID = UUID(), name: String, subcategories: [String], ageGroups: [AgeGroup], icon: String, color: String) {
        self.id = id
        self.name = name
        self.subcategories = subcategories
        self.ageGroups = ageGroups
        self.icon = icon
        self.color = color
    }
}

// MARK: - Predefined Struggle Categories
extension StruggleCategory {
    static let allCategories: [StruggleCategory] = [
        StruggleCategory(
            name: "Sleep Routines",
            subcategories: ["Bedtime Resistance", "Night Wakings", "Nap Refusal", "Early Rising"],
            ageGroups: [.toddler, .preschool, .schoolAge],
            icon: "moon.stars.fill",
            color: "#9B8AFB"
        ),
        StruggleCategory(
            name: "Tantrums",
            subcategories: ["Meltdowns", "Defiance", "Hitting/Kicking", "Screaming"],
            ageGroups: [.toddler, .preschool, .schoolAge],
            icon: "exclamationmark.triangle.fill",
            color: "#FF6B6B"
        ),
        StruggleCategory(
            name: "Eating Habits",
            subcategories: ["Picky Eating", "Mealtime Battles", "Food Refusal", "Snacking Issues"],
            ageGroups: [.toddler, .preschool, .schoolAge],
            icon: "fork.knife",
            color: "#4ECDC4"
        ),
        StruggleCategory(
            name: "Screen Time",
            subcategories: ["Device Battles", "TV Time", "Gaming Limits", "Screen Addiction"],
            ageGroups: [.toddler, .preschool, .schoolAge],
            icon: "tv.fill",
            color: "#FFB84D"
        ),
        StruggleCategory(
            name: "Potty Training",
            subcategories: ["Accidents", "Resistance", "Regression", "Public Restrooms"],
            ageGroups: [.toddler, .preschool],
            icon: "toilet.fill",
            color: "#A8E6CF"
        ),
        StruggleCategory(
            name: "Social Skills",
            subcategories: ["Sharing", "Turn-Taking", "Playing with Others", "Making Friends"],
            ageGroups: [.toddler, .preschool, .schoolAge],
            icon: "person.3.fill",
            color: "#FFD93D"
        ),
        StruggleCategory(
            name: "Separation Anxiety",
            subcategories: ["Daycare Drop-off", "Clingy Behavior", "School Refusal", "Stranger Anxiety"],
            ageGroups: [.toddler, .preschool, .schoolAge],
            icon: "heart.fill",
            color: "#FF9CEE"
        ),
        StruggleCategory(
            name: "Focus and Attention",
            subcategories: ["Homework Time", "Following Directions", "Staying Seated", "Listening"],
            ageGroups: [.preschool, .schoolAge],
            icon: "target",
            color: "#6BCF7F"
        ),
        StruggleCategory(
            name: "Behavior Management",
            subcategories: ["Discipline", "Consequences", "Time-Outs", "Reward Systems"],
            ageGroups: [.toddler, .preschool, .schoolAge],
            icon: "star.fill",
            color: "#B6E4FF"
        )
    ]
}
