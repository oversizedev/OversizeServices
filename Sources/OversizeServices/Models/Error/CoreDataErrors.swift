//
// Copyright © 2022 Alexander Romanov
// CoreDataErrors.swift
//

import OversizeLocalizable
import OversizeUI
import SwiftUI

public extension AppError.Enums {
    enum CoreData {
        case deleteItem
        case updateItem
        case savingItem
        case fetchItems
        case unknown
    }
}

extension AppError.Enums.CoreData: AppErrorProtocol {
    public var title: String {
        switch self {
        case .deleteItem: return "Delete error"
        case .updateItem: return "Update error"
        case .savingItem: return "Saving error"
        case .fetchItems: return "Fetch error"
        case .unknown: return "Unknown"
        }
    }

    public var subtitle: String? {
        switch self {
        case .deleteItem: return L10n.Error.tryAgainLater
        case .updateItem: return L10n.Error.tryAgainLater
        case .savingItem: return L10n.Error.tryAgainLater
        case .fetchItems: return L10n.Error.tryAgainLater
        case .unknown: return L10n.Error.tryAgainLater
        }
    }

    public var image: Image? {
        return Images.Status.error
    }

    public var icon: Image? {
        nil
    }
}
