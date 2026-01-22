//
// Copyright © 2022 Alexander Romanov
// Info.swift
//

import Foundation
import OversizeCore
import SwiftUI
#if os(watchOS)
import WatchKit
#endif

public enum Info: Sendable {
    private static let configName = "AppConfig"

    // MARK: - App

    public enum App: Sendable {
        public static var version: String? {
            Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        }

        public static var build: String? {
            Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        }

        @MainActor
        public static var device: String? {
            #if os(iOS) || os(tvOS) || os(visionOS)
            UIDevice.current.model
            #elseif os(watchOS)
            WKInterfaceDevice.current().model
            #elseif os(macOS)
            Host.current().localizedName
            #else
            nil
            #endif
        }

        @MainActor
        public static var osVersion: String? {
            #if os(iOS) || os(tvOS) || os(visionOS)
            UIDevice.current.systemName + " " + UIDevice.current.systemVersion
            #elseif os(watchOS)
            WKInterfaceDevice.current().systemName + " " + WKInterfaceDevice.current().systemVersion
            #elseif os(macOS)
            let version = ProcessInfo.processInfo.operatingSystemVersion
            return "macOS \(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
            #else
            nil
            #endif
        }

        public static var localeIdentifier: String? {
            Locale.current.identifier
        }

        public static var name: String? {
            Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        }

        public static var appStoreId: String? {
            if let id = Bundle.main.object(forInfoDictionaryKey: "AppStoreId") as? String, !id.isEmpty {
                return id
            }
            guard let id = linksConfiguration?.app?.appStoreId, !id.isEmpty else {
                return nil
            }
            return id
        }

        public static var bundleId: String? {
            Bundle.main.bundleIdentifier
        }

        public static var telegramChatId: String? {
            if let id = Bundle.main.object(forInfoDictionaryKey: "TelegramChatId") as? String, !id.isEmpty {
                return id
            }
            return linksConfiguration?.app?.telegramChat
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
            if let iconName {
                Image(iconName)
            } else {
                nil
            }
        }

        public static var alternateIconNames: [String] {
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

        public static var appStoreUrl: URL? {
            guard let appStoreId else { return nil }
            return URL(string: "https://itunes.apple.com/us/app/apple-store/id\(appStoreId)")
        }

        public static var appStoreReviewUrl: URL? {
            guard let appStoreId else { return nil }
            return URL(string: "itms-apps:itunes.apple.com/us/app/apple-store/id\(appStoreId)&action=write-review")
        }

        public static var websiteUrl: URL? {
            guard let companyUrl = Company.websiteUrl, let appStoreId else { return nil }
            return URL(string: "\(companyUrl.absoluteString)/\(appStoreId)")
        }

        public static var privacyPolicyUrl: URL? {
            guard let websiteUrl else { return nil }
            return URL(string: "\(websiteUrl.absoluteString)/privacy-policy")
        }

        public static var termsOfUseUrl: URL? {
            guard let websiteUrl else { return nil }
            return URL(string: "\(websiteUrl.absoluteString)/terms-and-conditions")
        }

        public static var telegramChatUrl: URL? {
            guard let telegramChatId else { return nil }
            return URL(string: "https://t.me/\(telegramChatId)")
        }
    }

    // MARK: - Developer

    public enum Developer: Sendable {
        private static var developerDict: [String: Any]? {
            Bundle.main.infoDictionary?["Developer"] as? [String: Any]
        }

        public static var websiteUrl: URL? {
            let urlString = developerDict?["WebsiteUrl"] as? String ?? linksConfiguration?.developer.url
            guard let urlString else { return nil }
            return URL(string: urlString.hasPrefix("http") ? urlString : "https://\(urlString)")
        }

        public static var email: String? {
            developerDict?["Email"] as? String ?? linksConfiguration?.developer.email
        }

        public static var name: String? {
            developerDict?["Name"] as? String ?? linksConfiguration?.developer.name
        }

        public static var emailUrl: URL? {
            guard let email else { return nil }
            return URL(string: "mailto:\(email)")
        }

        public static var appsUrl: URL? {
            guard let appStoreId = Company.appStoreId else { return nil }
            return URL(string: "itms-apps://itunes.apple.com/developer/id\(appStoreId)")
        }
    }

    // MARK: - Company

    public enum Company: Sendable {
        private static var companyDict: [String: Any]? {
            Bundle.main.infoDictionary?["Company"] as? [String: Any]
        }

        public static var websiteUrl: URL? {
            if let urlString = companyDict?["WebsiteUrl"] as? String {
                return URL(string: urlString)
            }
            return linksConfiguration?.company.url
        }

        public static var appStoreId: String? {
            companyDict?["AppStoreId"] as? String ?? linksConfiguration?.company.appStoreId
        }

        public static var twitterUsername: String? {
            companyDict?["Twitter"] as? String ?? linksConfiguration?.company.twitter
        }

        public static var dribbbleUsername: String? {
            companyDict?["Dribbble"] as? String ?? linksConfiguration?.company.dribbble
        }

        public static var instagramUsername: String? {
            companyDict?["Instagram"] as? String ?? linksConfiguration?.company.instagram
        }

        public static var facebookUsername: String? {
            companyDict?["Facebook"] as? String ?? linksConfiguration?.company.facebook
        }

        public static var telegramUsername: String? {
            companyDict?["Telegram"] as? String ?? linksConfiguration?.company.telegram
        }

        public static var cdnUrl: URL? {
            if let cdnString = companyDict?["CdnUrl"] as? String {
                return URL(string: cdnString)
            }
            guard let cdnString = linksConfiguration?.company.cdnString else { return nil }
            return URL(string: cdnString)
        }

        public static var emailUrl: URL? {
            let email = companyDict?["Email"] as? String ?? linksConfiguration?.company.email
            guard let email else { return nil }
            return URL(string: "mailto:\(email)")
        }

        public static var telegramUrl: URL? {
            guard let telegramUsername else { return nil }
            return URL(string: "https://t.me/\(telegramUsername)")
        }

        public static var facebookUrl: URL? {
            guard let facebookUsername else { return nil }
            return URL(string: "https://facebook.com/\(facebookUsername)")
        }

        public static var twitterUrl: URL? {
            guard let twitterUsername else { return nil }
            return URL(string: "https://twitter.com/\(twitterUsername)")
        }

        public static var dribbbleUrl: URL? {
            guard let dribbbleUsername else { return nil }
            return URL(string: "https://dribbble.com/\(dribbbleUsername)")
        }

        public static var instagramUrl: URL? {
            guard let instagramUsername else { return nil }
            return URL(string: "https://instagram.com/\(instagramUsername)")
        }
    }

    // MARK: - Private

    private static var linksConfiguration: Links? {
        let info = Bundle.main.infoDictionary

        if let developerDict = info?["Developer"] as? [String: Any],
           let companyDict = info?["Company"] as? [String: Any]
        {
            let linksDict: [String: Any] = [
                "Developer": developerDict,
                "Company": companyDict,
            ]
            if let data = try? JSONSerialization.data(withJSONObject: linksDict) {
                return try? JSONDecoder().decode(Links.self, from: data)
            }
        }

        if let linksDict = info?["Links"] as? [String: Any],
           let data = try? JSONSerialization.data(withJSONObject: linksDict)
        {
            return try? JSONDecoder().decode(Links.self, from: data)
        }

        if let configDict = info?["AppConfig"] as? [String: Any],
           let data = try? JSONSerialization.data(withJSONObject: configDict),
           let config = try? JSONDecoder().decode(PlistConfiguration.self, from: data)
        {
            return config.links
        }

        guard let url = Bundle.main.url(forResource: configName, withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let config = try? PropertyListDecoder().decode(PlistConfiguration.self, from: data)
        else {
            return nil
        }
        return config.links
    }
}
