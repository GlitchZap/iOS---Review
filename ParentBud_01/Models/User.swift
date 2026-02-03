//
//  User.swift
//  ParentBud_01
//
//  Created by Aayush Kumar on 07/11/25.
//


// FILE: User.swift

import Foundation

struct User: Codable {
    let id = UUID()
    let name: String
    let email: String
    let location: String?
}


struct MockUser {
    static let sampleUser = User(
        name: "Aayush Kumar",
        email: "aayush@example.com",
        location: "Chennai, India"
    )
}
