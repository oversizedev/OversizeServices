//
// Copyright © 2023 Alexander Romanov
// OversizeNotificationService.swift
//

import Foundation
import OversizeServices
import UserNotifications

public actor NotificationService {
    // private let notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()
    public init() {}

    public var isAuthorizedToNotify: Bool {
        get async {
            let notificationCenter = UNUserNotificationCenter.current()
            let currentSettings = await notificationCenter.notificationSettings()

            return currentSettings.authorizationStatus == .authorized
        }
    }

    public func requestAuthorizationForNotifications() async throws -> Bool {
        if await isAuthorizedToNotify {
            return true
        } else {
            let notificationCenter = UNUserNotificationCenter.current()
            let authorizationOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            do {
                return try await notificationCenter.requestAuthorization(options: authorizationOptions)
            } catch {
                throw error
            }
        }
    }

    public func createNotification(title: String, subtitle: String, body: String, badge: Int) async {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        notificationContent.subtitle = subtitle
        notificationContent.body = body
        notificationContent.badge = NSNumber(value: badge)
        notificationContent.sound = UNNotificationSound.default

        notificationContent.categoryIdentifier = "TIME"

        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)

        let notificationIdentifier = UUID().uuidString

        let notificationRequest = UNNotificationRequest(identifier: notificationIdentifier,
                                                        content: notificationContent,
                                                        trigger: notificationTrigger)
        
        let notificationCenter = UNUserNotificationCenter.current()
        do {
            try await notificationCenter.add(notificationRequest)
        } catch {
            print("⛔️ \(error.localizedDescription)")
        }
    }

}
