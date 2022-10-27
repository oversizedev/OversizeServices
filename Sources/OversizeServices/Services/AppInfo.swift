//
// Copyright © 2022 Alexander Romanov
// AppInfo.swift
//

import Foundation
import SwiftUI
import UIKit

// swiftlint:disable all
public enum AppInfo {
    private static let configName = "AppConfig"
    private static let linksDictonaryName = "Links"
    private static let storeDictonaryName = "Store"

    public enum app {
        public static var verstion: String? {
            Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        }

        public static var build: String? {
            Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        }

        public static var device: String? {
            #if os(iOS)
                return UIDevice.current.model
            #else
                return nil
            #endif
        }

        public static var system: String? {
            #if os(iOS)
                return UIDevice.current.systemName + " " + UIDevice.current.systemVersion
            #else
                return nil
            #endif
        }

        public static var language: String? {
            Locale.current.identifier
        }

        public static var name: String? {
            Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        }

        public static var appStoreID: String? {
            let value = PlistService.shared.getStringFromDictionary(field: "AppStoreID", dictionary: linksDictonaryName, plist: configName)
            return value
        }

        public static var bundleID: String? {
            Bundle.main.bundleIdentifier
        }

        public static var facebookMessengerChatID: String? {
            let value = PlistService.shared.getStringFromDictionary(field: "AppFacebookMessengerChatID", dictionary: linksDictonaryName, plist: configName)
            return value
        }

        public static var telegramChatID: String? {
            let value = PlistService.shared.getStringFromDictionary(field: "AppTelegramChatID", dictionary: linksDictonaryName, plist: configName)
            return value
        }

        public static var iconName: String? {
            guard let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
                  let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
                  let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
                  let iconFileName = iconFiles.last
            else { return nil }
            return iconFileName
        }
    }

    public enum developer {
        public static var url: String? {
            let value = PlistService.shared.getStringFromDictionary(field: "DeveloperURL", dictionary: linksDictonaryName, plist: configName)
            return value
        }

        public static var email: String? {
            let value = PlistService.shared.getStringFromDictionary(field: "DeveloperEmail", dictionary: linksDictonaryName, plist: configName)
            return value
        }

        public static var name: String? {
            let value = PlistService.shared.getStringFromDictionary(field: "DeveloperName", dictionary: linksDictonaryName, plist: configName)
            return value
        }

        public static var company: String? {
            let value = PlistService.shared.getStringFromDictionary(field: "DeveloperCompany", dictionary: linksDictonaryName, plist: configName)
            return value
        }

        public static var appStoreID: String? {
            let value = PlistService.shared.getStringFromDictionary(field: "DeveloperAppStoreID", dictionary: linksDictonaryName, plist: configName)
            return value
        }

        public static var telegramAccountID: String? {
            let value = PlistService.shared.getStringFromDictionary(field: "DeveloperTelegramAccountID", dictionary: linksDictonaryName, plist: configName)
            return value
        }

        public static var facebookAccountID: String? {
            let value = PlistService.shared.getStringFromDictionary(field: "DeveloperFacebookAccountID", dictionary: linksDictonaryName, plist: configName)
            return value
        }

        public static var companyTwitterID: String? {
            let value = PlistService.shared.getStringFromDictionary(field: "TwitterID", dictionary: linksDictonaryName, plist: configName)
            return value
        }

        public static var companyDribbbleID: String? {
            let value = PlistService.shared.getStringFromDictionary(field: "DribbbleID", dictionary: linksDictonaryName, plist: configName)
            return value
        }

        public static var companyInstagramID: String? {
            let value = PlistService.shared.getStringFromDictionary(field: "InstagramID", dictionary: linksDictonaryName, plist: configName)
            return value
        }

        public static var companyFacebookID: String? {
            let value = PlistService.shared.getStringFromDictionary(field: "FacebookID", dictionary: linksDictonaryName, plist: configName)
            return value
        }

        public static var companyTelegramID: String? {
            let value = PlistService.shared.getStringFromDictionary(field: "TelegramCompanyID", dictionary: linksDictonaryName, plist: configName)
            return value
        }
    }

    public enum company {
        public static var url: URL? {
            guard let value: String = PlistService.shared.getStringFromDictionary(field: "CompanyURL", dictionary: linksDictonaryName, plist: configName) else { return nil }
            guard let url = URL(string: value) else { return nil }
            return url
        }
    }

    public enum url {
        public static var appStoreReview: URL? {
            guard app.appStoreID != nil else { return nil }
            let url = URL(string: "itms-apps:itunes.apple.com/us/app/apple-store/id\(app.appStoreID!)?mt=8&action=write-review")
            return url
        }

        public static var appInstallShare: URL? {
            guard app.appStoreID != nil else { return nil }
            let url = URL(string: "https://itunes.apple.com/us/app/apple-store/id\(app.appStoreID!)")
            return url
        }

        public static var developerSendMail: URL? {
            guard developer.email != nil else { return nil }
            let mail = URL(string: "mailto:\(developer.email!)")
            return mail
        }

        public static var developerAllApps: URL? {
            guard developer.appStoreID != nil else { return nil }
            let url = URL(string: "itms-apps://itunes.apple.com/developer/id\(developer.appStoreID!)")
            return url
        }

        public static var appTelegramChat: URL? {
            guard app.telegramChatID != nil else { return nil }
            let url = URL(string: "https://t.me/\(app.telegramChatID!)")
            return url
        }

        public static var developerTelegram: URL? {
            guard developer.telegramAccountID != nil else { return nil }
            let url = URL(string: "https://t.me/\(developer.telegramAccountID!)")
            return url
        }

        public static var developerFacebook: URL? {
            guard developer.facebookAccountID != nil else { return nil }
            let url = URL(string: "https://www.facebook.com/\(developer.facebookAccountID!)")
            return url
        }

        public static var appPrivacyPolicyUrl: URL? {
            let urlString = PlistService.shared.getStringFromDictionary(field: "AppPrivacyPolicyURL", dictionary: linksDictonaryName, plist: configName)
            let url = URL(string: urlString ?? "")
            return url
        }

        public static var appTermsOfUseUrl: URL? {
            let urlString = PlistService.shared.getStringFromDictionary(field: "AppTermsOfUseURL", dictionary: linksDictonaryName, plist: configName)
            let url = URL(string: urlString ?? "")
            return url
        }

        public static var companyTelegram: URL? {
            guard let id = developer.companyTelegramID else { return nil }
            guard let url = URL(string: "https://www.t.me/\(id)") else { return nil }
            return url
        }

        public static var companyFacebook: URL? {
            guard let id = developer.companyFacebookID else { return nil }
            guard let url = URL(string: "https://www.facebook.com/\(id)") else { return nil }
            return url
        }

        public static var companyTwitter: URL? {
            guard let id = developer.companyTwitterID else { return nil }
            guard let url = URL(string: "https://www.twitter.com/\(id)") else { return nil }
            return url
        }

        public static var companyDribbble: URL? {
            guard let id = developer.companyDribbbleID else { return nil }
            guard let url = URL(string: "https://www.dribbble.com/\(id)") else { return nil }
            return url
        }

        public static var companyInstagram: URL? {
            guard let id = developer.companyInstagramID else { return nil }
            guard let url = URL(string: "https://www.instagram.com/\(id)") else { return nil }
            return url
        }
    }

    public static var apps: [App] {
        guard let filePath = Bundle.main.url(forResource: configName, withExtension: "plist") else {
            fatalError("Couldn't find file \(configName).plist'.")
        }
        let data = try! Data(contentsOf: filePath)
        let decoder: PropertyListDecoder = .init()
        do {
            let decodeData = try decoder.decode(PlistConfiguration.self, from: data)
            return decodeData.apps
        } catch {
            return []
        }
    }

    public static var links: Links? {
        guard let filePath = Bundle.main.url(forResource: configName, withExtension: "plist") else {
            fatalError("Couldn't find file \(configName).plist'.")
        }
        let data = try! Data(contentsOf: filePath)
        let decoder: PropertyListDecoder = .init()
        do {
            let decodeData = try decoder.decode(PlistConfiguration.self, from: data)
            if let features = decodeData.links {
                return features
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }

    public enum store {
        public static var features: [StoreFeature] {
            guard let filePath = Bundle.main.url(forResource: configName, withExtension: "plist") else {
                fatalError("Couldn't find file \(configName).plist'.")
            }
            let data = try! Data(contentsOf: filePath)
            let decoder: PropertyListDecoder = .init()
            do {
                let decodeData = try decoder.decode(PlistConfiguration.self, from: data)
                if let features = decodeData.store?.features {
                    return features
                } else {
                    return []
                }
            } catch {
                return []
            }
        }

        public func parseConfig() -> PlistConfiguration {
            let url = Bundle.main.url(forResource: configName, withExtension: "plist")!
            let data = try! Data(contentsOf: url)
            let decoder: PropertyListDecoder = .init()
            return try! decoder.decode(PlistConfiguration.self, from: data)
        }

        public static var bannerLabel: String {
            let value = PlistService.shared.getStringFromDictionary(field: "BannerLabel", dictionary: storeDictonaryName, plist: configName)
            return value ?? ""
        }

        public static var subscriptionsName: String {
            let value = PlistService.shared.getStringFromDictionary(field: "SubscriptionsName", dictionary: storeDictonaryName, plist: configName)
            return value ?? ""
        }

        public static var subscriptionsDescription: String {
            let value = PlistService.shared.getStringFromDictionary(field: "SubscriptionsDescription", dictionary: storeDictonaryName, plist: configName)
            return value ?? ""
        }

        public static var secretKey: String {
            let value = PlistService.shared.getStringFromDictionary(field: "SecretKey", dictionary: storeDictonaryName, plist: configName)
            return value ?? ""
        }

        public static var productIdentifiers: [String] {
            let value = PlistService.shared.getStringArrayFromDictionary(field: "ProductIdentifiers", dictionary: storeDictonaryName, plist: configName)
            return value
        }
    }

    public static var all: PlistConfiguration? {
        let url = Bundle.main.url(forResource: configName, withExtension: "plist")!
        let data = try! Data(contentsOf: url)
        let decoder: PropertyListDecoder = .init()
        return try? decoder.decode(PlistConfiguration.self, from: data)
    }
}

public struct PlistConfiguration: Codable {
    public var store: Store?
    public var apps: [App]
    public var links: Links?

    private enum CodingKeys: String, CodingKey {
        case store = "Store"
        case apps = "Apps"
        case links = "Links"
    }
}

public struct Links: Codable {
    public var app: App
    public var developer: Developer
    public var company: Company

    private enum CodingKeys: String, CodingKey {
        case app = "App"
        case developer = "Developer"
        case company = "Company"
    }

    public struct App: Codable, Hashable {
        public var urlString: String?
        public var telegramChat: String?
        public var appStore: String?

        public var url: URL? {
            URL(string: urlString ?? "")
        }

        public var privacyPolicyURL: URL? {
            URL(string: "\(urlString ?? "")/privacy-policy")
        }

        public var termsOfUseURL: URL? {
            URL(string: "\(urlString ?? "")/terms-and-conditions")
        }

        private enum CodingKeys: String, CodingKey {
            case urlString = "Url"
            case telegramChat = "TelegramChat"
            case appStore = "AppStore"
        }
    }

    public struct Developer: Codable, Hashable {
        public var name: String?
        public var url: String?
        public var email: String?
        public var fecebook: String?
        public var telegram: String?

        private enum CodingKeys: String, CodingKey {
            case name = "Name"
            case url = "Url"
            case email = "Email"
            case fecebook = "Fecebook"
            case telegram = "Telegram"
        }
    }

    public struct Company: Codable, Hashable {
        public var name: String?
        public var urlString: String?
        public var email: String?
        public var fecebook: String?
        public var telegram: String?
        public var dribbble: String?
        public var instagram: String?

        public var facebookUrl: URL? {
            URL(string: "https://www.facebook.com/\(String(describing: fecebook))")
        }

        public var url: URL? {
            URL(string: urlString ?? "")
        }

        private enum CodingKeys: String, CodingKey {
            case name = "Name"
            case urlString = "Url"
            case email = "Email"
            case fecebook = "Fecebook"
            case telegram = "Telegram"
            case dribbble = "Dribbble"
            case instagram = "Instagram"
        }
    }
}

public struct App: Codable, Identifiable, Hashable {
    public var id: String?
    public var name: String?
    public var title: String?
    public var subtitle: String?
    public var path: String?
    private enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case title = "Title"
        case subtitle = "Subtitle"
        case path = "Path"
    }
}

public struct Store: Codable {
    public var features: [StoreFeature]

    private enum CodingKeys: String, CodingKey {
        case features = "Features"
    }
}

public struct StoreFeature: Codable, Identifiable, Hashable {
    public var id: String {
        (image ?? "") + (title ?? "") + (subtitle ?? "")
    }

    public let image: String?
    public let title: String?
    public let subtitle: String?
    public let illustrationURL: String?
    public let screenURL: String?
    public let topScreenAlignment: Bool?
    public let backgroundColor: String?
    private enum CodingKeys: String, CodingKey {
        case image, title, subtitle, screenURL, topScreenAlignment, illustrationURL, backgroundColor
    }
}
