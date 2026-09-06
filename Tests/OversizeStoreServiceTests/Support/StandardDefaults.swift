//
// Copyright © 2026 Alexander Romanov
// StandardDefaults.swift
//

import Foundation

enum StandardDefaults {
    static func remove(keys: [String]) {
        let defaults = UserDefaults.standard
        for key in keys {
            defaults.removeObject(forKey: key)
        }
    }
}
