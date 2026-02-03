//
//  GuidanceModels.swift
//  ParentBud_01
//
//  Created by GlitchZap on 2025-11-13
//

import Foundation

struct GuidanceStep: Codable, Identifiable {
    let id: UUID
    var stepNumber: Int
    var title: String
    var description: String
    var tips: [String]
    var isCompleted: Bool
    var completedAt: Date?
    var notes: String?
    
    init(id: UUID = UUID(),
         stepNumber: Int,
         title: String,
         description: String,
         tips: [String] = [],
         isCompleted: Bool = false,
         completedAt: Date? = nil,
         notes: String? = nil) {
        self.id = id
        self.stepNumber = stepNumber
        self.title = title
        self.description = description
        self.tips = tips
        self.isCompleted = isCompleted
        self.completedAt = completedAt
        self.notes = notes
    }
}

enum GuidanceApproach: String, Codable {
    case cbtPcit = "CBT + PCIT Approach"
    case alternative = "Alternative Approach"
    
    var displayName: String {
        return self.rawValue
    }
}

struct GuidanceSession: Codable, Identifiable {
    let id: UUID
    let logEntryId: UUID
    let userId: UUID
    let struggles: [String]
    var currentApproach: GuidanceApproach
    var currentStepIndex: Int
    var steps: [GuidanceStep]
    var startedAt: Date
    var completedAt: Date?
    var isCompleted: Bool
    
    init(id: UUID = UUID(),
         logEntryId: UUID,
         userId: UUID,
         struggles: [String],
         currentApproach: GuidanceApproach = .cbtPcit,
         currentStepIndex: Int = 0,
         steps: [GuidanceStep],
         startedAt: Date = Date(),
         completedAt: Date? = nil,
         isCompleted: Bool = false) {
        self.id = id
        self.logEntryId = logEntryId
        self.userId = userId
        self.struggles = struggles
        self.currentApproach = currentApproach
        self.currentStepIndex = currentStepIndex
        self.steps = steps
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.isCompleted = isCompleted
    }
}
