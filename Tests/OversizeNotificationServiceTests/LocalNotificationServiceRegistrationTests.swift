//
// Copyright © 2026 Alexander Romanov
// LocalNotificationServiceRegistrationTests.swift
//

#if !os(tvOS)
import FactoryKit
import FactoryTesting
import Foundation
@testable import OversizeNotificationService
import Testing

struct LocalNotificationServiceRegistrationTests {
    @Test(.container)
    func registeredMockReplacesProductionType() {
        Container.shared.localNotificationService.register { MockLocalNotificationService() }

        #expect(Container.shared.localNotificationService() is MockLocalNotificationService)
    }

    @Test(.container)
    func scheduleNotificationForwardsTimeSchedule() async throws {
        let mock = MockLocalNotificationService()
        Container.shared.localNotificationService.register { mock }

        let id = UUID()
        let service = Container.shared.localNotificationService()
        await service.scheduleNotification(
            id: id,
            title: "Title",
            body: "Body",
            timeInterval: 42,
            repeatNotification: true,
            scheduleType: .time,
            dateComponents: DateComponents(),
        )

        let scheduled = try #require(mock.scheduledNotifications.first)
        #expect(scheduled.id == id)
        #expect(scheduled.scheduleType == .time)
        #expect(scheduled.timeInterval == 42)
        #expect(scheduled.repeats)
    }

    @Test(.container)
    func removeRequestIsForwarded() {
        let mock = MockLocalNotificationService()
        Container.shared.localNotificationService.register { mock }

        Container.shared.localNotificationService().removeRequest(withIdentifier: "identifier")

        #expect(mock.removedIdentifiers == ["identifier"])
    }
}
#endif
