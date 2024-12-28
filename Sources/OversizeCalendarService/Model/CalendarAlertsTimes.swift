//
// Copyright © 2022 Alexander Romanov
// CalendarAlertsTimes.swift
//

#if canImport(EventKit)
@preconcurrency import EventKit
#endif
import Foundation

#if !os(tvOS)
public enum CalendarAlertsTimes: CaseIterable, Equatable, Identifiable, @unchecked Sendable {
    case oneMinuteBefore, fiveMinutesBefore, tenMinutesBefore, thirtyMinutesBefore, oneHourBefore, twoHoursBefore, oneDayBefore, twoDaysBefore, oneWeekBefore, custom(EKAlarm)

    public var title: String {
        switch self {
        case .oneMinuteBefore:
            "1 minute before"
        case .fiveMinutesBefore:
            "5 minutes before"
        case .tenMinutesBefore:
            "10 minutes before"
        case .thirtyMinutesBefore:
            "30 minutes before"
        case .oneHourBefore:
            "1 hour before"
        case .twoHoursBefore:
            "2 hours before"
        case .oneDayBefore:
            "1 day before"
        case .twoDaysBefore:
            "2 days before"
        case .oneWeekBefore:
            "1 week before"
        case .custom:
            "Custom"
        }
    }

    public var alarm: EKAlarm {
        switch self {
        case .oneMinuteBefore:
            EKAlarm(relativeOffset: -1 * 60)
        case .fiveMinutesBefore:
            EKAlarm(relativeOffset: -5 * 60)
        case .tenMinutesBefore:
            EKAlarm(relativeOffset: -10 * 60)
        case .thirtyMinutesBefore:
            EKAlarm(relativeOffset: -30 * 60)
        case .oneHourBefore:
            EKAlarm(relativeOffset: -1 * 60 * 60)
        case .twoHoursBefore:
            EKAlarm(relativeOffset: -2 * 60 * 60)
        case .oneDayBefore:
            EKAlarm(relativeOffset: -1 * 24 * 60 * 60)
        case .twoDaysBefore:
            EKAlarm(relativeOffset: -2 * 24 * 60 * 60)
        case .oneWeekBefore:
            EKAlarm(relativeOffset: -7 * 24 * 60 * 60)
        case let .custom(alarm):
            alarm
        }
    }

    public var id: String {
        if case let .custom(alarm) = self {
            title + String(alarm.relativeOffset)
        } else {
            title
        }
    }

    public static let allCases: [CalendarAlertsTimes] = [
        .oneMinuteBefore,
        .fiveMinutesBefore,
        .tenMinutesBefore,
        .thirtyMinutesBefore,
        .oneHourBefore,
        .twoHoursBefore,
        .oneDayBefore,
        .twoDaysBefore,
        .oneWeekBefore,
    ]
}

public extension EKAlarm {
    var calendarAlert: CalendarAlertsTimes {
        if let calendarAlert = CalendarAlertsTimes.allCases.first(where: { $0.alarm.relativeOffset == self.relativeOffset }) {
            calendarAlert
        } else {
            .custom(self)
        }
    }
}
#endif
