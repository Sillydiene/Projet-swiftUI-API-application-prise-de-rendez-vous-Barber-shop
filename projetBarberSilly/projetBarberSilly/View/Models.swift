//
//  Models.swift
//  projetBarberSilly
//
//  Created by MacBook Pro Silly on 2025-10-22.
//

// Models.swift
import Foundation

struct User: Identifiable, Codable, Hashable {
    let id: String
    var name: String?
    var email: String
    
}

struct Appointment: Identifiable, Codable, Hashable {
    let id: String
    var title: String
    var notes: String?
    var date: Date
    var userId: String
}

extension JSONDecoder {
    static var iso8601Decoder: JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }
}

extension JSONEncoder {
    static var iso8601Encoder: JSONEncoder {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }
}
