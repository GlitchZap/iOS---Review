//
//  SupabaseProfileService.swift
//  ParentBud_01
//
//  Persists UserData to Supabase `profiles` table.
//

import Foundation
import Supabase
import Auth

/// Matches the `profiles` table schema.
struct SupabaseProfileRecord: Codable {
    let id: UUID
    var email: String?
    var name: String?
    var phoneNumber: String?
    var hasCompletedOnboarding: Bool?
    var hasCompletedScreener: Bool?
    var screenerData: ScreenerData?
    var childProfiles: [ChildData]?
    var activeChildId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var lastLoginAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case phoneNumber = "phone_number"
        case hasCompletedOnboarding = "has_completed_onboarding"
        case hasCompletedScreener = "has_completed_screener"
        case screenerData = "screener_data"
        case childProfiles = "child_profiles"
        case activeChildId = "active_child_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case lastLoginAt = "last_login_at"
    }
}

final class SupabaseProfileService {
    static let shared = SupabaseProfileService()
    private let client = SupabaseClientProvider.shared.client
    private init() {}

    // Fetch the profile for the current authenticated user
    func fetchCurrentProfile() async throws -> UserData {
        let session = try await client.auth.session
        // If needed, you can add additional validation here; `session` is non-optional.
        return try await fetchProfile(for: session.user.id)
    }

    func fetchProfile(for userId: UUID) async throws -> UserData {
        let records: [SupabaseProfileRecord] = try await client
            .from("profiles")
            .select()
            .eq("id", value: userId)
            .limit(1)
            .execute()
            .value

        guard let record = records.first else {
            throw NSError(domain: "profile", code: 404, userInfo: [NSLocalizedDescriptionKey: "Profile not found"])
        }
        return map(record: record)
    }

    func upsertProfile(_ user: UserData) async throws {
        let record = map(user: user)
        _ = try await client
            .from("profiles")
            .upsert(record, returning: .representation)
            .execute()
    }

    // MARK: - Mapping
    private func map(record: SupabaseProfileRecord) -> UserData {
        UserData(
            userId: record.id.uuidString,
            email: record.email ?? "",
            name: record.name ?? "",
            phoneNumber: record.phoneNumber,
            createdAt: record.createdAt ?? Date(),
            updatedAt: record.updatedAt ?? Date(),
            lastLoginAt: record.lastLoginAt ?? Date(),
            hasCompletedOnboarding: record.hasCompletedOnboarding ?? false,
            hasCompletedScreener: record.hasCompletedScreener ?? false,
            screenerData: record.screenerData,
            childProfiles: record.childProfiles ?? [],
            activeChildId: record.activeChildId
        )
    }

    private func map(user: UserData) -> SupabaseProfileRecord {
        SupabaseProfileRecord(
            id: UUID(uuidString: user.userId) ?? UUID(),
            email: user.email,
            name: user.name,
            phoneNumber: user.phoneNumber,
            hasCompletedOnboarding: user.hasCompletedOnboarding,
            hasCompletedScreener: user.hasCompletedScreener,
            screenerData: user.screenerData,
            childProfiles: user.childProfiles,
            activeChildId: user.activeChildId,
            createdAt: user.createdAt,
            updatedAt: Date(),
            lastLoginAt: Date()
        )
    }
}

