//
// Copyright © 2026 Alexander Romanov
// ContainerRegistrationTests.swift
//

import FactoryKit
import FactoryTesting
import Foundation
@testable import OversizeServices
import Testing

struct ContainerRegistrationTests {
    @Test(.container)
    func defaultRegistrationsResolveToProductionTypes() {
        #expect(Container.shared.settingsService() is SettingsService)
        #expect(Container.shared.biometricService() is BiometricService)
        _ = Container.shared.appStateService()
        _ = Container.shared.secureStorageService()
    }

    @Test(.container)
    func defaultScopeIsUnique() {
        let first = Container.shared.appStateService()
        let second = Container.shared.appStateService()

        #expect(first !== second)
    }

    @Test(.container)
    func registeredMockReplacesProductionType() {
        Container.shared.settingsService.register { MockSettingsService() }

        #expect(Container.shared.settingsService() is MockSettingsService)
    }

    @Test(.container)
    func resetRestoresOriginalRegistration() {
        Container.shared.settingsService.register { MockSettingsService() }
        #expect(Container.shared.settingsService() is MockSettingsService)

        Container.shared.settingsService.reset()

        #expect(Container.shared.settingsService() is SettingsService)
    }

    @Test(.container)
    func pushAndPopRestoreRegistrations() {
        Container.shared.manager.push()
        Container.shared.settingsService.register { MockSettingsService() }
        #expect(Container.shared.settingsService() is MockSettingsService)

        Container.shared.manager.pop()

        #expect(Container.shared.settingsService() is SettingsService)
    }

    @Test(.container)
    func contextRegistrationIsUsedWhileTesting() {
        Container.shared.settingsService.onTest { MockSettingsService() }

        #expect(Container.shared.settingsService() is MockSettingsService)
    }

    @Test(.container)
    func containerTraitIsolatesRegistrationsFromOtherTests() {
        Container.shared.biometricService.register { MockBiometricService() }

        #expect(Container.shared.biometricService() is MockBiometricService)
    }

    @Test(.container)
    func injectedPropertyResolvesRegisteredMock() {
        Container.shared.biometricService.register { MockBiometricService(biometricType: .touchID) }

        let consumer = BiometricConsumer()

        #expect(consumer.biometricService.biometricType == .touchID)
    }
}

private struct BiometricConsumer {
    @Injected(\.biometricService) var biometricService
}
