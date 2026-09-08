//
// Copyright © 2022 Alexander Romanov
// FeatureFlags.swift
//

import Foundation

public enum FeatureFlags: Sendable {
    private static var featureFlagsDict: [String: Any]? {
        Bundle.main.infoDictionary?["FeatureFlags"] as? [String: Any]
    }

    @MainActor
    private static func getBool(_ key: String) -> Bool? {
        getBool(anyOf: [key])
    }

    @MainActor
    private static func getBool(anyOf keys: [String]) -> Bool? {
        for key in keys {
            if let value = featureFlagsDict?[key] as? Bool {
                return value
            }
        }
        for key in keys {
            if let value = PlistService.shared.getBoolFromDictionary(
                field: key,
                dictionary: "FeatureFlags",
                plist: "AppConfig",
            ) {
                return value
            }
        }
        return nil
    }

    @MainActor
    public enum app: Sendable {
        public static var appearance: Bool? {
            getBool(anyOf: ["Appearance", "Apperance"])
        }

        public static var storeKit: Bool? {
            getBool("StoreKit")
        }

        public static var сloudKit: Bool? {
            getBool("CloudKit")
        }

        public static var healthKit: Bool? {
            getBool("HealthKit")
        }

        public static var notifications: Bool? {
            getBool("Notifications")
        }

        public static var vibration: Bool? {
            getBool("Vibration")
        }

        public static var sounds: Bool? {
            getBool("Sounds")
        }
    }

    @MainActor
    public enum secure {
        public static var faceID: Bool? {
            getBool("FaceID")
        }

        public static var lookscreen: Bool? {
            getBool("Lookscreen")
        }

        public static var blurMinimize: Bool? {
            getBool("BlurMinimize")
        }
    }
}
