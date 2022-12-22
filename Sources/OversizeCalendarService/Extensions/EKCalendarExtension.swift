//
// Copyright © 2022 Alexander Romanov
// EKCalendarExtension.swift
//

import EventKit
import SwiftUI

extension EKCalendar: Identifiable {
    public var id: String {
        calendarIdentifier
    }

    public var color: Color {
        Color(UIColor(cgColor: cgColor))
    }
}
