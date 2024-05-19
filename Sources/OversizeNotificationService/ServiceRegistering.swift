//
// Copyright © 2023 Alexander Romanov
// ServiceRegistering.swift
//

import Factory
import Foundation

#if !os(tvOS)
    public extension Container {
        var localNotificationService: Factory<LocalNotificationServiceProtocol> {
            self { LocalNotificationService() }
        }
    }
#endif
