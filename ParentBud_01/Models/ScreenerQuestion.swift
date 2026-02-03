//
//  ScreenerQuestion.swift
//  ParentBud_01
//
//  Created by Aayush Kumar on 07/11/25.
//

import Foundation

// MARK: - Screener Question Model
/// Represents a single screener question with its metadata
struct ScreenerQuestion: Codable, Identifiable {
    let id: String
    let questionTitle: String
    let questionSubtitle: String
    let questionType: QuestionType
    let options: [String]
    let isRequired: Bool
    let category: QuestionCategory
    
    /// Type of question determines UI and validation
    enum QuestionType: String, Codable {
        case singleChoice = "single_choice"      // Radio buttons - one selection
        case multipleChoice = "multiple_choice"  // Checkboxes - multiple selections
        case textInput = "text_input"           // Text field input
    }
    
    /// Category helps organize questions by topic
    enum QuestionCategory: String, Codable {
        case parentInfo = "parent_info"
        case childInfo = "child_info"
        case familyDynamics = "family_dynamics"
        case supportNeeds = "support_needs"
    }
}


