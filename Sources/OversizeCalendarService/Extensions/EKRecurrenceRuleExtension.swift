//
// Copyright © 2022 Alexander Romanov
// EKRecurrenceRuleExtension.swift
//

#if canImport(EventKit)
import EventKit
#endif

#if !os(tvOS)
public extension EKRecurrenceRule {
    var calendarRecurrenceRule: CalendarEventRecurrenceRules {
        if let rule = CalendarEventRecurrenceRules.allCases.first(where: {
            $0.rule?.frequency == self.frequency
                && $0.rule?.interval == self.interval
                && $0.rule?.daysOfTheWeek == self.daysOfTheWeek
                && $0.rule?.daysOfTheWeek == self.daysOfTheWeek
        }) {
            rule
        } else {
            .custom(self)
        }
    }
}

public extension EKRecurrenceEnd {
    var calendarEndRecurrenceRule: CalendarEventEndRecurrenceRules {
        if let endDate {
            .endDate(endDate)
        } else if occurrenceCount != 0 {
            .occurrenceCount(occurrenceCount)
        } else {
            .never
        }
    }
}
#endif
