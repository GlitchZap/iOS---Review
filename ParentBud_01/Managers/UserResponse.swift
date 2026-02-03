//
//  UserResponse.swift
//  ParentBud_01
//
//  Created by Aayush Kumar on 13/11/25.
//


//
//  UserResponse.swift
//  ParentBud_01
//
//  Created by GlitchZap on 2025-11-13
//

import Foundation

// MARK: - User Response Model
struct UserResponse: Codable {
    var questionId: String
    var selectedOptions: [String]  // For single/multi-select
    var textInput: String?         // For text input
    var timestamp: Date
    
    init(questionId: String, selectedOptions: [String] = [], textInput: String? = nil) {
        self.questionId = questionId
        self.selectedOptions = selectedOptions
        self.textInput = textInput
        self.timestamp = Date()
    }
}