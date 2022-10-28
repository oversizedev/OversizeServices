//
// Copyright © 2022 Alexander Romanov
// AssetIcon.swift
//

import CloudKit
import Foundation

public struct AssetIcon: Identifiable {
    public let id = UUID()

    public let name: String
    // public let style: String
    // public let category: String
    public let imageUrl: URL?
}
