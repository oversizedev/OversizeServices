//
// Copyright © 2022 Alexander Romanov
// EKEventExtension.swift
//

import EventKit

public extension EKEvent {
    var membersCount: Int {
        if organizer != nil, hasAttendees {
            return 1 + (attendees?.count ?? 0)
        } else if organizer != nil {
            return 1
        } else {
            return 1
        }
    }
}
