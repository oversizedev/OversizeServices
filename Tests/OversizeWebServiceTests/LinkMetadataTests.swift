//
// Copyright © 2026 Alexander Romanov
// LinkMetadataTests.swift
//

#if canImport(LinkPresentation)
import FactoryKit
import FactoryTesting
import Foundation
@testable import OversizeWebService
import Testing

struct LinkMetadataTests {
    @Test
    func storesProvidedValues() throws {
        guard #available(macOS 13.0, iOS 16.0, tvOS 18.0, *) else { return }

        let id = UUID()
        let url = try #require(URL(string: "https://example.com/article"))
        let videoURL = try #require(URL(string: "https://example.com/video.mp4"))

        let metadata = LinkMetadata(
            id: id,
            url: url,
            title: "Article",
            host: url.host,
            videoURL: videoURL,
            color: nil,
            image: nil,
            icon: nil,
        )

        #expect(metadata.id == id)
        #expect(metadata.url == url)
        #expect(metadata.title == "Article")
        #expect(metadata.host == "example.com")
        #expect(metadata.videoURL == videoURL)
    }

    @Test(.container)
    func linkMetadataServiceUsesUniqueScope() {
        guard #available(macOS 13.0, iOS 16.0, tvOS 18.0, *) else { return }

        #expect(Container.shared.linkMetadataService() !== Container.shared.linkMetadataService())
    }
}
#endif
