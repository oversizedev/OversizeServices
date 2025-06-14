//
// Copyright © 2022 Alexander Romanov
// CalendarEventRecurrenceRules.swift
//

#if canImport(EventKit)
@preconcurrency import EventKit
#endif
import Foundation

#if !os(tvOS)
public enum CalendarEventRecurrenceRules: CaseIterable, Equatable, Identifiable, @unchecked Sendable {
    case never, everyDay, everyWorkingDay, everyWeekend, everyWeek, everyTwoWeeks, everyMonth, everyYear, custom(EKRecurrenceRule?)

    public var rule: EKRecurrenceRule? {
        switch self {
        case .never:
            nil
        case .everyDay:
            .init(recurrenceWith: .daily, interval: 1, end: nil)
        case .everyWorkingDay:
            .init(EKRecurrenceRule(
                recurrenceWith: .weekly,
                interval: 1,
                daysOfTheWeek: [.init(.monday), .init(.tuesday), .init(.wednesday), .init(.thursday), .init(.friday)],
                daysOfTheMonth: nil,
                monthsOfTheYear: nil,
                weeksOfTheYear: nil,
                daysOfTheYear: nil,
                setPositions: nil,
                end: nil,
            ))
        case .everyWeekend:
            .init(EKRecurrenceRule(
                recurrenceWith: .weekly,
                interval: 1,
                daysOfTheWeek: [.init(.saturday), .init(.sunday)],
                daysOfTheMonth: nil,
                monthsOfTheYear: nil,
                weeksOfTheYear: nil,
                daysOfTheYear: nil,
                setPositions: nil,
                end: nil,
            ))
        case .everyWeek:
            .init(recurrenceWith: .weekly, interval: 1, end: nil)
        case .everyTwoWeeks:
            .init(recurrenceWith: .daily, interval: 2, end: nil)
        case .everyMonth:
            .init(recurrenceWith: .monthly, interval: 1, end: nil)
        case .everyYear:
            .init(recurrenceWith: .yearly, interval: 1, end: nil)
        case let .custom(customRule):
            customRule
        }
    }

    public var title: String {
        switch self {
        case .never:
            "Never"
        case .everyDay:
            "Every Day"
        case .everyWorkingDay:
            "Every Working Day"
        case .everyWeekend:
            "Every Weekend"
        case .everyWeek:
            "Every Week"
        case .everyTwoWeeks:
            "Every 2 Weeks"
        case .everyMonth:
            "Every Month"
        case .everyYear:
            "Every Year"
        case .custom:
            "Custom"
        }
    }

    public var id: String {
        title
    }

    public static let allCases: [CalendarEventRecurrenceRules] = [.never, .everyDay, .everyWorkingDay, .everyWeekend, .everyWeek, .everyTwoWeeks, .everyMonth, .everyYear]
}

public enum CalendarEventEndRecurrenceRules: CaseIterable, Equatable, Identifiable, Hashable, @unchecked Sendable {
    case never, occurrenceCount(Int), endDate(Date)

    public var end: EKRecurrenceEnd? {
        switch self {
        case .never:
            nil
        case let .occurrenceCount(count):
            .init(occurrenceCount: count)
        case let .endDate(date):
            .init(end: date)
        }
    }

    public var title: String {
        switch self {
        case .never:
            "Never"
        case .occurrenceCount:
            "Occurrence Count"
        case .endDate:
            "End Date"
        }
    }

    public var id: String {
        title
    }

    public static let allCases: [CalendarEventEndRecurrenceRules] = [
        .never,
        .occurrenceCount(1),
        .endDate(Date()),
    ]
}

public extension EKEvent {
    var calendarEventRecurrenceRules: CalendarEventRecurrenceRules? {
        let eventRule = recurrenceRules?.first
        eventRule?.recurrenceEnd = nil

        if let rule = CalendarEventRecurrenceRules.allCases.first(where: { $0.rule == eventRule }) {
            return rule
        } else {
            return .custom(recurrenceRules?.first)
        }
    }
}
#endif
