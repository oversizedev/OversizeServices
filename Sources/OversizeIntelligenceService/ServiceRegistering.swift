// Copyright © 2026 Alexander Romanov
// ServiceRegistering.swift

import FactoryKit
import Foundation

#if canImport(FoundationModels)
@available(iOS 26.0, macOS 26.0, *)
public extension Container {
    var intelligenceService: Factory<IntelligenceService> {
        self { IntelligenceService() }
    }
}
#endif
