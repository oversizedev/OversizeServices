//
// Copyright © 2022 Alexander Romanov
// ContactsErrors.swift
//

import OversizeLocalizable
import OversizeUI
import SwiftUI

public extension AppError.Enums {
    enum Contacts {
        case notAccess
        case unknown
    }
}

extension AppError.Enums.Contacts: AppErrorProtocol {
    public var title: String {
        switch self {
        case .notAccess: return "No access to the contacts"
        case .unknown: return "Unknown"
        }
    }

    public var subtitle: String? {
        switch self {
        case .notAccess: return "Please allow access to contacts in settings"
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
