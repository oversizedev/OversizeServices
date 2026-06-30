//
// Copyright © 2026 Alexander Romanov
// LinkMetadata.swift, created on 16.03.2026
//

import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public struct LinkMetadata: Identifiable, Sendable {
    public let id: UUID
    public let url: URL
    public let title: String?
    public let host: String?
    public let videoURL: URL?
    public let color: Color?
    #if canImport(UIKit)
    public let image: UIImage?
    public let icon: UIImage?
    #elseif canImport(AppKit)
    public let image: NSImage?
    public let icon: NSImage?
    #endif
}
