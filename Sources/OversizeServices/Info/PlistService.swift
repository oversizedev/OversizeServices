//
// Copyright © 2022 Alexander Romanov
// PlistService.swift
//

import Foundation

public final class PlistService: Sendable {
    public static let shared: PlistService = .init()
    public init() {}

    public func getStringArrayFromDictionary(field: String, dictionary: String, plist: String) -> [String] {
        guard let filePath = Bundle.main.path(forResource: plist, ofType: "plist") else {
            fatalError("Couldn't find file \(plist).plist'.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let links = plist?.object(forKey: dictionary) as? [String: Any] else {
            fatalError("Couldn't find dictionary '\(dictionary)' in '\(String(describing: plist)).plist'.")
        }
        let value: [String] = links[field] as? [String] ?? []
        return value
    }

    public func getBoolFromDictionary(field: String, dictionary: String, plist: String) -> Bool? {
        guard let filePath = Bundle.main.path(forResource: plist, ofType: "plist") else {
            fatalError("Couldn't find file \(plist).plist'.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let links = plist?.object(forKey: dictionary) as? [String: Any] else {
            fatalError("Couldn't find dictionary '\(dictionary)' in '\(String(describing: plist)).plist'.")
        }
        let value: Bool? = links[field] as? Bool
        return value
    }

    public func getIntFromDictionary(field: String, dictionary: String, plist: String) -> Int? {
        guard let filePath = Bundle.main.path(forResource: plist, ofType: "plist") else {
            fatalError("Couldn't find file \(plist).plist'.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let links = plist?.object(forKey: dictionary) as? [String: Any] else {
            fatalError("Couldn't find dictionary '\(dictionary)' in '\(String(describing: plist)).plist'.")
        }
        let value: Int? = links[field] as? Int
        return value
    }

    public func getStringFromDictionary(field: String, dictionary: String, plist: String) -> String? {
        guard let filePath = Bundle.main.path(forResource: plist, ofType: "plist") else {
            fatalError("Couldn't find file \(plist).plist'.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let links = plist?.object(forKey: dictionary) as? [String: Any] else {
            fatalError("Couldn't find dictionary '\(dictionary)' in '\(String(describing: plist)).plist'.")
        }
        let value: String? = links[field] as? String
        return value
    }

    public func getString(field: String, plist: String) -> String? {
        guard let filePath = Bundle.main.path(forResource: plist, ofType: "plist") else {
            fatalError("Couldn't find file \(plist).plist'.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: field) as? String else {
            fatalError("Couldn't find key '\(field)' in '\(String(describing: plist)).plistt'.")
        }
        return value
    }
}
