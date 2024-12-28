//
// Copyright © 2022 Alexander Romanov
// EKEventStatus.swift
//
#if canImport(EventKit)
import EventKit
#endif

#if os(iOS) || os(macOS)
public extension EKEventStatus {
    var title: String {
        switch self {
        case .none:
            return "None"
        case .confirmed:
            return "Accept"
        case .tentative:
            return "Maybe"
        case .canceled:
            return "Decline"
        @unknown default:
            return "None"
        }
    }
}
#endif
