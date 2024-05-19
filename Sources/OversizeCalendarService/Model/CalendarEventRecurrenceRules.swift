//
// Copyright © 2022 Alexander Romanov
// CalendarEventRecurrenceRules.swift
//

#if canImport(EventKit)
    import EventKit
#endif
import Foundation

#if os(iOS) || os(macOS)
    public enum CalendarEventRecurrenceRules: CaseIterable, Equatable, Identifiable {
        case never, everyDay, everyWorkingDay, everyWeekend, everyWeek, everyTwoWeeks, everyMonth, everyYear, custom(EKRecurrenceRule?)

        public var rule: EKRecurrenceRule? {
            switch self {
            case .never:
                return nil
            case .everyDay:
                return .init(recurrenceWith: .daily, interval: 1, end: nil)
            case .everyWorkingDay:
                return .init(EKRecurrenceRule(
                    recurrenceWith: .weekly,
                    interval: 1,
                    daysOfTheWeek: [.init(.monday), .init(.tuesday), .init(.wednesday), .init(.thursday), .init(.friday)],
                    daysOfTheMonth: nil,
                    monthsOfTheYear: nil,
                    weeksOfTheYear: nil,
                    daysOfTheYear: nil,
                    setPositions: nil,
                    end: nil
                ))
            case .everyWeekend:
                return .init(EKRecurrenceRule(
                    recurrenceWith: .weekly,
                    interval: 1,
                    daysOfTheWeek: [.init(.saturday), .init(.sunday)],
                    daysOfTheMonth: nil,
                    monthsOfTheYear: nil,
                    weeksOfTheYear: nil,
                    daysOfTheYear: nil,
                    setPositions: nil,
                    end: nil
                ))
            case .everyWeek:
                return .init(recurrenceWith: .weekly, interval: 1, end: nil)
            case .everyTwoWeeks:
                return .init(recurrenceWith: .daily, interval: 2, end: nil)
            case .everyMonth:
                return .init(recurrenceWith: .monthly, interval: 1, end: nil)
            case .everyYear:
                return .init(recurrenceWith: .yearly, interval: 1, end: nil)
            case let .custom(customRule):
                return customRule
            }
        }

        public var title: String {
            switch self {
            case .never:
                return "Never"
            case .everyDay:
                return "Every Day"
            case .everyWorkingDay:
                return "Every Working Day"
            case .everyWeekend:
                return "Every Weekend"
            case .everyWeek:
                return "Every Week"
            case .everyTwoWeeks:
                return "Every 2 Weeks"
            case .everyMonth:
                return "Every Month"
            case .everyYear:
                return "Every Year"
            case .custom:
                return "Custom"
            }
        }

        public var id: String {
            title
        }

        public static var allCases: [CalendarEventRecurrenceRules] = [.never, .everyDay, .everyWorkingDay, .everyWeekend, .everyWeek, .everyTwoWeeks, .everyMonth, .everyYear]
    }

    public enum CalendarEventEndRecurrenceRules: CaseIterable, Equatable, Identifiable, Hashable {
        case never, occurrenceCount(Int), endDate(Date)

        public var end: EKRecurrenceEnd? {
            switch self {
            case .never:
                return nil
            case let .occurrenceCount(count):
                return .init(occurrenceCount: count)
            case let .endDate(date):
                return .init(end: date)
            }
        }

        public var title: String {
            switch self {
            case .never:
                return "Never"
            case .occurrenceCount:
                return "Occurrence Count"
            case .endDate:
                return "End Date"
            }
        }

        public var id: String {
            title
        }

        public static var allCases: [CalendarEventEndRecurrenceRules] = [.never, .occurrenceCount(1), .endDate(Date())]
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
