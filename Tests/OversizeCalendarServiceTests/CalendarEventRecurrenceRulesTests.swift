//
// Copyright © 2026 Alexander Romanov
// CalendarEventRecurrenceRulesTests.swift
//

#if !os(tvOS)
import EventKit
import Foundation
@testable import OversizeCalendarService
import Testing

struct CalendarEventRecurrenceRulesTests {
    @Test
    func neverHasNoRule() {
        #expect(CalendarEventRecurrenceRules.never.rule == nil)
    }

    @Test(arguments: [
        (CalendarEventRecurrenceRules.everyDay, EKRecurrenceFrequency.daily, 1),
        (CalendarEventRecurrenceRules.everyWorkingDay, EKRecurrenceFrequency.weekly, 1),
        (CalendarEventRecurrenceRules.everyWeekend, EKRecurrenceFrequency.weekly, 1),
        (CalendarEventRecurrenceRules.everyWeek, EKRecurrenceFrequency.weekly, 1),
        (CalendarEventRecurrenceRules.everyTwoWeeks, EKRecurrenceFrequency.weekly, 2),
        (CalendarEventRecurrenceRules.everyMonth, EKRecurrenceFrequency.monthly, 1),
        (CalendarEventRecurrenceRules.everyYear, EKRecurrenceFrequency.yearly, 1),
    ])
    func frequencyAndInterval(rule: CalendarEventRecurrenceRules, frequency: EKRecurrenceFrequency, interval: Int) throws {
        let recurrenceRule = try #require(rule.rule)

        #expect(recurrenceRule.frequency == frequency)
        #expect(recurrenceRule.interval == interval)
        #expect(recurrenceRule.recurrenceEnd == nil)
    }

    @Test
    func workingDayRuleContainsWeekdaysOnly() throws {
        let rule = try #require(CalendarEventRecurrenceRules.everyWorkingDay.rule)
        let days = try #require(rule.daysOfTheWeek).map(\.dayOfTheWeek)

        #expect(days == [.monday, .tuesday, .wednesday, .thursday, .friday])
    }

    @Test
    func weekendRuleContainsWeekendDaysOnly() throws {
        let rule = try #require(CalendarEventRecurrenceRules.everyWeekend.rule)
        let days = try #require(rule.daysOfTheWeek).map(\.dayOfTheWeek)

        #expect(days == [.saturday, .sunday])
    }

    @Test
    func allCasesAreIdentifiedByTitle() {
        #expect(CalendarEventRecurrenceRules.allCases.count == 8)
        #expect(CalendarEventRecurrenceRules.allCases.allSatisfy { $0.id == $0.title })
        #expect(Set(CalendarEventRecurrenceRules.allCases.map(\.id)).count == 8)
    }

    @Test
    func customRuleKeepsProvidedValue() {
        let custom = EKRecurrenceRule(recurrenceWith: .monthly, interval: 3, end: nil)

        #expect(CalendarEventRecurrenceRules.custom(custom).rule == custom)
        #expect(CalendarEventRecurrenceRules.custom(nil).rule == nil)
    }
}

struct CalendarEventEndRecurrenceRulesTests {
    @Test
    func neverHasNoEnd() {
        #expect(CalendarEventEndRecurrenceRules.never.end == nil)
        #expect(CalendarEventEndRecurrenceRules.never.title == "Never")
    }

    @Test
    func occurrenceCountIsPreserved() throws {
        let end = try #require(CalendarEventEndRecurrenceRules.occurrenceCount(5).end)

        #expect(end.occurrenceCount == 5)
        #expect(end.endDate == nil)
    }

    @Test
    func endDateIsPreserved() throws {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let end = try #require(CalendarEventEndRecurrenceRules.endDate(date).end)

        #expect(end.endDate == date)
        #expect(end.occurrenceCount == 0)
    }
}
#endif
