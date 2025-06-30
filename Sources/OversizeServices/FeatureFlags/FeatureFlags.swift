//
// Copyright © 2022 Alexander Romanov
// FeatureFlags.swift
//

import Foundation

// swiftlint:disable line_length type_name

public enum FeatureFlags: Sendable {
    private static let configName = "AppConfig"
    private static let dictionaryName = "FeatureFlags"

    @MainActor
    public enum app: Sendable {
        public static var appearance: Bool? {
            let value = PlistService.shared.getBoolFromDictionary(field: "Apperance", dictionary: dictionaryName, plist: configName)
            return value
        }

        @available(*, deprecated, message: "Use appearance instead")
        public static var apperance: Bool? {
            appearance
        }

        public static var storeKit: Bool? {
            let value = PlistService.shared.getBoolFromDictionary(field: "StoreKit", dictionary: dictionaryName, plist: configName)
            return value
        }

        public static var сloudKit: Bool? {
            let value = PlistService.shared.getBoolFromDictionary(field: "CloudKit", dictionary: dictionaryName, plist: configName)
            return value
        }

        public static var healthKit: Bool? {
            let value = PlistService.shared.getBoolFromDictionary(field: "HealthKit", dictionary: dictionaryName, plist: configName)
            return value
        }

        public static var notifications: Bool? {
            let value = PlistService.shared.getBoolFromDictionary(field: "Notifications", dictionary: dictionaryName, plist: configName)
            return value
        }

        public static var vibration: Bool? {
            let value = PlistService.shared.getBoolFromDictionary(field: "Vibration", dictionary: dictionaryName, plist: configName)
            return value
        }

        public static var sounds: Bool? {
            let value = PlistService.shared.getBoolFromDictionary(field: "Sounds", dictionary: dictionaryName, plist: configName)
            return value
        }

        public static var spotlight: Bool? {
            let value = PlistService.shared.getBoolFromDictionary(field: "Spotlight", dictionary: dictionaryName, plist: configName)
            return value
        }

        public static var alternateAppIcons: Int? {
            let value = PlistService.shared.getIntFromDictionary(field: "AlternateAppIcons", dictionary: dictionaryName, plist: configName)
            return value
        }
    }

    @MainActor
    public enum secure {
        public static var faceID: Bool? {
            let value = PlistService.shared.getBoolFromDictionary(field: "FaceID", dictionary: dictionaryName, plist: configName)
            return value
        }

        public static var lookscreen: Bool? {
            let value = PlistService.shared.getBoolFromDictionary(field: "Lookscreen", dictionary: dictionaryName, plist: configName)
            return value
        }

        public static var CVVCodes: Bool? {
            let value = PlistService.shared.getBoolFromDictionary(field: "CVVCodes", dictionary: dictionaryName, plist: configName)
            return value
        }

        public static var alertSecureCodes: Bool? {
            let value = PlistService.shared.getBoolFromDictionary(field: "AlertPINCode", dictionary: dictionaryName, plist: configName)
            return value
        }

        public static var blurMinimize: Bool? {
            let value = PlistService.shared.getBoolFromDictionary(field: "BlurMinimize", dictionary: dictionaryName, plist: configName)
            return value
        }

        public static var bruteForceSecure: Bool? {
            let value = PlistService.shared.getBoolFromDictionary(field: "BruteForceSecure", dictionary: dictionaryName, plist: configName)
            return value
        }

        public static var photoBreaker: Bool? {
            let value = PlistService.shared.getBoolFromDictionary(field: "PhotoBreaker", dictionary: dictionaryName, plist: configName)
            return value
        }
    }
}
