//
// Copyright © 2022 Alexander Romanov
// CloudKitErrors.swift
//

import OversizeLocalizable
import OversizeResources
import SwiftUI

public extension AppError.Enums {
    enum CloudKit {
        case decode
        case noAccount
        case notAccess
        case unknown
    }
}

extension AppError.Enums.CloudKit: AppErrorProtocol {
    public var title: String {
        switch self {
        case .decode: return L10n.Error.dataFromICloudCouldNotBeRead
        case .noAccount: return L10n.Error.looksLikeYouDonTHaveAnICloudAccount
        case .notAccess: return L10n.Error.noAccessToICloud
        case .unknown: return L10n.Error.somethingWentWrongWithICloud
        }
    }

    public var subtitle: String? {
        switch self {
        case .decode: return L10n.Error.updatingAppShouldHelp
        case .noAccount: return L10n.Error.mostLikelyYouNeedToLogInWithYourAppleIDInYourPhoneSettings
        case .notAccess: return L10n.Error.mostLikelyYouNeedToLogInWithYourAppleIDInYourPhoneSettings
        case .unknown: return L10n.Error.tryAgainLater
        }
    }

    public var image: Image? {
        switch self {
        case .decode:
            return Illustration.Objects.Cloud.medium
        default:
            return Illustration.Objects.Error.medium
        }
    }

    public var icon: Image? {
        nil
    }
}
