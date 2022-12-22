//
// Copyright © 2022 Alexander Romanov
// EKRecurrenceRuleExtension.swift
//

import EventKit

public extension EKRecurrenceRule {
    var calendarRecurrenceRule: CalendarEventRecurrenceRules {
        if let rule = CalendarEventRecurrenceRules.allCases.first(where: {
            $0.rule?.frequency == self.frequency
                && $0.rule?.interval == self.interval
                && $0.rule?.daysOfTheWeek == self.daysOfTheWeek
                && $0.rule?.daysOfTheWeek == self.daysOfTheWeek
        }) {
            return rule
        } else {
            return .custom(self)
        }
    }
}

public extension EKRecurrenceEnd {
    var calendarEndRecurrenceRule: CalendarEventEndRecurrenceRules {
        if let endDate {
            return .endDate(endDate)
        } else if occurrenceCount != 0 {
            return .occurrenceCount(occurrenceCount)
        } else {
            return .never
        }
    }
}
