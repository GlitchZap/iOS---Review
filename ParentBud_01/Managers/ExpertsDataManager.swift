//
//  ExpertsDataManager.swift
//  ParentBud_01
//
//  Updated to use Supabase for real data - fetches actual experts from the portal
//

import Foundation
import Supabase

// MARK: - Supabase Expert Model (matches database schema)
struct SupabaseExpert: Codable {
    let id: UUID
    let auth_user_id: UUID
    let email: String
    let full_name: String
    let expertise: [String]
    let hourly_rate: Double
    let bio: String?
    let verified: Bool
    let rating: Double?
    let total_reviews: Int?
    let profile_image_url: String?
    let created_at: String
    let updated_at: String
}

// MARK: - Supabase Availability Model
struct SupabaseAvailability: Codable {
    let id: UUID
    let expert_id: UUID
    let day_of_week: Int
    let start_time: String
    let end_time: String
    let is_available: Bool
    let created_at: String
}

// MARK: - Supabase Appointment Model
struct SupabaseAppointment: Codable, Identifiable {
    let id: UUID
    let expert_id: UUID
    let user_id: UUID?
    let client_name: String
    let client_email: String
    let scheduled_for: String
    let start_time: String?
    let end_time: String?
    let status: String
    let meeting_link: String?
    let notes: String?
    let feedback: String?
    let rating: Double?
    let amount: Double
    let created_at: String
    let updated_at: String
}

// MARK: - Supabase Chat Message Model
struct SupabaseChatMessage: Codable, Identifiable {
    let id: UUID
    let appointment_id: UUID?
    let sender_id: UUID?
    let receiver_id: UUID?
    let message: String?
    let sender_role: String?
    let sent_at: String?
}

class ExpertsDataManager {
    static let shared = ExpertsDataManager()
    
    private let supabase = SupabaseClientProvider.shared.client
    
    private let reviewsKey = "expert_reviews"
    private let helpfulReviewsKey = "helpful_reviews_marked"
    
    private var experts: [Expert] = []
    private var sessions: [ExpertSession] = []
    private var chatThreads: [ChatThread] = []
    private var reviews: [ExpertReview] = []
    private var helpfulReviewsMarked: Set<UUID> = []
    
    private var isLoading = false
    
    private init() {
        loadLocalReviews()
        loadHelpfulMarks()
        
        // Load real data from Supabase
        Task {
            await loadExpertsFromSupabase()
            await loadSessionsFromSupabase()
            await loadChatMessagesFromSupabase()
        }
    }
    
    // MARK: - Get Current User ID
    private func getCurrentUserId() -> String {
        let currentUser = UserDataManager.shared.getCurrentUser()
        return currentUser?.userId ?? UUID().uuidString
    }
    
    private func getCurrentUserUUID() -> UUID? {
        let currentUser = UserDataManager.shared.getCurrentUser()
        if let userId = currentUser?.userId {
            return UUID(uuidString: userId)
        }
        return nil
    }
    
    // MARK: - Supabase Data Loading
    
    @MainActor
    func loadExpertsFromSupabase() async {
        guard !isLoading else { return }
        isLoading = true
        
        do {
            print("🔄 Loading experts from Supabase...")
            
            let supabaseExperts: [SupabaseExpert] = try await supabase
                .from("experts")
                .select()
                .execute()
                .value
            
            print("📊 Found \(supabaseExperts.count) experts in Supabase")
            
            // Convert Supabase experts to local Expert model
            var loadedExperts: [Expert] = []
            
            for supaExpert in supabaseExperts {
                print("   - Expert: \(supaExpert.full_name) (ID: \(supaExpert.id))")
                
                // Load availability for this expert
                let availability = await loadAvailabilityForExpert(expertId: supaExpert.id)
                print("     Availability slots: \(availability.count)")
                
                // Parse date with fallback
                let dateFormatter = ISO8601DateFormatter()
                dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                var createdDate = dateFormatter.date(from: supaExpert.created_at)
                if createdDate == nil {
                    dateFormatter.formatOptions = [.withInternetDateTime]
                    createdDate = dateFormatter.date(from: supaExpert.created_at)
                }
                
                let expert = Expert(
                    id: supaExpert.id,
                    name: supaExpert.full_name,
                    title: supaExpert.expertise.first ?? "Expert",
                    specialization: supaExpert.expertise.isEmpty ? "General" : supaExpert.expertise.joined(separator: ", "),
                    certifications: supaExpert.expertise,
                    bio: supaExpert.bio ?? "Experienced professional ready to help your family.",
                    rating: supaExpert.rating ?? 4.5,
                    reviewCount: supaExpert.total_reviews ?? 0,
                    photoURL: supaExpert.profile_image_url,
                    availableTimeSlots: availability,
                    expertise: supaExpert.expertise.isEmpty ? ["General"] : supaExpert.expertise,
                    createdAt: createdDate ?? Date()
                )
                
                loadedExperts.append(expert)
            }
            
            self.experts = loadedExperts
            print("✅ Loaded \(experts.count) experts from Supabase")
            
            // Post notification for UI update
            NotificationCenter.default.post(name: .expertsDidUpdate, object: nil)
            
        } catch {
            print("❌ Failed to load experts from Supabase: \(error)")
            print("   Error details: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    private func loadAvailabilityForExpert(expertId: UUID) async -> [TimeSlot] {
        do {
            let availability: [SupabaseAvailability] = try await supabase
                .from("availability")
                .select()
                .eq("expert_id", value: expertId.uuidString)
                .eq("is_available", value: true)
                .execute()
                .value
            
            var slots: [TimeSlot] = []
            let calendar = Calendar.current
            let today = Date()
            
            for avail in availability {
                // Generate slots for the next 2 weeks based on day_of_week
                for dayOffset in 0...13 {
                    guard let futureDate = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }
                    let weekday = calendar.component(.weekday, from: futureDate) - 1 // 0 = Sunday
                    
                    if weekday == avail.day_of_week {
                        let slot = TimeSlot(
                            date: futureDate,
                            startTime: String(avail.start_time.prefix(5)), // "09:00"
                            endTime: String(avail.end_time.prefix(5)),
                            isAvailable: true
                        )
                        slots.append(slot)
                    }
                }
            }
            
            return slots.sorted { $0.date < $1.date }
            
        } catch {
            print("❌ Failed to load availability: \(error)")
            return []
        }
    }
    
    @MainActor
    func loadSessionsFromSupabase() async {
        guard let userId = getCurrentUserUUID() else {
            print("⚠️ No user ID available for loading sessions")
            return
        }
        
        do {
            print("🔄 Loading appointments from Supabase...")
            
            let appointments: [SupabaseAppointment] = try await supabase
                .from("appointments")
                .select()
                .eq("user_id", value: userId.uuidString)
                .execute()
                .value
            
            var loadedSessions: [ExpertSession] = []
            
            for appt in appointments {
                let dateFormatter = ISO8601DateFormatter()
                let sessionDate = dateFormatter.date(from: appt.scheduled_for) ?? Date()
                
                // Parse time from scheduled_for or use start_time
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "HH:mm"
                let startTimeStr = appt.start_time?.prefix(5).description ?? timeFormatter.string(from: sessionDate)
                let endTimeStr = appt.end_time?.prefix(5).description ?? timeFormatter.string(from: sessionDate.addingTimeInterval(3600))
                
                let timeSlot = TimeSlot(
                    date: sessionDate,
                    startTime: startTimeStr,
                    endTime: endTimeStr,
                    isAvailable: false
                )
                
                let status: SessionStatus
                switch appt.status {
                case "confirmed": status = .scheduled
                case "completed": status = .completed
                case "cancelled": status = .cancelled
                case "pending", "requested": status = .scheduled
                default: status = .scheduled
                }
                
                let session = ExpertSession(
                    id: appt.id,
                    expertId: appt.expert_id,
                    userId: userId.uuidString,
                    sessionDate: sessionDate,
                    timeSlot: timeSlot,
                    status: status,
                    notes: appt.notes,
                    createdAt: dateFormatter.date(from: appt.created_at) ?? Date()
                )
                
                loadedSessions.append(session)
            }
            
            self.sessions = loadedSessions
            print("✅ Loaded \(sessions.count) sessions from Supabase")
            
            // Post notification for UI update
            NotificationCenter.default.post(name: .sessionsDidUpdate, object: nil)
            
        } catch {
            print("❌ Failed to load sessions from Supabase: \(error)")
        }
    }
    
    @MainActor
    func loadChatMessagesFromSupabase() async {
        do {
            print("🔄 Loading chat messages from Supabase...")
            
            // Get all appointments for this user first
            let userSessions = sessions
            
            var loadedThreads: [ChatThread] = []
            
            for session in userSessions {
                let messages: [SupabaseChatMessage] = try await supabase
                    .from("chat_messages")
                    .select()
                    .eq("appointment_id", value: session.id.uuidString)
                    .order("sent_at", ascending: true)
                    .execute()
                    .value
                
                if !messages.isEmpty {
                    var chatMessages: [ChatMessage] = []
                    
                    for msg in messages {
                        let senderType: SenderType = msg.sender_role == "expert" ? .expert : .user
                        let dateFormatter = ISO8601DateFormatter()
                        
                        let chatMsg = ChatMessage(
                            id: msg.id,
                            sessionId: session.id,
                            senderId: msg.sender_id?.uuidString ?? "",
                            senderType: senderType,
                            message: msg.message ?? "",
                            timestamp: dateFormatter.date(from: msg.sent_at ?? "") ?? Date(),
                            isRead: true
                        )
                        chatMessages.append(chatMsg)
                    }
                    
                    let thread = ChatThread(
                        sessionId: session.id,
                        expertId: session.expertId,
                        messages: chatMessages,
                        lastMessage: chatMessages.last,
                        unreadCount: 0,
                        isTyping: false,
                        updatedAt: chatMessages.last?.timestamp ?? Date()
                    )
                    
                    loadedThreads.append(thread)
                }
            }
            
            self.chatThreads = loadedThreads
            print("✅ Loaded \(chatThreads.count) chat threads from Supabase")
            
            // Post notification for UI update
            NotificationCenter.default.post(name: .chatThreadsDidUpdate, object: nil)
            
        } catch {
            print("❌ Failed to load chat messages from Supabase: \(error)")
        }
    }
    
    // MARK: - Refresh Data
    
    func refreshAllData() {
        Task {
            await loadExpertsFromSupabase()
            await loadSessionsFromSupabase()
            await loadChatMessagesFromSupabase()
        }
    }
    
    // MARK: - Experts Management
    
    func getAllExperts() -> [Expert] {
        return experts.sorted { $0.rating > $1.rating }
    }
    
    func getExpert(byId id: UUID) -> Expert? {
        return experts.first { $0.id == id }
    }
    
    func searchExperts(query: String) -> [Expert] {
        guard !query.isEmpty else { return getAllExperts() }
        
        let lowercasedQuery = query.lowercased()
        return experts.filter { expert in
            expert.name.lowercased().contains(lowercasedQuery) ||
            expert.specialization.lowercased().contains(lowercasedQuery) ||
            expert.expertise.contains { $0.lowercased().contains(lowercasedQuery) }
        }
    }
    
    // MARK: - Sessions Management
    
    func scheduleSession(expertId: UUID, userId: String, timeSlot: TimeSlot) -> ExpertSession {
        let session = ExpertSession(
            expertId: expertId,
            userId: userId,
            sessionDate: timeSlot.date,
            timeSlot: timeSlot,
            status: .scheduled
        )
        
        sessions.append(session)
        
        // Save to Supabase
        Task {
            await saveSessionToSupabase(session)
        }
        
        // Schedule reminder notification
        if let expert = getExpert(byId: expertId) {
            NotificationManager.shared.sendSessionReminderNotification(
                expertName: expert.name,
                sessionDate: session.sessionDate
            )
        }
        
        print("✅ Session scheduled: \(session.id)")
        return session
    }
    
    private func saveSessionToSupabase(_ session: ExpertSession) async {
        guard let _ = getExpert(byId: session.expertId) else { return }
        
        do {
            let isoFormatter = ISO8601DateFormatter()
            
            let appointmentData: [String: AnyEncodable] = [
                "id": AnyEncodable(session.id.uuidString),
                "expert_id": AnyEncodable(session.expertId.uuidString),
                "user_id": AnyEncodable(session.userId),
                "client_name": AnyEncodable(UserDataManager.shared.getCurrentUser()?.name ?? "User"),
                "client_email": AnyEncodable(UserDataManager.shared.getCurrentUser()?.email ?? "user@example.com"),
                "scheduled_for": AnyEncodable(isoFormatter.string(from: session.sessionDate)),
                "status": AnyEncodable("pending"),
                "amount": AnyEncodable(100.0),
                "notes": AnyEncodable(session.notes ?? "")
            ]
            
            try await supabase
                .from("appointments")
                .insert(appointmentData)
                .execute()
            
            print("✅ Session saved to Supabase")
            
        } catch {
            print("❌ Failed to save session to Supabase: \(error)")
        }
    }
    
    func getScheduledSessions(for userId: String) -> [ExpertSession] {
        let userSessions = sessions.filter { $0.userId == userId && $0.status == .scheduled }
            .sorted { $0.sessionDate < $1.sessionDate }
        
        return userSessions
    }
    
    func getSession(byId id: UUID) -> ExpertSession? {
        return sessions.first { $0.id == id }
    }
    
    func updateSessionStatus(_ sessionId: UUID, status: SessionStatus) {
        if let index = sessions.firstIndex(where: { $0.id == sessionId }) {
            sessions[index].status = status
            sessions[index].updatedAt = Date()
            
            // Update in Supabase
            Task {
                await updateSessionStatusInSupabase(sessionId: sessionId, status: status)
            }
        }
    }
    
    private func updateSessionStatusInSupabase(sessionId: UUID, status: SessionStatus) async {
        do {
            let statusString: String
            switch status {
            case .scheduled: statusString = "confirmed"
            case .completed: statusString = "completed"
            case .cancelled: statusString = "cancelled"
            case .inProgress: statusString = "confirmed"
            }
            
            try await supabase
                .from("appointments")
                .update(["status": statusString, "updated_at": ISO8601DateFormatter().string(from: Date())])
                .eq("id", value: sessionId.uuidString)
                .execute()
            
            print("✅ Session status updated in Supabase")
            
        } catch {
            print("❌ Failed to update session status: \(error)")
        }
    }
    
    // MARK: - Chat Management
    
    func getChatThreads(for userId: String) -> [ChatThread] {
        let userThreads = chatThreads.filter { thread in
            if let session = getSession(byId: thread.sessionId) {
                return session.userId == userId
            }
            return false
        }
        .filter { thread in
            return !thread.messages.isEmpty &&
                   thread.lastMessage != nil &&
                   getExpert(byId: thread.expertId) != nil
        }
        .sorted { $0.updatedAt > $1.updatedAt }
        
        return userThreads
    }
    
    func getChatThread(for sessionId: UUID) -> ChatThread? {
        return chatThreads.first { $0.sessionId == sessionId }
    }
    
    func sendMessage(sessionId: UUID, senderId: String, senderType: SenderType, message: String) {
        let newMessage = ChatMessage(
            sessionId: sessionId,
            senderId: senderId,
            senderType: senderType,
            message: message
        )
        
        if let threadIndex = chatThreads.firstIndex(where: { $0.sessionId == sessionId }) {
            chatThreads[threadIndex].messages.append(newMessage)
            chatThreads[threadIndex].lastMessage = newMessage
            chatThreads[threadIndex].updatedAt = Date()
            
            if senderType == .expert {
                chatThreads[threadIndex].unreadCount += 1
                
                if let expert = getExpert(byId: chatThreads[threadIndex].expertId) {
                    NotificationManager.shared.sendExpertMessageNotification(
                        expertName: expert.name,
                        message: message,
                        expertId: expert.id.uuidString
                    )
                }
            }
            
            // Save to Supabase
            Task {
                await saveMessageToSupabase(message: newMessage, sessionId: sessionId)
            }
        } else {
            // Create new thread if it doesn't exist
            if let session = getSession(byId: sessionId) {
                var thread = ChatThread(sessionId: sessionId, expertId: session.expertId)
                thread.messages.append(newMessage)
                thread.lastMessage = newMessage
                chatThreads.append(thread)
                
                Task {
                    await saveMessageToSupabase(message: newMessage, sessionId: sessionId)
                }
            }
        }
    }
    
    private func saveMessageToSupabase(message: ChatMessage, sessionId: UUID) async {
        do {
            let messageData: [String: AnyEncodable] = [
                "id": AnyEncodable(message.id.uuidString),
                "appointment_id": AnyEncodable(sessionId.uuidString),
                "sender_id": AnyEncodable(message.senderId),
                "message": AnyEncodable(message.message),
                "sender_role": AnyEncodable(message.senderType == .expert ? "expert" : "parent"),
                "sent_at": AnyEncodable(ISO8601DateFormatter().string(from: message.timestamp))
            ]
            
            try await supabase
                .from("chat_messages")
                .insert(messageData)
                .execute()
            
            print("✅ Message saved to Supabase")
            
        } catch {
            print("❌ Failed to save message: \(error)")
        }
    }
    
    func markMessagesAsRead(sessionId: UUID) {
        if let threadIndex = chatThreads.firstIndex(where: { $0.sessionId == sessionId }) {
            chatThreads[threadIndex].unreadCount = 0
            
            for messageIndex in chatThreads[threadIndex].messages.indices {
                chatThreads[threadIndex].messages[messageIndex].isRead = true
            }
        }
    }
    
    func setTypingIndicator(sessionId: UUID, isTyping: Bool) {
        if let threadIndex = chatThreads.firstIndex(where: { $0.sessionId == sessionId }) {
            chatThreads[threadIndex].isTyping = isTyping
        }
    }
    
    // MARK: - Reviews Management
    
    func getReviews(for expertId: UUID) -> [ExpertReview] {
        return reviews.filter { $0.expertId == expertId }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    func addReview(_ review: ExpertReview) {
        reviews.append(review)
        saveLocalReviews()
        updateExpertRating(expertId: review.expertId)
    }
    
    private func updateExpertRating(expertId: UUID) {
        guard let expertIndex = experts.firstIndex(where: { $0.id == expertId }) else { return }
        
        let expertReviews = reviews.filter { $0.expertId == expertId }
        guard !expertReviews.isEmpty else { return }
        
        let totalRating = expertReviews.reduce(0.0) { $0 + $1.rating }
        let averageRating = totalRating / Double(expertReviews.count)
        
        experts[expertIndex].rating = averageRating
        experts[expertIndex].reviewCount = expertReviews.count
    }
    
    func isReviewMarkedHelpful(_ reviewId: UUID) -> Bool {
        return helpfulReviewsMarked.contains(reviewId)
    }
    
    func toggleHelpfulMark(for reviewId: UUID) {
        if helpfulReviewsMarked.contains(reviewId) {
            helpfulReviewsMarked.remove(reviewId)
        } else {
            helpfulReviewsMarked.insert(reviewId)
        }
        saveHelpfulMarks()
    }
    
    // MARK: - Local Persistence (for reviews and helpful marks)
    
    private func loadLocalReviews() {
        if let data = UserDefaults.standard.data(forKey: reviewsKey),
           let decoded = try? JSONDecoder().decode([ExpertReview].self, from: data) {
            reviews = decoded
        }
    }
    
    private func saveLocalReviews() {
        if let encoded = try? JSONEncoder().encode(reviews) {
            UserDefaults.standard.set(encoded, forKey: reviewsKey)
        }
    }
    
    private func loadHelpfulMarks() {
        if let data = UserDefaults.standard.data(forKey: helpfulReviewsKey),
           let decoded = try? JSONDecoder().decode(Set<UUID>.self, from: data) {
            helpfulReviewsMarked = decoded
        }
    }
    
    private func saveHelpfulMarks() {
        if let encoded = try? JSONEncoder().encode(helpfulReviewsMarked) {
            UserDefaults.standard.set(encoded, forKey: helpfulReviewsKey)
        }
    }
    
    // MARK: - Debug
    
    func printDebugInfo() {
        print("\n📊 === EXPERTS DATA MANAGER DEBUG INFO ===")
        print("👤 Current User: \(getCurrentUserId())")
        print("📊 Experts: \(experts.count)")
        print("📊 Sessions: \(sessions.count)")
        print("📊 Chat Threads: \(chatThreads.count)")
        print("📊 Reviews: \(reviews.count)")
        print("=== END DEBUG INFO ===\n")
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let expertsDidUpdate = Notification.Name("expertsDidUpdate")
    static let sessionsDidUpdate = Notification.Name("sessionsDidUpdate")
    static let chatThreadsDidUpdate = Notification.Name("chatThreadsDidUpdate")
}

// MARK: - Helper for encoding

struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void
    
    init<T: Encodable>(_ wrapped: T) {
        _encode = wrapped.encode
    }
    
    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}
