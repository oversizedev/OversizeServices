//
// Copyright © 2022 Alexander Romanov
// CalendarAlertsTimes.swift
//

#if canImport(EventKit)
    @preconcurrency import EventKit
#endif
import Foundation

#if !os(tvOS)
    public enum CalendarAlertsTimes: CaseIterable, Equatable, Identifiable, Sendable {
        case oneMinuteBefore, fiveMinutesBefore, tenMinutesBefore, thirtyMinutesBefore, oneHourBefore, twoHoursBefore, oneDayBefore, twoDaysBefore, oneWeekBefore, custom(EKAlarm)

        public var title: String {
            switch self {
            case .oneMinuteBefore:
                return "1 minute before"
            case .fiveMinutesBefore:
                return "5 minutes before"
            case .tenMinutesBefore:
                return "10 minutes before"
            case .thirtyMinutesBefore:
                return "30 minutes before"
            case .oneHourBefore:
                return "1 hour before"
            case .twoHoursBefore:
                return "2 hours before"
            case .oneDayBefore:
                return "1 day before"
            case .twoDaysBefore:
                return "2 days before"
            case .oneWeekBefore:
                return "1 week before"
            case .custom:
                return "Custom"
            }
        }

        public var alarm: EKAlarm {
            switch self {
            case .oneMinuteBefore:
                return EKAlarm(relativeOffset: -1 * 60)
            case .fiveMinutesBefore:
                return EKAlarm(relativeOffset: -5 * 60)
            case .tenMinutesBefore:
                return EKAlarm(relativeOffset: -10 * 60)
            case .thirtyMinutesBefore:
                return EKAlarm(relativeOffset: -30 * 60)
            case .oneHourBefore:
                return EKAlarm(relativeOffset: -1 * 60 * 60)
            case .twoHoursBefore:
                return EKAlarm(relativeOffset: -2 * 60 * 60)
            case .oneDayBefore:
                return EKAlarm(relativeOffset: -1 * 24 * 60 * 60)
            case .twoDaysBefore:
                return EKAlarm(relativeOffset: -2 * 24 * 60 * 60)
            case .oneWeekBefore:
                return EKAlarm(relativeOffset: -7 * 24 * 60 * 60)
            case let .custom(alarm):
                return alarm
            }
        }

        public var id: String {
            if case let .custom(alarm) = self {
                return title + String(alarm.relativeOffset)
            } else {
                return title
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
                return calendarAlert
            } else {
                return .custom(self)
            }
        }
    }
#endif
