//
// Copyright © 2022 Alexander Romanov
// LocationErrors.swift
//

import OversizeLocalizable
import OversizeResources
import SwiftUI

public extension AppError.Enums {
    enum Location {
        case notDetermined
        case notAccess
        case unknown
    }
}

extension AppError.Enums.Location: AppErrorProtocol {
    public var title: String {
        switch self {
        case .notDetermined: return L10n.Error.selectLocationSettings
        case .notAccess: return L10n.Error.noAccessToLocation
        case .unknown: return L10n.Error.noAccessToLocation
        }
    }

    public var subtitle: String? {
        switch self {
        case .notDetermined: return L10n.Error.withoutAccessToLocationApplicationCannotWork
        case .notAccess: return L10n.Error.pleaseAllowAccessToLocationInSettings
        case .unknown: return L10n.Error.somethingIsWrongWithTheLocation
        }
    }

    public var image: Image? {
        switch self {
        case .notDetermined:
            return Illustration.Objects.Pin.medium
        case .notAccess:
            return Illustration.Objects.Pin.medium
        case .unknown:
            return Illustration.Objects.Error.medium
        }
    }

    public var icon: Image? {
        nil
    }
}
