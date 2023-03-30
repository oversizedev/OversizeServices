//
// Copyright © 2023 Alexander Romanov
// ServiceRegistering.swift, created 02.03.2023
//

import Foundation
import OversizeServices

public extension Container {
    static var localNotificationService = Factory<LocalNotificationServiceProtocol> { LocalNotificationService() }
}
