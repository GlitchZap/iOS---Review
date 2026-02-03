//
//  ScreenerQuestionsData.swift
//  ParentBud_01
//
//  Created by Aayush Kumar on 07/11/25
//

import Foundation

// MARK: - Screener Questions Mock Data
class ScreenerQuestionsData {
    
    static let questions: [ScreenerQuestion] = [
        // SECTION 1: Tell us about yourself (Q1-Q4)
        
        // Question 1: Parent Role
        ScreenerQuestion(
            id: "q1",
            questionTitle: "Tell us about yourself",
            questionSubtitle: "How would you describe your role in the child's care?",
            questionType: .singleChoice,
            options: ["Parent", "Single Parent", "Caregiver"],
            isRequired: true,
            category: .parentInfo
        ),
        
        // Question 2: Family Structure
        ScreenerQuestion(
            id: "q2",
            questionTitle: "Tell us about yourself",
            questionSubtitle: "Every parent needs a support system. Could you describe the kind of family village you rely on?",
            questionType: .singleChoice,
            options: ["Nuclear Family", "Joint Family"],
            isRequired: true,
            category: .familyDynamics
        ),
        
        // Question 3: Employment Status
        ScreenerQuestion(
            id: "q3",
            questionTitle: "Tell us about yourself",
            questionSubtitle: "Which of the following best describe your current employment status?",
            questionType: .singleChoice,
            options: ["Working", "Not Working"],
            isRequired: true,
            category: .parentInfo
        ),
        
        // Question 4: Child Age Group
        ScreenerQuestion(
            id: "q4",
            questionTitle: "Tell us about yourself",
            questionSubtitle: "Which stage of childhood are you currently navigating with your little one?",
            questionType: .singleChoice,
            options: [
                "2-4 years (toddler & preschool years)",
                "5-7 years (early school years)",
                "8-10 years (growing independence years)"
            ],
            isRequired: true,
            category: .childInfo
        ),
        
        // SECTION 2: Tell us about your little one (Q5-Q7)
        
        // Question 5: Child Name
        ScreenerQuestion(
            id: "q5",
            questionTitle: "Tell us about your little one",
            questionSubtitle: "What is your Child's name (or nickname)",
            questionType: .textInput,
            options: [],
            isRequired: true,
            category: .childInfo
        ),
        
        // Question 6: Child Temperament
        ScreenerQuestion(
            id: "q6",
            questionTitle: "Tell us about your little one",
            questionSubtitle: "Every child is unique. How would you describe their general temperament?",
            questionType: .multipleChoice,
            options: ["Easy Going", "Sensitive", "Spirited", "Cautious", "Mixed Traits"],
            isRequired: true,
            category: .childInfo
        ),
        
        // Question 7: Support Areas
        ScreenerQuestion(
            id: "q7",
            questionTitle: "Tell us about your little one",
            questionSubtitle: "What areas would you like support with? (Select all that apply)",
            questionType: .multipleChoice,
            options: [
                "Sleep Routines",
                "Tantrums",
                "Screen Time",
                "Eating Habits",
                "Potty Training",
                "Social Skills",
                "Separation Anxiety",
                "Behavior Management"
            ],
            isRequired: true,
            category: .supportNeeds
        )
    ]
}
