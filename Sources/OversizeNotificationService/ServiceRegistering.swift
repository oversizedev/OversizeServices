//
// Copyright © 2023 Alexander Romanov
// ServiceRegistering.swift
//

import Foundation
import OversizeServices

public extension Container {
    static var localNotificationService = Factory<LocalNotificationServiceProtocol> { LocalNotificationService() }
}
