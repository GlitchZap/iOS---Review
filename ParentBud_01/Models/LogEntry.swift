//
//  LogEntry.swift
//  ParentBud_01
//
//  Created by GlitchZap on 2025-11-14
//

import Foundation

enum LogStatus: String, Codable {
    case ongoing = "Ongoing"
    case resolved = "Resolved"
    case unresolved = "Unresolved"
}

enum ApproachOutcome: String, Codable {
    case improved = "Improved!"
    case soSo = "So-So"
    case notGood = "Not Good"
}

struct StepTried: Codable, Identifiable {
    let id: UUID
    var stepDescription: String
    var isCompleted: Bool
    var completedAt: Date?
    var notes: String?
    
    init(id: UUID = UUID(), stepDescription: String, isCompleted: Bool = false, completedAt: Date? = nil, notes: String? = nil) {
        self.id = id
        self.stepDescription = stepDescription
        self.isCompleted = isCompleted
        self.completedAt = completedAt
        self.notes = notes
    }
}

struct LogEntry: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let createdAt: Date
    var updatedAt: Date
    
    var tags: [String]
    var customNote: String?
    var flowTitle: String?
    
    var stepsTried: [StepTried]
    var currentApproachIndex: Int
    
    var totalSteps: Int
    var completedSteps: Int
    
    var status: LogStatus
    var outcome: ApproachOutcome?
    var finalNotes: String?
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        tags: [String],
        customNote: String? = nil,
        flowTitle: String? = nil,
        stepsTried: [StepTried] = [],
        currentApproachIndex: Int = 0,
        totalSteps: Int = 0,
        completedSteps: Int = 0,
        status: LogStatus = .ongoing,
        outcome: ApproachOutcome? = nil,
        finalNotes: String? = nil
    ) {
        self.id = id
        self.userId = userId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.tags = tags
        self.customNote = customNote
        self.flowTitle = flowTitle
        self.stepsTried = stepsTried
        self.currentApproachIndex = currentApproachIndex
        self.totalSteps = totalSteps
        self.completedSteps = completedSteps
        self.status = status
        self.outcome = outcome
        self.finalNotes = finalNotes
    }
    
    var progressText: String {
        if status == .resolved {
            return "Completed ✅"
        } else {
            return "Step \(completedSteps)/\(totalSteps) in Progress"
        }
    }
}
