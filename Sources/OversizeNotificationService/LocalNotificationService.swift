//
// Copyright © 2023 Alexander Romanov
// LocalNotificationService.swift
//

import OversizeCore
import OversizeModels
import SwiftUI
import UserNotifications

#if !os(tvOS)
    public protocol LocalNotificationServiceProtocol {
        func requestAuthorization() async throws
        func fetchCurrentSettings() async
        func schedule(localNotification: LocalNotification) async
        func scheduleNotification(id: UUID, title: String, body: String, timeInterval: Double, repeatNotification: Bool, scheduleType: LocalNotification.ScheduleType, dateComponents: DateComponents) async
        func fetchPendingIds() async -> [String]
        func removeRequest(withIdentifier identifier: String)
        func requestAccess() async -> Result<Bool, AppError>
    }

    public final class LocalNotificationService: NSObject {
        let notificationCenter = UNUserNotificationCenter.current()
        var isGranted = false
        var pendingRequests: [UNNotificationRequest] = []
        @AppStorage("SettingsStore.SilentNotificationSetting") var silentNotificationSetting: Bool = false

        override public init() {
            super.init()
            notificationCenter.delegate = self
        }
    }

    extension LocalNotificationService: LocalNotificationServiceProtocol {
        public func requestAuthorization() async throws {
            try await notificationCenter.requestAuthorization(options: [.sound, .badge, .alert])
            await fetchCurrentSettings()
        }

        public func fetchCurrentSettings() async {
            let currentSettings = await notificationCenter.notificationSettings()
            isGranted = (currentSettings.authorizationStatus == .authorized)
        }

        public func requestAccess() async -> Result<Bool, AppError> {
            let _ = try? await requestAuthorization()
            let currentSettings = await notificationCenter.notificationSettings()
            switch currentSettings.authorizationStatus {
            case .notDetermined:
                return .failure(.notifications(type: .notDetermined))
            case .denied:
                return .failure(.notifications(type: .notAccess))
            case .authorized:
                return .success(true)
            case .provisional:
                return .failure(.notifications(type: .notAccess))
            case .ephemeral:
                return .failure(.notifications(type: .notAccess))
            @unknown default:
                return .failure(.notifications(type: .unknown))
            }
        }

        public func scheduleNotification(
            id: UUID = UUID(),
            title: String, body: String,
            timeInterval: Double = 5,
            repeatNotification: Bool = false,
            scheduleType: LocalNotification.ScheduleType,
            dateComponents: DateComponents = Calendar.current.dateComponents([.day, .minute, .second], from: Date.now)
        ) {
            Task {
                switch scheduleType {
                case .time:
                    let localNotification = LocalNotification(id: id,
                                                              title: title,
                                                              body: body,
                                                              timeInterval: timeInterval,
                                                              repeats: repeatNotification)
                    await schedule(localNotification: localNotification)
                case .calendar:
                    let localNotification = LocalNotification(id: id,
                                                              title: title,
                                                              body: body,
                                                              dateComponents: dateComponents,
                                                              repeats: repeatNotification)
                    await schedule(localNotification: localNotification)
                }
            }
        }

        public func schedule(localNotification: LocalNotification) async {
            let content = UNMutableNotificationContent()
            content.title = localNotification.title
            content.body = localNotification.body
            content.categoryIdentifier = localNotification.categoryIdentifier

            if let subtitle = localNotification.subtitle {
                content.subtitle = subtitle
            }
            if let bundleImageName = localNotification.bundleImageName {
                if let url = Bundle.main.url(forResource: bundleImageName, withExtension: "") {
                    if let attachment = try? UNNotificationAttachment(identifier: bundleImageName, url: url) {
                        content.attachments = [attachment]
                    }
                }
            }
            if let userInfo = localNotification.userInfo {
                content.userInfo = userInfo
            }

            if !silentNotificationSetting {
                content.sound = .default
            }

            if localNotification.scheduleType == .time {
                guard let timeInterval = localNotification.timeInterval else { return }
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval,
                                                                repeats: localNotification.repeats)
                let request = UNNotificationRequest(identifier: localNotification.id.uuidString, content: content, trigger: trigger)
                try? await notificationCenter.add(request)
            } else {
                guard let dateComponents = localNotification.dateComponents else { return }
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: localNotification.repeats)
                let request = UNNotificationRequest(identifier: localNotification.id.uuidString, content: content, trigger: trigger)
                try? await notificationCenter.add(request)
            }
            await fetchPendingRequests()
        }

        public func fetchPendingRequests() async {
            pendingRequests = await notificationCenter.pendingNotificationRequests()
        }

        public func fetchPendingIds() async -> [String] {
            pendingRequests = await notificationCenter.pendingNotificationRequests()
            return pendingRequests.compactMap { $0.identifier }
        }

        public func removeRequest(withIdentifier identifier: String) {
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
            if let index = pendingRequests.firstIndex(where: { $0.identifier == identifier }) {
                pendingRequests.remove(at: index)
            }
        }

        public func removeAllRequests(ignoreNotifications: [String] = []) {
            if ignoreNotifications.isEmpty {
                notificationCenter.removeAllPendingNotificationRequests()
                pendingRequests.removeAll()
            } else {
                for request in pendingRequests {
                    if !(ignoreNotifications.contains(request.identifier)) {
                        removeRequest(withIdentifier: request.identifier)
                    }
                }
            }
        }
    }

    extension LocalNotificationService: UNUserNotificationCenterDelegate {
        public func userNotificationCenter(_: UNUserNotificationCenter, willPresent _: UNNotification) async -> UNNotificationPresentationOptions {
            await fetchPendingRequests()
            if !silentNotificationSetting {
                return [.sound, .banner]
            } else {
                return [.banner]
            }
        }

        public func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("Deeplink"), object: nil, userInfo: response.notification.request.content.userInfo)
            }
        }
    }
#endif
