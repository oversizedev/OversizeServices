//
// Copyright © 2026 Alexander Romanov
// EKEventStatusTests.swift
//

#if os(iOS) || os(macOS)
import EventKit
@testable import OversizeCalendarService
import Testing

struct EKEventStatusTests {
    @Test(arguments: [
        (EKEventStatus.none, "None"),
        (EKEventStatus.confirmed, "Accept"),
        (EKEventStatus.tentative, "Maybe"),
        (EKEventStatus.canceled, "Decline"),
    ])
    func title(status: EKEventStatus, expected: String) {
        #expect(status.title == expected)
    }
}
#endif
