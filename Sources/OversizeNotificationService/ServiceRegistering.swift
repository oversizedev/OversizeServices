//
// Copyright © 2023 Alexander Romanov
// ServiceRegistering.swift
//

import Factory
import Foundation
import OversizeServices

public extension Container {
    var localNotificationService: Factory<LocalNotificationServiceProtocol> {
        self { LocalNotificationService() }
    }
}
