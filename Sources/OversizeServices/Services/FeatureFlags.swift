//
// Copyright © 2022 Alexander Romanov
// FeatureFlags.swift
//

import Foundation

// swiftlint:disable line_length type_name
public enum FeatureFlags /*: ObservableObject */ {
    private static let configName = "AppConfig"
    private static let dictonaryName = "FeatureFlags"

    public enum app {
        public static var apperance: Bool? {
            let value = PlistService.shared.getBoolFromDictionary(field: "Apperance", dictionary: dictonaryName, plist: configName)
            return value
        }

        public static var storeKit: Bool? {
            let value = PlistService.shared.getBoolFromDictionary(field: "StoreKit", dictionary: dictonaryName, plist: configName)
            return value
        }

        public static var сloudKit: Bool? {
            let value = PlistService.shared.getBoolFromDictionary(field: "CloudKit", dictionary: dictonaryName, plist: configName)
            return value
        }
        
        public static var healthKit: Bool? {
            let value = PlistService.shared.getBoolFromDictionary(field: "HealthKit", dictionary: dictonaryName, plist: configName)
            return value
        }

        public static var notifications: Bool? {
            let value = PlistService.shared.getBoolFromDictionary(field: "Notifications", dictionary: dictonaryName, plist: configName)
            return value
        }

        public static var vibration: Bool? {
            let value = PlistService.shared.getBoolFromDictionary(field: "Vibration", dictionary: dictonaryName, plist: configName)
            return value
        }

        public static var sounds: Bool? {
            let value = PlistService.shared.getBoolFromDictionary(field: "Sounds", dictionary: dictonaryName, plist: configName)
            return value
        }

        public static var spotlight: Bool? {
            let value = PlistService.shared.getBoolFromDictionary(field: "Spotlight", dictionary: dictonaryName, plist: configName)
            return value
        }
    }

    public enum secure {
        public static var faceID: Bool? {
            let value = PlistService.shared.getBoolFromDictionary(field: "FaceID", dictionary: dictonaryName, plist: configName)
            return value
        }

        public static var lookscreen: Bool? {
            let value = PlistService.shared.getBoolFromDictionary(field: "Lookscreen", dictionary: dictonaryName, plist: configName)
            return value
        }

        public static var CVVCodes: Bool? {
            let value = PlistService.shared.getBoolFromDictionary(field: "CVVCodes", dictionary: dictonaryName, plist: configName)
            return value
        }

        public static var alertSecureCodes: Bool? {
            let value = PlistService.shared.getBoolFromDictionary(field: "AlertPINCode", dictionary: dictonaryName, plist: configName)
            return value
        }

        public static var blurMinimize: Bool? {
            let value = PlistService.shared.getBoolFromDictionary(field: "BlurMinimize", dictionary: dictonaryName, plist: configName)
            return value
        }

        public static var bruteForceSecure: Bool? {
            let value = PlistService.shared.getBoolFromDictionary(field: "BruteForceSecure", dictionary: dictonaryName, plist: configName)
            return value
        }

        public static var photoBreaker: Bool? {
            let value = PlistService.shared.getBoolFromDictionary(field: "PhotoBreaker", dictionary: dictonaryName, plist: configName)
            return value
        }
    }
}
