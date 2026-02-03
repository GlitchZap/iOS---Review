//
//  SupabaseClientProvider.swift
//  ParentBud_01
//
//  Centralised Supabase client + configuration.
//  NOTE: Uses the public/anon key only – do NOT embed service_role keys in the app.
//

import Foundation
import Supabase

enum SupabaseConfig {
    // ⚠️ IMPORTANT: Get your real keys from Supabase Dashboard:
    //    1. Go to https://supabase.com/dashboard → select your project
    //    2. Settings → API → Copy "Project URL" and "anon (public)" key
    //    The anon key is a JWT token starting with "eyJ..."
    //
    // Project URL (update if different):
    static let url = URL(string: "https://rpxccrfbicwkoeenhfkm.supabase.co")!
    
    // ⚠️ REPLACE THIS with your real anon key from Supabase Dashboard → Settings → API → "anon public"
    // It should be a long JWT token starting with "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJweGNjcmZiaWN3a29lZW5oZmttIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc2ODUwNTYsImV4cCI6MjA4MzI2MTA1Nn0.7Pb8VUx64ZAXzO3O2EeeUWxhXe3rQMhTy8wF1_D1IJY"
}

final class SupabaseClientProvider {
    static let shared = SupabaseClientProvider()
    let client: SupabaseClient

    private init() {
        print("🔧 Initializing Supabase client...")
        print("   URL: \(SupabaseConfig.url)")
        print("   Key: \(String(SupabaseConfig.anonKey.prefix(50)))...")
        
        client = SupabaseClient(
            supabaseURL: SupabaseConfig.url,
            supabaseKey: SupabaseConfig.anonKey
        )
        
        print("✅ Supabase client initialized successfully")
    }
}

