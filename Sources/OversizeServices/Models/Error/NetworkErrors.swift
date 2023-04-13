//
// Copyright © 2022 Alexander Romanov
// NetworkErrors.swift
//

import OversizeLocalizable
import OversizeUI
import SwiftUI

public extension AppError.Enums {
    enum NetworkError {
        case decode
        case invalidURL
        case noResponse
        case unauthorized
        case unexpectedStatusCode
        case unknown
    }
}

extension AppError.Enums.NetworkError: AppErrorProtocol {
    public var title: String {
        switch self {
        case .decode: return L10n.Error.somethingWentWrong
        case .unauthorized: return L10n.Error.authorisationError
        case .invalidURL: return L10n.Error.invalidRequest
        case .noResponse: return L10n.Error.nothingСameFromServer
        case .unexpectedStatusCode: return L10n.Error.somethingWentWrong
        case .unknown: return L10n.Error.somethingWentWrong
        }
    }

    public var subtitle: String? {
        switch self {
        case .decode: return L10n.Error.somethingStrangeCameFromServer
        case .unauthorized: return L10n.Error.looksLikeYouNeedToLogin
        case .invalidURL: return L10n.Error.looksLikeTheAppIsBroken
        case .noResponse: return L10n.Error.tryAgainLater
        case .unexpectedStatusCode: return L10n.Error.somethingStrangeCameFromServer
        case .unknown: return L10n.Error.tryAgainLater
        }
    }

    public var image: Image? {
        switch self {
        default: return Images.Status.error
        }
    }

    public var icon: Image? {
        nil
    }
}
