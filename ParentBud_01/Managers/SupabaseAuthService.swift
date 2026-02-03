//
//  SupabaseAuthService.swift
//  ParentBud_01
//
//  Thin async wrapper around Supabase Auth.
//

import Foundation
import Supabase
import Auth

enum AuthError: LocalizedError {
    case noSession

    var errorDescription: String? {
        switch self {
        case .noSession:
            return "No active session found."
        }
    }
}

final class SupabaseAuthService {
    static let shared = SupabaseAuthService()
    private let client = SupabaseClientProvider.shared.client

    private init() {}

    func signUp(email: String, password: String, name: String?) async throws {
        let metadata: [String: AnyJSON] = name.map { ["name": AnyJSON.string($0)] } ?? [:]
        try await client.auth.signUp(
            email: email,
            password: password,
            data: metadata
        )
    }

    func signIn(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }

    func currentSession() async throws -> Supabase.Session {
        return try await client.auth.session
    }

    func currentUser() async throws -> Supabase.User {
        let session = try await currentSession()
        return session.user
    }
}

