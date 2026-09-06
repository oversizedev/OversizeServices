//
// Copyright © 2026 Alexander Romanov
// MockLocalNotificationService.swift
//

#if !os(tvOS)
import Foundation
import OversizeNotificationService

final class MockLocalNotificationService: LocalNotificationServiceProtocol, @unchecked Sendable {
    private let scheduled: LockedBox<[LocalNotification]> = .init([])
    private let removed: LockedBox<[String]> = .init([])
    private let pending: LockedBox<[String]> = .init([])

    var scheduledNotifications: [LocalNotification] {
        scheduled.current
    }

    var removedIdentifiers: [String] {
        removed.current
    }

    func setPendingIds(_ ids: [String]) {
        pending.mutate { $0 = ids }
    }

    func requestAuthorization() async throws {}

    func fetchCurrentSettings() async {}

    func schedule(localNotification: LocalNotification) async {
        scheduled.mutate { $0.append(localNotification) }
    }

    func scheduleNotification(
        id: UUID,
        title: String,
        body: String,
        timeInterval: Double,
        repeatNotification: Bool,
        scheduleType: LocalNotification.ScheduleType,
        dateComponents: DateComponents,
    ) async {
        let notification = switch scheduleType {
        case .time:
            LocalNotification(id: id, title: title, body: body, timeInterval: timeInterval, repeats: repeatNotification)
        case .calendar:
            LocalNotification(id: id, title: title, body: body, dateComponents: dateComponents, repeats: repeatNotification)
        }
        await schedule(localNotification: notification)
    }

    func fetchPendingIds() async -> [String] {
        pending.current
    }

    func removeRequest(withIdentifier identifier: String) {
        removed.mutate { $0.append(identifier) }
    }

    func requestAccess() async -> Result<Bool, Error> {
        .success(true)
    }
}
#endif
