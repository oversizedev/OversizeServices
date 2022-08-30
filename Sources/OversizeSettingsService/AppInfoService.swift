//
// Copyright © 2022 Alexander Romanov
// AppInfoService.swift
//

import Foundation
import SwiftUI

// swiftlint:disable all
public enum AppInfoService {
    private static let configName = "AppConfig"
    private static let dictonaryName = "Links"

    public enum app {
        public static var verstion: String? {
            Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        }

        public static var name: String? {
            Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        }

        public static var appStoreID: String? {
            let value = PlistService.shared.getStringFromDictionary(field: "AppStoreID", dictionary: dictonaryName, plist: configName)
            return value
        }

        public static var bundleID: String? {
            Bundle.main.bundleIdentifier
        }

        public static var facebookMessengerChatID: String? {
            let value = PlistService.shared.getStringFromDictionary(field: "AppFacebookMessengerChatID", dictionary: dictonaryName, plist: configName)
            return value
        }

        public static var telegramChatID: String? {
            let value = PlistService.shared.getStringFromDictionary(field: "AppTelegramChatID", dictionary: dictonaryName, plist: configName)
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
            let value = PlistService.shared.getStringFromDictionary(field: "DeveloperUrl", dictionary: dictonaryName, plist: configName)
            return value
        }

        public static var email: String? {
            let value = PlistService.shared.getStringFromDictionary(field: "DeveloperEmail", dictionary: dictonaryName, plist: configName)
            return value
        }

        public static var name: String? {
            let value = PlistService.shared.getStringFromDictionary(field: "DeveloperName", dictionary: dictonaryName, plist: configName)
            return value
        }

        public static var appStoreID: String? {
            let value = PlistService.shared.getStringFromDictionary(field: "DeveloperAppStoreID", dictionary: dictonaryName, plist: configName)
            return value
        }

        public static var telegramAccountID: String? {
            let value = PlistService.shared.getStringFromDictionary(field: "DeveloperTelegramAccountID", dictionary: dictonaryName, plist: configName)
            return value
        }

        public static var facebookAccountID: String? {
            let value = PlistService.shared.getStringFromDictionary(field: "DeveloperFacebookAccountID", dictionary: dictonaryName, plist: configName)
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
            let urlString = PlistService.shared.getStringFromDictionary(field: "AppPrivacyPolicyUrl", dictionary: dictonaryName, plist: configName)
            let url = URL(string: urlString ?? "")
            return url
        }

        public static var appTermsOfUseUrl: URL? {
            let urlString = PlistService.shared.getStringFromDictionary(field: "AppTermsOfUseUrl", dictionary: dictonaryName, plist: configName)
            let url = URL(string: urlString ?? "")
            return url
        }
    }

    public enum storeKit {
        public static var features: [[String: String]] {
            guard let filePath = Bundle.main.path(forResource: configName, ofType: "plist") else {
                fatalError("Couldn't find file \(configName).plist'.")
            }
            let plist = NSDictionary(contentsOfFile: filePath)
            guard let store = plist?.object(forKey: dictonaryName) as? [String: Any] else {
                fatalError("Couldn't find dictionary '\(dictonaryName)' in ")
            }
            let value: [[String: String]] = store["Features"] as? [[String: String]] ?? []
            return value
        }

        public static var bannerLabel: String {
            let value = PlistService.shared.getStringFromDictionary(field: "BannerLabel", dictionary: dictonaryName, plist: configName)
            return value ?? ""
        }

        public static var badgeName: String {
            let value = PlistService.shared.getStringFromDictionary(field: "BadgeName", dictionary: dictonaryName, plist: configName)
            return value ?? ""
        }

        public static var secretKey: String {
            let value = PlistService.shared.getStringFromDictionary(field: "SecretKey", dictionary: dictonaryName, plist: configName)
            return value ?? ""
        }

        public static var productIdentifiers: [String] {
            let value = PlistService.shared.getStringArrayFromDictionary(field: "ProductIdentifiers", dictionary: dictonaryName, plist: configName)
            return value
        }
    }
}
