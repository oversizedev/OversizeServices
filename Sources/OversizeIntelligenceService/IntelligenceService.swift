// Copyright © 2026 Alexander Romanov
// IntelligenceService.swift

import Foundation
import OversizeCore

#if canImport(FoundationModels)
import FoundationModels
#endif

// MARK: - IntelligenceService

@available(iOS 26.0, macOS 26.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public actor IntelligenceService {
    #if canImport(FoundationModels)
    private var session: LanguageModelSession
    private let systemInstructions: String
    #endif

    public init(instructions: String = "") {
        #if canImport(FoundationModels)
        systemInstructions = instructions
        session = LanguageModelSession(instructions: instructions)
        #endif
    }

    public nonisolated func isAvailable() -> Bool {
        #if canImport(FoundationModels)
        return SystemLanguageModel.default.isAvailable
        #else
        return false
        #endif
    }

    public func reset() {
        #if canImport(FoundationModels)
        session = LanguageModelSession(instructions: systemInstructions)
        #endif
    }

    public func respond(to input: String) async throws -> String {
        #if canImport(FoundationModels)
        guard SystemLanguageModel.default.isAvailable else {
            throw IntelligenceError.modelNotAvailable
        }
        let response = try await session.respond(to: input)
        return response.content
        #else
        throw IntelligenceError.unsupportedPlatform
        #endif
    }

    public func generate(_ input: String) async throws -> String {
        #if canImport(FoundationModels)
        guard SystemLanguageModel.default.isAvailable else {
            throw IntelligenceError.modelNotAvailable
        }
        let freshSession = LanguageModelSession(instructions: systemInstructions)
        let response = try await freshSession.respond(to: input)
        return response.content
        #else
        throw IntelligenceError.unsupportedPlatform
        #endif
    }
}
