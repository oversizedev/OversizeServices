//
// Copyright © 2026 Alexander Romanov
// ServiceRegistering.swift, created on 16.03.2026
//

#if canImport(LinkPresentation)
import FactoryKit
import Foundation

@available(macOS 13.0, iOS 16.0, tvOS 18.0, *)
public extension Container {
    var linkMetadataService: Factory<LinkMetadataService> {
        self { LinkMetadataService() }
    }
}
#endif
