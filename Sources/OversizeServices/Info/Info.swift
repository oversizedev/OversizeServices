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
            guard let id = configuration?.links.app.appStoreId, !id.isEmpty else {
                return nil
            }
            return id
        }

        public static var bundleId: String? {
            Bundle.main.bundleIdentifier
        }

        public static var telegramChatId: String? {
            configuration?.links.app.telegramChat
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
            guard let companyUrl = Company.url, let appStoreId else { return nil }
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
        public static var website: String? {
            configuration?.links.developer.url
        }

        public static var email: String? {
            configuration?.links.developer.email
        }

        public static var name: String? {
            configuration?.links.developer.name
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
        public static var url: URL? {
            configuration?.links.company.url
        }

        public static var appStoreId: String? {
            configuration?.links.company.appStoreId
        }

        public static var twitterUsername: String? {
            configuration?.links.company.twitter
        }

        public static var dribbbleUsername: String? {
            configuration?.links.company.dribbble
        }

        public static var instagramUsername: String? {
            configuration?.links.company.instagram
        }

        public static var facebookUsername: String? {
            configuration?.links.company.facebook
        }

        public static var telegramUsername: String? {
            configuration?.links.company.telegram
        }

        public static var cdnUrl: URL? {
            guard let cdnString = configuration?.links.company.cdnString else { return nil }
            return URL(string: cdnString)
        }

        public static var emailUrl: URL? {
            guard let email = configuration?.links.company.email else { return nil }
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

    private static var configuration: PlistConfiguration? {
        guard let url = Bundle.main.url(forResource: configName, withExtension: "plist"),
              let data = try? Data(contentsOf: url)
        else {
            return nil
        }
        return try? PropertyListDecoder().decode(PlistConfiguration.self, from: data)
    }
}

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
    static var appStoreID: String? { appStoreId }

    @available(*, deprecated, renamed: "bundleId")
    static var bundleID: String? { bundleId }

    @available(*, deprecated, renamed: "telegramChatId")
    static var telegramChatID: String? { telegramChatId }

    @available(*, deprecated, renamed: "alternateIconNames")
    static var alternateIconsNames: [String] { alternateIconNames }

    @available(*, deprecated, renamed: "osVersion")
    @MainActor static var system: String? { osVersion }

    @available(*, deprecated, renamed: "localeIdentifier")
    static var language: String? { localeIdentifier }

    @available(*, deprecated, renamed: "appStoreUrl")
    static var appStoreURL: URL? { appStoreUrl }

    @available(*, deprecated, renamed: "appStoreReviewUrl")
    static var appStoreReviewURL: URL? { appStoreReviewUrl }

    @available(*, deprecated, renamed: "websiteUrl")
    static var websiteURL: URL? { websiteUrl }

    @available(*, deprecated, renamed: "privacyPolicyUrl")
    static var privacyPolicyURL: URL? { privacyPolicyUrl }

    @available(*, deprecated, renamed: "termsOfUseUrl")
    static var termsOfUseURL: URL? { termsOfUseUrl }

    @available(*, deprecated, renamed: "telegramChatUrl")
    static var telegramChatURL: URL? { telegramChatUrl }
 }

 public extension Info.Developer {
    @available(*, deprecated, renamed: "website")
    static var url: String? { website }

    @available(*, deprecated, renamed: "emailUrl")
    static var emailURL: URL? { emailUrl }

    @available(*, deprecated, renamed: "appsUrl")
    static var appsURL: URL? { appsUrl }
 }

 public extension Info.Company {
    @available(*, deprecated, renamed: "appStoreId")
    static var appStoreID: String? { appStoreId }

    @available(*, deprecated, renamed: "twitterUsername")
    static var twitterID: String? { twitterUsername }

    @available(*, deprecated, renamed: "dribbbleUsername")
    static var dribbbleID: String? { dribbbleUsername }

    @available(*, deprecated, renamed: "instagramUsername")
    static var instagramID: String? { instagramUsername }

    @available(*, deprecated, renamed: "facebookUsername")
    static var facebookID: String? { facebookUsername }

    @available(*, deprecated, renamed: "telegramUsername")
    static var telegramID: String? { telegramUsername }

    @available(*, deprecated, renamed: "cdnUrl")
    static var cdnURL: URL? { cdnUrl }

    @available(*, deprecated, renamed: "emailUrl")
    static var emailURL: URL? { emailUrl }

    @available(*, deprecated, renamed: "telegramUrl")
    static var telegramURL: URL? { telegramUrl }

    @available(*, deprecated, renamed: "facebookUrl")
    static var facebookURL: URL? { facebookUrl }

    @available(*, deprecated, renamed: "twitterUrl")
    static var twitterURL: URL? { twitterUrl }

    @available(*, deprecated, renamed: "dribbbleUrl")
    static var dribbbleURL: URL? { dribbbleUrl }

    @available(*, deprecated, renamed: "instagramUrl")
    static var instagramURL: URL? { instagramUrl }
 }

// MARK: - Deprecated URLs Enum

 @available(*, deprecated, message: "Use Info.App, Info.Developer, Info.Company instead")
 public extension Info {
    enum URLs: Sendable {
        @available(*, deprecated, renamed: "Info.App.appStoreReviewUrl")
        public static var appStoreReview: URL? { App.appStoreReviewUrl }

        @available(*, deprecated, renamed: "Info.App.appStoreUrl")
        public static var appStore: URL? { App.appStoreUrl }

        @available(*, deprecated, renamed: "Info.Developer.emailUrl")
        public static var developerEmail: URL? { Developer.emailUrl }

        @available(*, deprecated, renamed: "Info.Developer.appsUrl")
        public static var developerApps: URL? { Developer.appsUrl }

        @available(*, deprecated, renamed: "Info.App.telegramChatUrl")
        public static var telegramChat: URL? { App.telegramChatUrl }

        @available(*, deprecated, renamed: "Info.App.websiteUrl")
        public static var app: URL? { App.websiteUrl }

        @available(*, deprecated, renamed: "Info.App.privacyPolicyUrl")
        public static var privacyPolicy: URL? { App.privacyPolicyUrl }

        @available(*, deprecated, renamed: "Info.App.termsOfUseUrl")
        public static var termsOfUse: URL? { App.termsOfUseUrl }

        @available(*, deprecated, renamed: "Info.Company.cdnUrl")
        public static var companyCDN: URL? { Company.cdnUrl }

        @available(*, deprecated, renamed: "Info.Company.emailUrl")
        public static var companyEmail: URL? { Company.emailUrl }

        @available(*, deprecated, renamed: "Info.Company.telegramUrl")
        public static var companyTelegram: URL? { Company.telegramUrl }

        @available(*, deprecated, renamed: "Info.Company.facebookUrl")
        public static var companyFacebook: URL? { Company.facebookUrl }

        @available(*, deprecated, renamed: "Info.Company.twitterUrl")
        public static var companyTwitter: URL? { Company.twitterUrl }

        @available(*, deprecated, renamed: "Info.Company.dribbbleUrl")
        public static var companyDribbble: URL? { Company.dribbbleUrl }

        @available(*, deprecated, renamed: "Info.Company.instagramUrl")
        public static var companyInstagram: URL? { Company.instagramUrl }

        @available(*, deprecated, renamed: "Info.App.appStoreUrl")
        public static var appInstallShare: URL? { App.appStoreUrl }

        @available(*, deprecated, renamed: "Info.Developer.emailUrl")
        public static var developerSendMail: URL? { Developer.emailUrl }

        @available(*, deprecated, renamed: "Info.Developer.appsUrl")
        public static var developerAllApps: URL? { Developer.appsUrl }

        @available(*, deprecated, renamed: "Info.App.telegramChatUrl")
        public static var appTelegramChat: URL? { App.telegramChatUrl }

        @available(*, deprecated, renamed: "Info.App.websiteUrl")
        public static var appUrl: URL? { App.websiteUrl }

        @available(*, deprecated, renamed: "Info.App.privacyPolicyUrl")
        public static var appPrivacyPolicyUrl: URL? { App.privacyPolicyUrl }

        @available(*, deprecated, renamed: "Info.App.termsOfUseUrl")
        public static var appTermsOfUseUrl: URL? { App.termsOfUseUrl }

        @available(*, deprecated, renamed: "Info.Company.cdnUrl")
        public static var companyCdnUrl: URL? { Company.cdnUrl }
    }
 }
