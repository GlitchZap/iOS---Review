//
//  Milestone.swift
//  ParentBud_01
//
//  Created by Aayush Kumar on 12/11/25.
//

import Foundation

// MARK: - Milestone Model
struct Milestone: Codable, Identifiable {
    let id: String
    let title: String
    let icon: String
    let ageGroups: [AgeGroup]
    let category: MilestoneCategory
    let isComingSoon: Bool
    
    enum AgeGroup: String, Codable {
        case toddler = "2-4 years (toddler & preschool years)"
        case earlySchool = "5-7 years (early school years)"
        case growing = "8-10 years (growing independence years)"
        case all = "all"
    }
    
    enum MilestoneCategory: String, Codable {
        case memory = "Memory"
        case development = "Development"
        case health = "Health"
        case learning = "Learning"
    }
}

// MARK: - Milestone Manager
class MilestoneManager {
    static let shared = MilestoneManager()
    
    private let allMilestones: [Milestone] = [
        // Toddler Milestones (2-4 years)
        Milestone(
            id: "milestone_001",
            title: "Click photos of your baby every month",
            icon: "photo",
            ageGroups: [.all],
            category: .memory,
            isComingSoon: false
        ),
        Milestone(
            id: "milestone_002",
            title: "Track your child’s height and growth over time",
            icon: "ruler",
            ageGroups: [.all],
            category: .development,
            isComingSoon: false
        ),
        Milestone(
            id: "milestone_003",
            title: "Record your child’s first words and funny phrases",
            icon: "book.closed",
            ageGroups: [.toddler],
            category: .development,
            isComingSoon: false
        ),
        Milestone(
            id: "milestone_004",
            title: "Keep a simple potty training progress chart",
            icon: "checkmark.circle",
            ageGroups: [.toddler],
            category: .development,
            isComingSoon: false
        ),
        Milestone(
            id: "milestone_005",
            title: "Track baby teeth coming in and falling out",
            icon: "mouth",
            ageGroups: [.toddler, .earlySchool],
            category: .health,
            isComingSoon: false
        ),
        Milestone(
            id: "milestone_006",
            title: "Log your child’s sleep times and nap routines",
            icon: "moon.zzz",
            ageGroups: [.toddler, .all],
            category: .health,
            isComingSoon: false
        ),
        Milestone(
            id: "milestone_007",
            title: "Save memories from your child’s first day at school",
            icon: "calendar.badge.plus",
            ageGroups: [.toddler, .earlySchool],
            category: .memory,
            isComingSoon: false
        ),
        Milestone(
            id: "milestone_008",
            title: "Note your child’s favorite meals and snacks",
            icon: "fork.knife",
            ageGroups: [.toddler, .all],
            category: .health,
            isComingSoon: false
        ),
        
        // Early School Milestones (5-7 years)
        Milestone(
            id: "milestone_009",
            title: "Track reading progress and favorite storybooks",
            icon: "text.book.closed",
            ageGroups: [.earlySchool, .growing],
            category: .learning,
            isComingSoon: false
        ),
        Milestone(
            id: "milestone_010",
            title: "Mark each tooth your child loses with a smile",
            icon: "star.circle",
            ageGroups: [.earlySchool],
            category: .health,
            isComingSoon: false
        ),
        Milestone(
            id: "milestone_011",
            title: "Celebrate school awards and classroom achievements",
            icon: "trophy",
            ageGroups: [.earlySchool, .growing],
            category: .learning,
            isComingSoon: false
        ),
        Milestone(
            id: "milestone_012",
            title: "Record your child’s first time riding a bicycle",
            icon: "bicycle",
            ageGroups: [.earlySchool, .growing],
            category: .development,
            isComingSoon: false
        ),
        Milestone(
            id: "milestone_013",
            title: "Track swimming lessons and milestones",
            icon: "figure.pool.swim",
            ageGroups: [.earlySchool, .growing],
            category: .development,
            isComingSoon: false
        ),
        Milestone(
            id: "milestone_014",
            title: "Save your child’s artwork and creative projects",
            icon: "paintpalette",
            ageGroups: [.earlySchool, .growing, .all],
            category: .learning,
            isComingSoon: false
        ),
        Milestone(
            id: "milestone_015",
            title: "Keep samples to see handwriting improvement",
            icon: "pencil.line",
            ageGroups: [.earlySchool, .growing],
            category: .learning,
            isComingSoon: false
        ),
        Milestone(
            id: "milestone_016",
            title: "Log fun science experiments done at home",
            icon: "flask",
            ageGroups: [.earlySchool, .growing],
            category: .learning,
            isComingSoon: false
        ),
        
        // Growing Independence Milestones (8-10 years)
        Milestone(
            id: "milestone_017",
            title: "Track math challenges your child masters",
            icon: "function",
            ageGroups: [.growing],
            category: .learning,
            isComingSoon: false
        ),
        Milestone(
            id: "milestone_018",
            title: "Record your child’s sports wins and practice goals",
            icon: "sportscourt",
            ageGroups: [.growing, .all],
            category: .development,
            isComingSoon: false
        ),
        Milestone(
            id: "milestone_019",
            title: "Track music lessons and practice sessions",
            icon: "music.note",
            ageGroups: [.growing, .all],
            category: .learning,
            isComingSoon: false
        ),
        Milestone(
            id: "milestone_020",
            title: "Save your child’s first coding or STEM projects",
            icon: "chevron.left.forwardslash.chevron.right",
            ageGroups: [.growing],
            category: .learning,
            isComingSoon: false
        ),
        Milestone(
            id: "milestone_021",
            title: "Write short book reviews together after reading",
            icon: "books.vertical",
            ageGroups: [.growing, .all],
            category: .learning,
            isComingSoon: false
        ),
        Milestone(
            id: "milestone_022",
            title: "Build a responsibility chart with daily chores",
            icon: "checklist",
            ageGroups: [.growing, .all],
            category: .development,
            isComingSoon: false
        ),
        Milestone(
            id: "milestone_023",
            title: "Capture fun memories with friends and playdates",
            icon: "person.2",
            ageGroups: [.growing, .all],
            category: .memory,
            isComingSoon: false
        ),
        Milestone(
            id: "milestone_024",
            title: "Create a travel journal for family trips",
            icon: "airplane",
            ageGroups: [.growing, .all],
            category: .memory,
            isComingSoon: false
        ),
        
        // Universal Milestones (All Ages)
        Milestone(
            id: "milestone_025",
            title: "Save birthday photos and memories each year",
            icon: "gift",
            ageGroups: [.all],
            category: .memory,
            isComingSoon: false
        ),
        Milestone(
            id: "milestone_026",
            title: "Write about family traditions and celebrations",
            icon: "heart.circle",
            ageGroups: [.all],
            category: .memory,
            isComingSoon: false
        ),
        Milestone(
            id: "milestone_027",
            title: "Keep track of vaccinations and health updates",
            icon: "cross.case",
            ageGroups: [.all],
            category: .health,
            isComingSoon: false
        ),
        Milestone(
            id: "milestone_028",
            title: "Log doctor visits and health notes easily",
            icon: "stethoscope",
            ageGroups: [.all],
            category: .health,
            isComingSoon: false
        ),
        Milestone(
            id: "milestone_029",
            title: "Record video messages and milestones over time",
            icon: "video",
            ageGroups: [.all],
            category: .memory,
            isComingSoon: false
        ),
        Milestone(
            id: "milestone_030",
            title: "Save voice clips of your child’s laughter and stories",
            icon: "waveform",
            ageGroups: [.all],
            category: .memory,
            isComingSoon: false
        )
    ]
    
    private init() {}
    
    // MARK: - Get Milestones for Age Group
    func getMilestones(for ageGroup: String?) -> [Milestone] {
        guard let ageGroup = ageGroup else {
            return allMilestones.filter { $0.ageGroups.contains(.all) }.shuffled()
        }
        
        let filtered = allMilestones.filter { milestone in
            milestone.ageGroups.contains(where: { $0.rawValue == ageGroup }) ||
            milestone.ageGroups.contains(.all)
        }
        
        return filtered.shuffled()
    }
    
    // MARK: - Get Featured Milestones (for home screen - 2 items)
    func getFeaturedMilestones(for ageGroup: String?) -> [Milestone] {
        let allAvailable = getMilestones(for: ageGroup)
        return Array(allAvailable.prefix(2))
    }
    
    // MARK: - Get All Milestones
    func getAllMilestones() -> [Milestone] {
        return allMilestones
    }
}
