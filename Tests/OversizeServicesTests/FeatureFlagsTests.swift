//
// Copyright © 2026 Alexander Romanov
// FeatureFlagsTests.swift
//

import Foundation
@testable import OversizeServices
import Testing

@MainActor
struct FeatureFlagsTests {
    @Test
    func appFlagsAreNilWithoutConfiguration() {
        #expect(FeatureFlags.app.appearance == nil)
        #expect(FeatureFlags.app.storeKit == nil)
        #expect(FeatureFlags.app.сloudKit == nil)
        #expect(FeatureFlags.app.healthKit == nil)
        #expect(FeatureFlags.app.notifications == nil)
        #expect(FeatureFlags.app.vibration == nil)
        #expect(FeatureFlags.app.sounds == nil)
    }

    @Test
    func secureFlagsAreNilWithoutConfiguration() {
        #expect(FeatureFlags.secure.faceID == nil)
        #expect(FeatureFlags.secure.lookscreen == nil)
        #expect(FeatureFlags.secure.blurMinimize == nil)
    }
}
