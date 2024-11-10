//
// Copyright © 2022 Alexander Romanov
// EKCalendarExtension.swift
//

#if canImport(EventKit)
    import EventKit
#endif
import SwiftUI

#if os(iOS) || os(macOS)
extension EKCalendar: @retroactive Identifiable {
        public var id: String {
            calendarIdentifier
        }

        public var color: Color {
            Color(cgColor)
        }
    }
#endif
