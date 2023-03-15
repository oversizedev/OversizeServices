//
// Copyright © 2023 Alexander Romanov
// ServiceRegistering.swift
//

//
//
// Copyright © 02.03.2023 Aleksandr Romanov
// File.swift, created on 02.03.2023
//
import Foundation
import OversizeServices

public extension Container {
    static var notificationService = Factory { NotificationService() }
}
