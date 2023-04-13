//
// Copyright © 2023 Alexander Romanov
// NotificationsErrors.swift
//

import OversizeLocalizable
import OversizeUI
import SwiftUI

public extension AppError.Enums {
    enum Notification {
        case notDetermined
        case notAccess
        case unknown
    }
}

extension AppError.Enums.Notification: AppErrorProtocol {
    public var title: String {
        switch self {
        case .notDetermined: return "Select notificatons settings"
        case .notAccess: return "No access to notificatons"
        case .unknown: return "Unknown"
        }
    }

    public var subtitle: String? {
        switch self {
        case .notDetermined: return nil
        case .notAccess: return "Please access to notifications in settings"
        default: return L10n.Error.tryAgainLater
        }
    }

    public var image: Image? {
        return Images.Status.error
    }

    public var icon: Image? {
        nil
    }
}
