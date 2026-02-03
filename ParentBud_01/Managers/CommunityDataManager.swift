//
//  CommunityDataManager.swift
//  ParentBud_01
//
//  Created by Aayush Kumar on 13/12/25.
//


// CommunityDataManager.swift

import Foundation

class CommunityDataManager {
    static let shared = CommunityDataManager()
    
    private let guidelinesKey = "community_guidelines_accepted"
    private let communitiesKey = "user_communities"
    private let postsKey = "community_posts"
    
    private var communities: [Community] = []
    private var posts: [CommunityPost] = []
    private var guidelines: CommunityGuidelines
    
    private init() {
        self.guidelines = CommunityGuidelines()
        loadGuidelines()
        loadCommunities()
        loadPosts()
    }
    
    // MARK: - Guidelines Management
    
    func hasAcceptedGuidelines() -> Bool {
        return guidelines.hasAccepted
    }
    
    func acceptGuidelines() {
        guidelines.hasAccepted = true
        guidelines.acceptedAt = Date()
        saveGuidelines()
    }
    
    func getGuidelines() -> CommunityGuidelines {
        return guidelines
    }
    
    private func saveGuidelines() {
        if let encoded = try? JSONEncoder().encode(guidelines) {
            UserDefaults.standard.set(encoded, forKey: guidelinesKey)
        }
    }
    
    private func loadGuidelines() {
        if let data = UserDefaults.standard.data(forKey: guidelinesKey),
           let decoded = try?  JSONDecoder().decode(CommunityGuidelines.self, from: data) {
            guidelines = decoded
        }
    }
    
    // MARK: - Communities Management
    
    func getAllCommunities() -> [Community] {
        return communities
    }
    
    func getCommunities(type: Community.CommunityType?  = nil) -> [Community] {
        if let type = type {
            return communities.filter { $0.type == type }
        }
        return communities
    }
    
    func getJoinedCommunities() -> [Community] {
        return communities.filter { $0.isJoined }
    }
    
    func getCommunity(byId id: UUID) -> Community? {
        return communities.first { $0.id == id }
    }
    
    func joinCommunity(_ communityId: UUID) {
        if let index = communities.firstIndex(where: { $0.id == communityId }) {
            communities[index].isJoined = true
            communities[index].memberCount += 1
            saveCommunities()
        }
    }
    
    func leaveCommunity(_ communityId: UUID) {
        if let index = communities.firstIndex(where: { $0.id == communityId }) {
            communities[index].isJoined = false
            communities[index].memberCount = max(0, communities[index].memberCount - 1)
            saveCommunities()
        }
    }
    
    private func saveCommunities() {
        if let encoded = try? JSONEncoder().encode(communities) {
            UserDefaults.standard.set(encoded, forKey: communitiesKey)
        }
    }
    
    private func loadCommunities() {
        if let data = UserDefaults.standard.data(forKey: communitiesKey),
           let decoded = try? JSONDecoder().decode([Community].self, from: data) {
            communities = decoded
        } else {
            createDefaultCommunities()
        }
    }
    
    private func createDefaultCommunities() {
        communities = [
            // Local Communities
            Community(
                name: "Peaceful Parents Circle",
                description: "Connect with calm, mindful parents in your area",
                icon: "leaf. circle.fill",
                memberCount: 2453,
                type: .local,
                isJoined: true
            ),
            Community(
                name: "Calm Parenting Circle",
                description: "Share tips on peaceful parenting strategies",
                icon: "heart.circle.fill",
                memberCount: 1876,
                type: .local
            ),
            Community(
                name: "School Lunch Ideas",
                description: "Creative and healthy lunch box inspiration",
                icon: "fork.knife.circle.fill",
                memberCount: 1234,
                type: .local
            ),
            Community(
                name: "Weekend Activity Club",
                description: "Plan fun weekend activities for kids",
                icon: "figure.play.circle.fill",
                memberCount: 987,
                type: .local
            ),
            
            // Global Communities
            Community(
                name: "Working Parents Support",
                description: "Balance work and parenting together",
                icon: "briefcase.circle.fill",
                memberCount: 15420,
                type: .global
            ),
            Community(
                name: "Toddler Tantrums Help",
                description: "Strategies for handling toddler meltdowns",
                icon: "exclamationmark.triangle.fill",
                memberCount: 12890,
                type: .global
            ),
            Community(
                name: "Sleep Training Support",
                description: "Help your little one sleep through the night",
                icon: "moon.circle.fill",
                memberCount: 10567,
                type: .global
            ),
            Community(
                name: "Picky Eaters Anonymous",
                description: "Dealing with selective eating habits",
                icon: "carrot.fill",
                memberCount: 8943,
                type: .global
            )
        ]
        saveCommunities()
    }
    
    // MARK: - Posts Management
    
    func getAllPosts() -> [CommunityPost] {
        return posts.sorted { $0.createdAt > $1.createdAt }
    }
    
    func getPosts(for communityId: UUID) -> [CommunityPost] {
        return posts.filter { $0.communityId == communityId }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    func getUserPosts(username: String) -> [CommunityPost] {
        return posts.filter { $0.authorName == username }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    func getSavedPosts() -> [CommunityPost] {
        return posts.filter { $0.isSaved }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    func addPost(_ post: CommunityPost) {
        posts.insert(post, at: 0)
        savePosts()
    }
    
    func toggleLike(postId: UUID) {
        if let index = posts.firstIndex(where: { $0.id == postId }) {
            posts[index].isLiked.toggle()
            posts[index].likeCount += posts[index].isLiked ?  1 : -1
            savePosts()
        }
    }
    
    func toggleSave(postId: UUID) {
        if let index = posts.firstIndex(where: { $0.id == postId }) {
            posts[index].isSaved.toggle()
            savePosts()
        }
    }
    
    private func savePosts() {
        if let encoded = try? JSONEncoder().encode(posts) {
            UserDefaults.standard.set(encoded, forKey: postsKey)
        }
    }
    
    private func loadPosts() {
        if let data = UserDefaults.standard.data(forKey: postsKey),
           let decoded = try? JSONDecoder().decode([CommunityPost].self, from: data) {
            posts = decoded
        } else {
            createDefaultPosts()
        }
    }
    
    private func createDefaultPosts() {
        guard let peacefulCircle = communities.first(where: { $0.name == "Peaceful Parents Circle" }),
              let lunchIdeas = communities.first(where: { $0.name == "School Lunch Ideas" }),
              let workingParents = communities.first(where: { $0.name == "Working Parents Support" }) else {
            return
        }
        
        posts = [
            CommunityPost(
                authorName: "Nora",
                communityId: peacefulCircle.id,
                communityName:  peacefulCircle.name,
                content: "Promoted to full-time Demolition Expert for year two! ",
                imageURL: "child_happy",
                likeCount: 24,
                commentCount: 8,
                createdAt: Date().addingTimeInterval(-7200)
            ),
            CommunityPost(
                authorName: "Kunika Kapadia",
                communityId: peacefulCircle.id,
                communityName: peacefulCircle.name,
                content: "How do you peacefully transition from a busy day to bedtime?",
                likeCount: 12,
                commentCount: 15,
                createdAt: Date().addingTimeInterval(-18000)
            ),
            CommunityPost(
                authorName: "Kaylen",
                communityId: lunchIdeas.id,
                communityName: lunchIdeas.name,
                content: "We tried a new camping-themed lunch today! The kids loved the adventure theme 🏕️",
                imageURL: "family_hiking",
                likeCount: 45,
                commentCount: 23,
                createdAt: Date().addingTimeInterval(-86400)
            ),
            CommunityPost(
                authorName: "Sarah M",
                communityId: workingParents.id,
                communityName: workingParents.name,
                content: "Finally found a morning routine that works! Wake up 30 mins earlier for some quiet coffee time before the chaos begins.",
                likeCount: 67,
                commentCount: 34,
                createdAt: Date().addingTimeInterval(-3600)
            )
        ]
        savePosts()
    }
}
