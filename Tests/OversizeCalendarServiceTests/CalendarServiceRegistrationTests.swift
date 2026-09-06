//
// Copyright © 2026 Alexander Romanov
// CalendarServiceRegistrationTests.swift
//

#if !os(tvOS)
import FactoryKit
import FactoryTesting
@testable import OversizeCalendarService
import Testing

struct CalendarServiceRegistrationTests {
    @Test(.container)
    func calendarServiceIsRegistered() {
        _ = Container.shared.calendarService()
    }

    @Test(.container)
    func calendarServiceUsesUniqueScope() {
        #expect(Container.shared.calendarService() !== Container.shared.calendarService())
    }
}
#endif
