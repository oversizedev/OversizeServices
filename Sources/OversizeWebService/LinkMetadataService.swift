//
// Copyright © 2026 Alexander Romanov
// LinkMetadataService.swift, created on 16.03.2026
//

#if canImport(LinkPresentation)
import LinkPresentation
import OversizeCore
import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

@available(macOS 13.0, iOS 16.0, tvOS 16.0, *)
public actor LinkMetadataService {
    public init() {}

    public func extractMetadata(from url: URL) async -> Result<LinkMetadata, Error> {
        let provider = LPMetadataProvider()
        do {
            let metadata = try await provider.startFetchingMetadata(for: url)
            #if canImport(UIKit)
            let image = await loadImage(from: metadata.imageProvider)
            let icon = await loadImage(from: metadata.iconProvider)
            let color = image.flatMap { $0.averageColor }.map { Color(uiColor: $0) }
            let result = LinkMetadata(
                id: UUID(),
                url: url,
                title: metadata.title,
                host: url.host,
                videoURL: metadata.remoteVideoURL,
                color: color,
                image: image,
                icon: icon,
            )
            #elseif canImport(AppKit)
            let image = await loadImage(from: metadata.imageProvider)
            let icon = await loadImage(from: metadata.iconProvider)
            let color = image.flatMap { $0.averageColor }.map { Color(nsColor: $0) }
            let result = LinkMetadata(
                id: UUID(),
                url: url,
                title: metadata.title,
                host: url.host,
                videoURL: metadata.remoteVideoURL,
                color: color,
                image: image,
                icon: icon,
            )
            #else
            let result = LinkMetadata(
                id: UUID(),
                url: url,
                title: metadata.title,
                host: url.host,
                videoURL: metadata.remoteVideoURL,
                color: nil,
            )
            #endif
            return .success(result)
        } catch {
            return .failure(error)
        }
    }

    public func extractMetadataWithThemeColor(from url: URL) async -> Result<LinkMetadata, Error> {
        let provider = LPMetadataProvider()
        async let themeColor = fetchThemeColor(from: url)
        do {
            let metadata = try await provider.startFetchingMetadata(for: url)
            let resolvedThemeColor = await themeColor
            #if canImport(UIKit)
            let image = await loadImage(from: metadata.imageProvider)
            let icon = await loadImage(from: metadata.iconProvider)
            let averageColor = image.flatMap { $0.averageColor }.map { Color(uiColor: $0) }
            let result = LinkMetadata(
                id: UUID(),
                url: url,
                title: metadata.title,
                host: url.host,
                videoURL: metadata.remoteVideoURL,
                color: resolvedThemeColor ?? averageColor,
                image: image,
                icon: icon,
            )
            #elseif canImport(AppKit)
            let image = await loadImage(from: metadata.imageProvider)
            let icon = await loadImage(from: metadata.iconProvider)
            let averageColor = image.flatMap { $0.averageColor }.map { Color(nsColor: $0) }
            let result = LinkMetadata(
                id: UUID(),
                url: url,
                title: metadata.title,
                host: url.host,
                videoURL: metadata.remoteVideoURL,
                color: resolvedThemeColor ?? averageColor,
                image: image,
                icon: icon,
            )
            #else
            let result = LinkMetadata(
                id: UUID(),
                url: url,
                title: metadata.title,
                host: url.host,
                videoURL: metadata.remoteVideoURL,
                color: resolvedThemeColor,
            )
            #endif
            return .success(result)
        } catch {
            return .failure(error)
        }
    }

    // MARK: - Private

    private func fetchThemeColor(from url: URL) async -> Color? {
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let html = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1)
        else { return nil }
        return parseThemeColor(from: html)
    }

    private func parseThemeColor(from html: String) -> Color? {
        let pattern = #"<meta[^>]+name=["']theme-color["'][^>]+content=["']([^"']+)["']|<meta[^>]+content=["']([^"']+)["'][^>]+name=["']theme-color["']"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html))
        else { return nil }
        let range = match.range(at: 1).location != NSNotFound ? match.range(at: 1) : match.range(at: 2)
        guard let swiftRange = Range(range, in: html) else { return nil }
        return Color(hex: String(html[swiftRange]))
    }

    #if canImport(UIKit)
    private func loadImage(from provider: NSItemProvider?) async -> UIImage? {
        guard let provider else { return nil }
        return await withCheckedContinuation { continuation in
            _ = provider.loadDataRepresentation(for: .image) { data, _ in
                if let data {
                    continuation.resume(returning: UIImage(data: data))
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    #elseif canImport(AppKit)
    private func loadImage(from provider: NSItemProvider?) async -> NSImage? {
        guard let provider else { return nil }
        return await withCheckedContinuation { continuation in
            _ = provider.loadDataRepresentation(for: .image) { data, _ in
                if let data {
                    continuation.resume(returning: NSImage(data: data))
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    #endif
}
#endif
