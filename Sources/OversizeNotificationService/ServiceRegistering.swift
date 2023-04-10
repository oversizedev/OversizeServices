//
// Copyright © 2023 Alexander Romanov
// ServiceRegistering.swift
//

import Foundation
import OversizeServices
import Factory

public extension Container {
    var localNotificationService: Factory<LocalNotificationServiceProtocol> {
        self { LocalNotificationService() }
    }
}
