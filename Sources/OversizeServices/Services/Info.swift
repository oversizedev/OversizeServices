//
// Copyright © 2022 Alexander Romanov
// Info.swift
//

import Foundation
import SwiftUI
import UIKit

// swiftlint:disable all
public enum Info {
    private static let configName = "AppConfig"
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
            links?.app.appStoreId
        }

        public static var bundleID: String? {
            Bundle.main.bundleIdentifier
        }

        public static var telegramChatID: String? {
            links?.app.telegramChat
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
            links?.developer.url
        }

        public static var email: String? {
            links?.developer.email
        }

        public static var name: String? {
            links?.developer.name
        }
    }

    public enum company {
        public static var url: URL? {
            links?.company.url
        }

        public static var appStoreID: String? {
            links?.company.appStoreId
        }

        public static var twitterID: String? {
            links?.company.twitter
        }

        public static var dribbbleID: String? {
            links?.company.dribbble
        }

        public static var tnstagramID: String? {
            links?.company.instagram
        }

        public static var facebookID: String? {
            links?.company.facebook
        }

        public static var telegramID: String? {
            links?.company.telegram
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
            guard company.appStoreID != nil else { return nil }
            let url = URL(string: "itms-apps://itunes.apple.com/developer/id\(company.appStoreID!)")
            return url
        }

        public static var appTelegramChat: URL? {
            guard app.telegramChatID != nil else { return nil }
            let url = URL(string: "https://t.me/\(app.telegramChatID!)")
            return url
        }

        public static var appPrivacyPolicyUrl: URL? {
            let url = URL(string: "\(Info.links?.company.urlString ?? "")/\(links?.app.urlString ?? ""))/privacy-policy")
            return url
        }

        public static var appTermsOfUseUrl: URL? {
            let url = URL(string: "\(Info.links?.company.urlString ?? "")/\(links?.app.urlString ?? ""))/terms-and-conditions")
            return url
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
            guard let id = company.tnstagramID else { return nil }
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
            return decodeData.links
        } catch {
            return nil
        }
    }

    public enum store {
        public static var features: [Store.StoreFeature] {
            guard let filePath = Bundle.main.url(forResource: configName, withExtension: "plist") else {
                fatalError("Couldn't find file \(configName).plist'.")
            }
            let data = try! Data(contentsOf: filePath)
            let decoder: PropertyListDecoder = .init()
            do {
                let decodeData = try decoder.decode(PlistConfiguration.self, from: data)
                return decodeData.store.features
            } catch {
                return []
            }
        }

        public static func parseConfig() -> PlistConfiguration {
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
