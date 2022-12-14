//
// Copyright © 2022 Alexander Romanov
// EKParticipantExtensions.swift
//

import EventKit
import Foundation
import SwiftUI

public extension EKParticipantRole {
    var title: String? {
        switch self {
        case .unknown:
            return nil
        case .required:
            return "Required"
        case .optional:
            return "Optional"
        case .chair:
            return "Chair"
        case .nonParticipant:
            return "Non participant"
        @unknown default:
            return nil
        }
    }
}

public extension EKParticipant {
    var color: Color {
        switch participantStatus {
        case .accepted, .delegated, .completed:
            return .green
        case .pending, .inProcess, .tentative:
            return .orange
        case .declined:
            return .red
        case .unknown:
            return .gray
        @unknown default:
            return .gray
        }
    }
}

public extension EKParticipant {
    var symbolName: String {
        switch participantStatus {
        case .accepted, .delegated, .completed:
            return "checkmark"
        case .pending, .inProcess, .tentative:
            return "questionmark"
        case .declined:
            return "xmark"
        case .unknown:
            return "questionmark"
        @unknown default:
            return "questionmark"
        }
    }
}

public extension EKParticipant {
    static func fromEmail(_ email: String) -> EKParticipant? {
        let clazz: AnyClass? = NSClassFromString("EKAttendee")
        if let type = clazz as? NSObject.Type {
            let attendee = type.init()
            attendee.setValue(email, forKey: "emailAddress")
            attendee.setValue(UUID().uuidString, forKey: "UUID")
            return attendee as? EKParticipant
        }
        return nil
    }
}
