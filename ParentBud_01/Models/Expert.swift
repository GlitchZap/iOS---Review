//
//  Expert.swift
//  ParentBud_01
//
//  Created by Aayush Kumar on 16/11/25
//


import Foundation

// MARK: - Expert Model
struct Expert: Codable, Identifiable {
    let id: UUID
    var name: String
    var title: String
    var specialization: String
    var certifications: [String]
    var bio: String
    var rating: Double
    var reviewCount: Int
    var photoURL: String? // In production, this would be an actual URL
    var photoName: String? // For local assets
    var availableTimeSlots: [TimeSlot]
    var expertise: [String]
    var createdAt: Date
    
    init(id: UUID = UUID(),
         name: String,
         title: String,
         specialization: String,
         certifications: [String],
         bio: String,
         rating: Double,
         reviewCount: Int,
         photoURL: String? = nil,
         photoName: String? = nil,
         availableTimeSlots: [TimeSlot] = [],
         expertise: [String] = [],
         createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.title = title
        self.specialization = specialization
        self.certifications = certifications
        self.bio = bio
        self.rating = rating
        self.reviewCount = reviewCount
        self.photoURL = photoURL
        self.photoName = photoName
        self.availableTimeSlots = availableTimeSlots
        self.expertise = expertise
        self.createdAt = createdAt
    }
    
    var initials: String {
        let components = name.components(separatedBy: " ")
        let firstInitial = components.first?.first?.uppercased() ?? ""
        let lastInitial = components.count > 1 ? (components.last?.first?.uppercased() ?? "") : ""
        return firstInitial + lastInitial
    }
}

// MARK: - Time Slot Model
struct TimeSlot: Codable, Identifiable {
    let id: UUID
    var date: Date
    var startTime: String // "09:00"
    var endTime: String   // "10:00"
    var isAvailable: Bool
    
    init(id: UUID = UUID(),
         date: Date,
         startTime: String,
         endTime: String,
         isAvailable: Bool = true) {
        self.id = id
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.isAvailable = isAvailable
    }
    
    var displayTime: String {
        return "\(startTime) - \(endTime)"
    }
}

// MARK: - Expert Review Model
struct ExpertReview: Codable, Identifiable {
    let id: UUID
    let expertId: UUID
    let userId: String
    let parentName: String
    var rating: Double
    var reviewText: String
    var createdAt: Date
    
    init(id: UUID = UUID(),
         expertId: UUID,
         userId: String,
         parentName: String,
         rating: Double,
         reviewText: String,
         createdAt: Date = Date()) {
        self.id = id
        self.expertId = expertId
        self.userId = userId
        self.parentName = parentName
        self.rating = rating
        self.reviewText = reviewText
        self.createdAt = createdAt
    }
}

// MARK: - Session Model
struct ExpertSession: Codable, Identifiable {
    let id: UUID
    let expertId: UUID
    let userId: String
    var sessionDate: Date
    var timeSlot: TimeSlot
    var status: SessionStatus
    var notes: String?
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(),
         expertId: UUID,
         userId: String,
         sessionDate: Date,
         timeSlot: TimeSlot,
         status: SessionStatus = .scheduled,
         notes: String? = nil,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.expertId = expertId
        self.userId = userId
        self.sessionDate = sessionDate
        self.timeSlot = timeSlot
        self.status = status
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

enum SessionStatus: String, Codable {
    case scheduled = "Scheduled"
    case completed = "Completed"
    case cancelled = "Cancelled"
    case inProgress = "In Progress"
}

// MARK: - Chat Message Model
struct ChatMessage: Codable, Identifiable {
    let id: UUID
    let sessionId: UUID
    let senderId: String // userId or expertId
    let senderType: SenderType
    var message: String
    var timestamp: Date
    var isRead: Bool
    
    init(id: UUID = UUID(),
         sessionId: UUID,
         senderId: String,
         senderType: SenderType,
         message: String,
         timestamp: Date = Date(),
         isRead: Bool = false) {
        self.id = id
        self.sessionId = sessionId
        self.senderId = senderId
        self.senderType = senderType
        self.message = message
        self.timestamp = timestamp
        self.isRead = isRead
    }
}

enum SenderType: String, Codable {
    case user = "user"
    case expert = "expert"
}

// MARK: - Chat Thread Model
struct ChatThread: Codable, Identifiable {
    let id: UUID
    let sessionId: UUID
    let expertId: UUID
    var messages: [ChatMessage]
    var lastMessage: ChatMessage?
    var unreadCount: Int
    var isTyping: Bool
    var updatedAt: Date
    
    init(id: UUID = UUID(),
         sessionId: UUID,
         expertId: UUID,
         messages: [ChatMessage] = [],
         lastMessage: ChatMessage? = nil,
         unreadCount: Int = 0,
         isTyping: Bool = false,
         updatedAt: Date = Date()) {
        self.id = id
        self.sessionId = sessionId
        self.expertId = expertId
        self.messages = messages
        self.lastMessage = lastMessage
        self.unreadCount = unreadCount
        self.isTyping = isTyping
        self.updatedAt = updatedAt
    }
}
