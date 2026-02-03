//
//  Community.swift
//  ParentBud_01
//
//  Created by Aayush Kumar on 13/12/25.
//


// CommunityModels.swift

import Foundation

// MARK: - Community Model
struct Community: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var description:  String
    var icon: String // SF Symbol name or emoji
    var memberCount: Int
    var type: CommunityType
    var isJoined: Bool
    var createdAt: Date
    
    enum CommunityType: String, Codable {
        case local = "Local"
        case global = "Global"
    }
    
    init(id: UUID = UUID(),
         name: String,
         description: String,
         icon:  String,
         memberCount: Int,
         type: CommunityType,
         isJoined: Bool = false,
         createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.memberCount = memberCount
        self.type = type
        self.isJoined = isJoined
        self.createdAt = createdAt
    }
}

// MARK: - Post Model
struct CommunityPost: Codable, Identifiable, Hashable {
    let id: UUID
    var authorName: String
    var authorAvatar: String?  // URL or system name
    var communityId: UUID
    var communityName: String
    var content: String
    var imageURL: String?
    var likeCount: Int
    var commentCount: Int
    var isLiked: Bool
    var isSaved: Bool
    var createdAt: Date
    
    init(id: UUID = UUID(),
         authorName: String,
         authorAvatar: String?  = nil,
         communityId: UUID,
         communityName: String,
         content: String,
         imageURL: String?  = nil,
         likeCount: Int = 0,
         commentCount: Int = 0,
         isLiked: Bool = false,
         isSaved: Bool = false,
         createdAt: Date = Date()) {
        self.id = id
        self.authorName = authorName
        self.authorAvatar = authorAvatar
        self.communityId = communityId
        self.communityName = communityName
        self.content = content
        self.imageURL = imageURL
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.isLiked = isLiked
        self.isSaved = isSaved
        self.createdAt = createdAt
    }
    
    var timeAgoDisplay: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}

// MARK: - Community Guidelines Model
struct CommunityGuidelines: Codable {
    let guidelines: [String]
    var hasAccepted: Bool
    var acceptedAt: Date? 
    
    init(guidelines: [String] = [
        "Share experiences, not medical advice",
        "Be kind and supportive to all parents",
        "Respect privacy - no names or identifying details",
        "Keep discussions relevant to parenting",
        "Report inappropriate content",
        "No spam, promotions, or commercial content"
    ], hasAccepted: Bool = false, acceptedAt: Date? = nil) {
        self.guidelines = guidelines
        self.hasAccepted = hasAccepted
        self.acceptedAt = acceptedAt
    }
}
