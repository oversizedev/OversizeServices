//
// Copyright © 2022 Alexander Romanov
// AppInfo.swift
//

import Foundation
import SwiftUI

// swiftlint:disable all
public enum AppInfo {
    private static let configName = "AppConfig"
    private static let linksDictonaryName = "Links"
    private static let storeDictonaryName = "Store"

    public enum app {
        public static var verstion: String? {
            Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
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

        /*
         public static var iconName: String? {
             return Bundle.main.object(forInfoDictionaryKey: "AppIconName") as? String
         }
          */
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
    }

    public enum store {
        public static var features: [StoreFeature] {
            guard let filePath = Bundle.main.url(forResource: configName, withExtension: "plist") else {
                fatalError("Couldn't find file \(configName).plist'.")
            }
            let data = try! Data(contentsOf: filePath)
            let decoder = PropertyListDecoder()
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
            let decoder = PropertyListDecoder()
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

    public static var plist: PlistConfiguration? {
        let url = Bundle.main.url(forResource: configName, withExtension: "plist")!
        let data = try! Data(contentsOf: url)
        let decoder = PropertyListDecoder()
        return try? decoder.decode(PlistConfiguration.self, from: data)
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

public struct Store: Codable {
    public var features: [StoreFeature]

    private enum CodingKeys: String, CodingKey {
        case features = "Features"
    }
}

public struct PlistConfiguration: Codable {
    public var store: Store?

    private enum CodingKeys: String, CodingKey {
        case store = "Store"
    }
}
