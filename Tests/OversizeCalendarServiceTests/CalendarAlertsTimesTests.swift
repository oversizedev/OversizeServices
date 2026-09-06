//
// Copyright © 2026 Alexander Romanov
// CalendarAlertsTimesTests.swift
//

#if !os(tvOS)
import EventKit
import Foundation
@testable import OversizeCalendarService
import Testing

struct CalendarAlertsTimesTests {
    @Test(arguments: [
        (CalendarAlertsTimes.oneMinuteBefore, -60.0, "1 minute before"),
        (CalendarAlertsTimes.fiveMinutesBefore, -300.0, "5 minutes before"),
        (CalendarAlertsTimes.tenMinutesBefore, -600.0, "10 minutes before"),
        (CalendarAlertsTimes.thirtyMinutesBefore, -1800.0, "30 minutes before"),
        (CalendarAlertsTimes.oneHourBefore, -3600.0, "1 hour before"),
        (CalendarAlertsTimes.twoHoursBefore, -7200.0, "2 hours before"),
        (CalendarAlertsTimes.oneDayBefore, -86400.0, "1 day before"),
        (CalendarAlertsTimes.twoDaysBefore, -172_800.0, "2 days before"),
        (CalendarAlertsTimes.oneWeekBefore, -604_800.0, "1 week before"),
    ])
    func alarmOffsetAndTitle(alert: CalendarAlertsTimes, offset: TimeInterval, title: String) {
        #expect(alert.alarm.relativeOffset == offset)
        #expect(alert.title == title)
        #expect(alert.id == title)
    }

    @Test
    func allCasesContainsEveryPredefinedAlert() {
        #expect(CalendarAlertsTimes.allCases.count == 9)
        #expect(CalendarAlertsTimes.allCases.allSatisfy { $0.alarm.relativeOffset < 0 })
    }

    @Test
    func customAlertKeepsProvidedAlarm() {
        let alarm = EKAlarm(relativeOffset: -42)
        let alert = CalendarAlertsTimes.custom(alarm)

        #expect(alert.alarm.relativeOffset == -42)
        #expect(alert.title == "Custom")
        #expect(alert.id == "Custom-42.0")
    }

    @Test
    func knownOffsetIsMappedToPredefinedAlert() {
        let alarm = EKAlarm(relativeOffset: -3600)

        #expect(alarm.calendarAlert == .oneHourBefore)
    }

    @Test
    func unknownOffsetIsMappedToCustomAlert() {
        let alarm = EKAlarm(relativeOffset: -42)

        guard case let .custom(mapped) = alarm.calendarAlert else {
            Issue.record("Expected custom alert")
            return
        }
        #expect(mapped.relativeOffset == -42)
    }
}
#endif
