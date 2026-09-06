//
// Copyright © 2026 Alexander Romanov
// LocalNotificationTests.swift
//

#if !os(tvOS)
import Foundation
@testable import OversizeNotificationService
import Testing

struct LocalNotificationTests {
    @Test
    func timeIntervalInitializerUsesTimeSchedule() {
        let id = UUID()

        let notification = LocalNotification(
            id: id,
            title: "Title",
            subtitle: "Subtitle",
            body: "Body",
            timeInterval: 60,
            repeats: true,
            userInfo: ["key": "value"],
        )

        #expect(notification.id == id)
        #expect(notification.scheduleType == .time)
        #expect(notification.timeInterval == 60)
        #expect(notification.dateComponents == nil)
        #expect(notification.repeats)
        #expect(notification.subtitle == "Subtitle")
        #expect(notification.userInfo == ["key": "value"])
        #expect(notification.categoryIdentifier == "notification")
    }

    @Test
    func dateComponentsInitializerUsesCalendarSchedule() {
        let components = DateComponents(year: 2026, month: 3, day: 16, hour: 9, minute: 30)

        let notification = LocalNotification(
            id: UUID(),
            categoryIdentifier: "reminder",
            title: "Title",
            body: "Body",
            dateComponents: components,
            repeats: false,
        )

        #expect(notification.scheduleType == .calendar)
        #expect(notification.timeInterval == nil)
        #expect(notification.dateComponents == components)
        #expect(notification.repeats == false)
        #expect(notification.subtitle == nil)
        #expect(notification.categoryIdentifier == "reminder")
    }

    @Test
    func dateInitializerExtractsCalendarComponents() throws {
        var components = DateComponents()
        components.year = 2026
        components.month = 3
        components.day = 16
        components.hour = 9
        components.minute = 30
        let date = try #require(Calendar.current.date(from: components))

        let notification = LocalNotification(id: UUID(), title: "Title", body: "Body", date: date, repeats: false)

        #expect(notification.scheduleType == .calendar)
        #expect(notification.timeInterval == nil)
        #expect(notification.dateComponents?.year == 2026)
        #expect(notification.dateComponents?.month == 3)
        #expect(notification.dateComponents?.day == 16)
        #expect(notification.dateComponents?.hour == 9)
        #expect(notification.dateComponents?.minute == 30)
        #expect(notification.dateComponents?.second == nil)
    }

    @Test
    func bundleImageNameIsPreserved() {
        let timed = LocalNotification(
            id: UUID(),
            title: "Title",
            body: "Body",
            timeInterval: 1,
            bundleImageName: "image",
        )
        let scheduled = LocalNotification(
            id: UUID(),
            title: "Title",
            body: "Body",
            dateComponents: DateComponents(year: 2026, month: 3, day: 16),
            repeats: false,
            bundleImageName: "image",
        )
        let dated = LocalNotification(
            id: UUID(),
            title: "Title",
            body: "Body",
            date: Date(),
            repeats: false,
            bundleImageName: "image",
        )

        #expect(timed.bundleImageName == "image")
        #expect(scheduled.bundleImageName == "image")
        #expect(dated.bundleImageName == "image")
    }

    @Test
    func bundleImageNameDefaultsToNil() {
        let notification = LocalNotification(id: UUID(), title: "Title", body: "Body", timeInterval: 1)

        #expect(notification.bundleImageName == nil)
    }
}
#endif
