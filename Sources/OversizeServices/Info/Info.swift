//
// Copyright © 2022 Alexander Romanov
// Info.swift
//

import Foundation
import SwiftUI

// swiftlint:disable all

public enum Info: Sendable {
    private static let configName = "AppConfig"
    private static let storeDictionaryName = "Store"

    public enum app: Sendable {
        public static var version: String? {
            Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        }

        public static var build: String? {
            Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        }

        @MainActor
        public static var device: String? {
            #if os(iOS)
            return UIDevice.current.model
            #else
            return nil
            #endif
        }

        @MainActor
        public static var system: String? {
            #if os(iOS)
            return UIDevice.current.systemName + " " + UIDevice.current.systemVersion
            #elseif os(macOS)
            let osVersion = ProcessInfo.processInfo.operatingSystemVersion
            return "macOS \(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
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
            guard let id = all?.links.app.appStoreId else {
                print("[Info] Warning: appStoreId is not set in AppConfig.plist")
                return nil
            }
            return id
        }

        public static var appStoreIDInt: Int? {
            guard let appStoreID = all?.links.app.appStoreId else { return nil }
            return Int(appStoreID)
        }

        public static var bundleID: String? {
            Bundle.main.bundleIdentifier
        }

        public static var telegramChatID: String? {
            all?.links.app.telegramChat
        }

        public static var iconName: String? {
            guard let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
                  let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
                  let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
                  let iconFileName = iconFiles.last
            else { return nil }
            return iconFileName
        }

        public static var icon: Image? {
            if let iconName, let uiImage = UIImage(named: iconName) {
                Image(uiImage: uiImage)
            } else {
                nil
            }
        }

        public static var alternateIconsNames: [String] {
            guard let icons = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],
                  let alternateIcons = icons["CFBundleAlternateIcons"] as? [String: Any]
            else {
                return []
            }
            return Array(alternateIcons.keys).sorted()
        }

        @MainActor
        public static var alternateIconName: String? {
            #if os(iOS)
            UIApplication.shared.alternateIconName
            #else
            nil
            #endif
        }
    }

    public enum developer: Sendable {
        public static var url: String? {
            all?.links.developer.url
        }

        public static var email: String? {
            all?.links.developer.email
        }

        public static var name: String? {
            all?.links.developer.name
        }
    }

    public enum company: Sendable {
        public static var url: URL? {
            all?.links.company.url
        }

        public static var appStoreID: String? {
            all?.links.company.appStoreId
        }

        public static var twitterID: String? {
            all?.links.company.twitter
        }

        public static var dribbbleID: String? {
            all?.links.company.dribbble
        }

        public static var instagramID: String? {
            all?.links.company.instagram
        }

        public static var facebookID: String? {
            all?.links.company.facebook
        }

        public static var telegramID: String? {
            all?.links.company.telegram
        }
    }

    public enum url: Sendable {
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
            guard company.appStoreID != nil else { return nil }
            let url = URL(string: "itms-apps://itunes.apple.com/developer/id\(company.appStoreID!)")
            return url
        }

        public static var appTelegramChat: URL? {
            guard app.telegramChatID != nil else { return nil }
            let url = URL(string: "https://t.me/\(app.telegramChatID!)")
            return url
        }

        public static var appUrl: URL? {
            guard let companyUrl = company.url,
                  let appStoreId = app.appStoreID
            else { return nil }
            return URL(string: "\(companyUrl.absoluteString)/\(appStoreId)")
        }

        public static var appPrivacyPolicyUrl: URL? {
            guard let appUrl else { return nil }
            return URL(string: "\(appUrl.absoluteString)/privacy-policy")
        }

        public static var appTermsOfUseUrl: URL? {
            guard let appUrl else { return nil }
            return URL(string: "\(appUrl.absoluteString)/terms-and-conditions")
        }

        public static var companyCdnUrl: URL? {
            guard let cdnString = all?.links.company.cdnString else { return nil }
            return URL(string: cdnString)
        }

        public static var companyEmail: URL? {
            guard let email = all?.links.company.email else { return nil }
            return URL(string: "mailto:\(email)")
        }

        public static var companyTelegram: URL? {
            guard let id = company.telegramID else { return nil }
            guard let url = URL(string: "https://www.t.me/\(id)") else { return nil }
            return url
        }

        public static var companyFacebook: URL? {
            guard let id = company.facebookID else { return nil }
            guard let url = URL(string: "https://www.facebook.com/\(id)") else { return nil }
            return url
        }

        public static var companyTwitter: URL? {
            guard let id = company.twitterID else { return nil }
            guard let url = URL(string: "https://www.twitter.com/\(id)") else { return nil }
            return url
        }

        public static var companyDribbble: URL? {
            guard let id = company.dribbbleID else { return nil }
            guard let url = URL(string: "https://www.dribbble.com/\(id)") else { return nil }
            return url
        }

        public static var companyInstagram: URL? {
            guard let id = company.instagramID else { return nil }
            guard let url = URL(string: "https://www.instagram.com/\(id)") else { return nil }
            return url
        }
    }

    private static var all: PlistConfiguration? {
        guard let url = Bundle.main.url(forResource: configName, withExtension: "plist"),
              let data = try? Data(contentsOf: url)
        else { return nil }
        return try? PropertyListDecoder().decode(PlistConfiguration.self, from: data)
    }
}
