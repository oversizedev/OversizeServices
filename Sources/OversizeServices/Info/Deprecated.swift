//
// Copyright © 2022 Alexander Romanov
// Deprecated.swift
//

import Foundation

// MARK: - Deprecated Compatibility

public extension Info {
    @available(*, deprecated, renamed: "App")
    typealias app = App

    @available(*, deprecated, renamed: "Developer")
    typealias developer = Developer

    @available(*, deprecated, renamed: "Company")
    typealias company = Company

    @available(*, deprecated, message: "URLs moved to App, Developer, Company")
    typealias url = URLs
}

public extension Info.App {
    @available(*, deprecated, renamed: "appStoreId")
    static var appStoreID: String? {
        appStoreId
    }

    @available(*, deprecated, renamed: "bundleId")
    static var bundleID: String? {
        bundleId
    }

    @available(*, deprecated, renamed: "telegramChatId")
    static var telegramChatID: String? {
        telegramChatId
    }

    @available(*, deprecated, renamed: "alternateIconNames")
    static var alternateIconsNames: [String] {
        alternateIconNames
    }

    @available(*, deprecated, renamed: "osVersion")
    @MainActor static var system: String? {
        osVersion
    }

    @available(*, deprecated, renamed: "localeIdentifier")
    static var language: String? {
        localeIdentifier
    }

    @available(*, deprecated, renamed: "appStoreUrl")
    static var appStoreURL: URL? {
        appStoreUrl
    }

    @available(*, deprecated, renamed: "appStoreReviewUrl")
    static var appStoreReviewURL: URL? {
        appStoreReviewUrl
    }

    @available(*, deprecated, renamed: "websiteUrl")
    static var websiteURL: URL? {
        websiteUrl
    }

    @available(*, deprecated, renamed: "privacyPolicyUrl")
    static var privacyPolicyURL: URL? {
        privacyPolicyUrl
    }

    @available(*, deprecated, renamed: "termsOfUseUrl")
    static var termsOfUseURL: URL? {
        termsOfUseUrl
    }

    @available(*, deprecated, renamed: "telegramChatUrl")
    static var telegramChatURL: URL? {
        telegramChatUrl
    }
}

public extension Info.Developer {
    @available(*, deprecated, renamed: "websiteUrl")
    static var url: String? {
        websiteUrl?.absoluteString
    }

    @available(*, deprecated, renamed: "websiteUrl")
    static var website: String? {
        websiteUrl?.absoluteString
    }

    @available(*, deprecated, renamed: "emailUrl")
    static var emailURL: URL? {
        emailUrl
    }

    @available(*, deprecated, renamed: "appsUrl")
    static var appsURL: URL? {
        appsUrl
    }
}

public extension Info.Company {
    @available(*, deprecated, renamed: "websiteUrl")
    static var url: URL? {
        websiteUrl
    }

    @available(*, deprecated, renamed: "appStoreId")
    static var appStoreID: String? {
        appStoreId
    }

    @available(*, deprecated, renamed: "twitterUsername")
    static var twitterID: String? {
        twitterUsername
    }

    @available(*, deprecated, renamed: "dribbbleUsername")
    static var dribbbleID: String? {
        dribbbleUsername
    }

    @available(*, deprecated, renamed: "instagramUsername")
    static var instagramID: String? {
        instagramUsername
    }

    @available(*, deprecated, renamed: "facebookUsername")
    static var facebookID: String? {
        facebookUsername
    }

    @available(*, deprecated, renamed: "telegramUsername")
    static var telegramID: String? {
        telegramUsername
    }

    @available(*, deprecated, renamed: "cdnUrl")
    static var cdnURL: URL? {
        cdnUrl
    }

    @available(*, deprecated, renamed: "emailUrl")
    static var emailURL: URL? {
        emailUrl
    }

    @available(*, deprecated, renamed: "telegramUrl")
    static var telegramURL: URL? {
        telegramUrl
    }

    @available(*, deprecated, renamed: "facebookUrl")
    static var facebookURL: URL? {
        facebookUrl
    }

    @available(*, deprecated, renamed: "twitterUrl")
    static var twitterURL: URL? {
        twitterUrl
    }

    @available(*, deprecated, renamed: "dribbbleUrl")
    static var dribbbleURL: URL? {
        dribbbleUrl
    }

    @available(*, deprecated, renamed: "instagramUrl")
    static var instagramURL: URL? {
        instagramUrl
    }
}

// MARK: - Deprecated URLs Enum

@available(*, deprecated, message: "Use Info.App, Info.Developer, Info.Company instead")
public extension Info {
    enum URLs: Sendable {
        @available(*, deprecated, renamed: "Info.App.appStoreReviewUrl")
        public static var appStoreReview: URL? {
            App.appStoreReviewUrl
        }

        @available(*, deprecated, renamed: "Info.App.appStoreUrl")
        public static var appStore: URL? {
            App.appStoreUrl
        }

        @available(*, deprecated, renamed: "Info.Developer.emailUrl")
        public static var developerEmail: URL? {
            Developer.emailUrl
        }

        @available(*, deprecated, renamed: "Info.Developer.appsUrl")
        public static var developerApps: URL? {
            Developer.appsUrl
        }

        @available(*, deprecated, renamed: "Info.App.telegramChatUrl")
        public static var telegramChat: URL? {
            App.telegramChatUrl
        }

        @available(*, deprecated, renamed: "Info.App.websiteUrl")
        public static var app: URL? {
            App.websiteUrl
        }

        @available(*, deprecated, renamed: "Info.App.privacyPolicyUrl")
        public static var privacyPolicy: URL? {
            App.privacyPolicyUrl
        }

        @available(*, deprecated, renamed: "Info.App.termsOfUseUrl")
        public static var termsOfUse: URL? {
            App.termsOfUseUrl
        }

        @available(*, deprecated, renamed: "Info.Company.cdnUrl")
        public static var companyCDN: URL? {
            Company.cdnUrl
        }

        @available(*, deprecated, renamed: "Info.Company.emailUrl")
        public static var companyEmail: URL? {
            Company.emailUrl
        }

        @available(*, deprecated, renamed: "Info.Company.telegramUrl")
        public static var companyTelegram: URL? {
            Company.telegramUrl
        }

        @available(*, deprecated, renamed: "Info.Company.facebookUrl")
        public static var companyFacebook: URL? {
            Company.facebookUrl
        }

        @available(*, deprecated, renamed: "Info.Company.twitterUrl")
        public static var companyTwitter: URL? {
            Company.twitterUrl
        }

        @available(*, deprecated, renamed: "Info.Company.dribbbleUrl")
        public static var companyDribbble: URL? {
            Company.dribbbleUrl
        }

        @available(*, deprecated, renamed: "Info.Company.instagramUrl")
        public static var companyInstagram: URL? {
            Company.instagramUrl
        }

        @available(*, deprecated, renamed: "Info.App.appStoreUrl")
        public static var appInstallShare: URL? {
            App.appStoreUrl
        }

        @available(*, deprecated, renamed: "Info.Developer.emailUrl")
        public static var developerSendMail: URL? {
            Developer.emailUrl
        }

        @available(*, deprecated, renamed: "Info.Developer.appsUrl")
        public static var developerAllApps: URL? {
            Developer.appsUrl
        }

        @available(*, deprecated, renamed: "Info.App.telegramChatUrl")
        public static var appTelegramChat: URL? {
            App.telegramChatUrl
        }

        @available(*, deprecated, renamed: "Info.App.websiteUrl")
        public static var appUrl: URL? {
            App.websiteUrl
        }

        @available(*, deprecated, renamed: "Info.App.privacyPolicyUrl")
        public static var appPrivacyPolicyUrl: URL? {
            App.privacyPolicyUrl
        }

        @available(*, deprecated, renamed: "Info.App.termsOfUseUrl")
        public static var appTermsOfUseUrl: URL? {
            App.termsOfUseUrl
        }

        @available(*, deprecated, renamed: "Info.Company.cdnUrl")
        public static var companyCdnUrl: URL? {
            Company.cdnUrl
        }
    }
}

// MARK: - Links

public struct Links: Codable, Sendable {
    public var app: App?
    public var developer: Developer
    public var company: Company

    private enum CodingKeys: String, CodingKey, Sendable {
        case app = "App"
        case developer = "Developer"
        case company = "Company"
    }

    public struct App: Codable, Hashable, Sendable {
        public var telegramChat: String?
        public var appStoreId: String

        private enum CodingKeys: String, CodingKey, Sendable {
            case telegramChat = "TelegramChat"
            case appStoreId = "AppStoreID"
        }
    }

    public struct Developer: Codable, Hashable, Sendable {
        public var name: String?
        public var url: String?
        public var email: String?
        public var facebook: String?
        public var telegram: String?

        private enum CodingKeys: String, CodingKey, Sendable {
            case name = "Name"
            case url = "Url"
            case email = "Email"
            case facebook = "Facebook"
            case telegram = "Telegram"
        }
    }

    public struct Company: Codable, Hashable, Sendable {
        public var name: String?
        public var urlString: String?
        public var email: String?
        public var appStoreId: String
        public var facebook: String?
        public var telegram: String?
        public var dribbble: String?
        public var instagram: String?
        public var twitter: String?
        public var cdnString: String?

        public var url: URL? {
            URL(string: urlString ?? "")
        }

        private enum CodingKeys: String, CodingKey {
            case name = "Name"
            case urlString = "Url"
            case email = "Email"
            case appStoreId = "AppStoreID"
            case facebook = "Facebook"
            case telegram = "Telegram"
            case dribbble = "Dribbble"
            case instagram = "Instagram"
            case twitter = "Twitter"
            case cdnString = "CDNUrl"
        }
    }
}

// MARK: - PlistConfiguration (Legacy)

public struct PlistConfiguration: Codable, Sendable {
    public var links: Links

    private enum CodingKeys: String, CodingKey, Sendable {
        case links = "Links"
    }
}

public final class PlistService: Sendable {
    public static let shared: PlistService = .init()
    public init() {}

    public func getStringArrayFromDictionary(field: String, dictionary: String, plist: String) -> [String] {
        guard let filePath = Bundle.main.path(forResource: plist, ofType: "plist") else {
            return []
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let links = plist?.object(forKey: dictionary) as? [String: Any] else {
            return []
        }
        return links[field] as? [String] ?? []
    }

    public func getBoolFromDictionary(field: String, dictionary: String, plist: String) -> Bool? {
        guard let filePath = Bundle.main.path(forResource: plist, ofType: "plist") else {
            return nil
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let links = plist?.object(forKey: dictionary) as? [String: Any] else {
            return nil
        }
        return links[field] as? Bool
    }

    public func getIntFromDictionary(field: String, dictionary: String, plist: String) -> Int? {
        guard let filePath = Bundle.main.path(forResource: plist, ofType: "plist") else {
            return nil
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let links = plist?.object(forKey: dictionary) as? [String: Any] else {
            return nil
        }
        return links[field] as? Int
    }

    public func getStringFromDictionary(field: String, dictionary: String, plist: String) -> String? {
        guard let filePath = Bundle.main.path(forResource: plist, ofType: "plist") else {
            return nil
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let links = plist?.object(forKey: dictionary) as? [String: Any] else {
            return nil
        }
        return links[field] as? String
    }

    public func getString(field: String, plist: String) -> String? {
        guard let filePath = Bundle.main.path(forResource: plist, ofType: "plist") else {
            return nil
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: field) as? String else {
            return nil
        }
        return value
    }
}
