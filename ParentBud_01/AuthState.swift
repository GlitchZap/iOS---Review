//
//  AuthManager.swift
//  ParentBud_01
//
//  Created by GlitchZap on 2026-01-15
//

import Foundation

enum AuthState {
    case loggedIn
    case guest
    case loggedOut
}

class AuthManager {
    static let shared = AuthManager()
    
    private init() {
        // Load auth state from UserDefaults
        if let savedState = UserDefaults.standard.string(forKey: "authState") {
            switch savedState {
            case "loggedIn":
                authState = .loggedIn
            case "guest":
                authState = . guest
            default:
                authState = .loggedOut
            }
        }
    }
    
    var authState: AuthState = .loggedOut {
        didSet {
            // Save to UserDefaults
            let stateString:  String
            switch authState {
            case .loggedIn:
                stateString = "loggedIn"
            case . guest:
                stateString = "guest"
            case .loggedOut:
                stateString = "loggedOut"
            }
            UserDefaults.standard.set(stateString, forKey: "authState")
            
            // Post notification for any views that need to update
            NotificationCenter.default.post(name: NSNotification.Name("AuthStateChanged"), object: nil)
            
            print("🔐 Auth state changed to: \(authState)")
        }
    }
    
    var isGuest: Bool {
        return authState == . guest
    }
    
    var isLoggedIn: Bool {
        return authState == .loggedIn
    }
    
    func activateGuestMode() {
        authState = .guest
        print("👤 Guest mode activated")
    }
    
    func login() {
        authState = .loggedIn
        print("✅ User logged in")
    }
    
    func logout() {
        authState = .loggedOut
        UserDefaults.standard.removeObject(forKey: "authState")
        print("👋 User logged out")
    }
}
