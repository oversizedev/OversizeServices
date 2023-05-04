//
// Copyright © 2023 Alexander Romanov
// File.swift, created on 02.05.2023
//

import OversizeLocalizable
import OversizeUI
import SwiftUI

public extension AppError.Enums {
    enum CloudDocuments {
        case deleteItem
        case updateItem
        case savingItem
        case fetchItems
        case notAccess
        case unknown
    }
}

extension AppError.Enums.CloudDocuments: AppErrorProtocol {
    public var title: String {
        switch self {
        case .deleteItem: return "Delete error"
        case .updateItem: return "Update error"
        case .savingItem: return "Saving error"
        case .fetchItems: return "Fetch error"
        case .notAccess: return "No access to iCloud"
        case .unknown: return "Unknown"
        }
    }

    public var subtitle: String? {
        switch self {
        case .notAccess: return L10n.Error.mostLikelyYouNeedToLogInWithYourAppleIDInYourPhoneSettings
        default: return L10n.Error.tryAgainLater
        }
    }

    public var image: Image? {
        Images.Status.error
    }

    public var icon: Image? {
        nil
    }
}
