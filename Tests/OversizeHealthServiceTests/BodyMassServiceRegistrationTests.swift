//
// Copyright © 2026 Alexander Romanov
// BodyMassServiceRegistrationTests.swift
//

#if os(iOS) || os(macOS)
import FactoryKit
import FactoryTesting
import Foundation
@testable import OversizeHealthService
import Testing

struct BodyMassServiceRegistrationTests {
    @Test(.container)
    func registeredMockReplacesProductionType() {
        guard #available(iOS 15, macOS 13.0, *) else { return }

        Container.shared.bodyMassService.register { MockBodyMassService() }

        #expect(Container.shared.bodyMassService() is MockBodyMassService)
    }

    @Test(.container)
    func mockIsResolvedThroughProtocol() async {
        guard #available(iOS 15, macOS 13.0, *) else { return }

        let mock = MockBodyMassService()
        Container.shared.bodyMassService.register { mock }

        let result = await Container.shared.bodyMassService().requestAuthorization()

        #expect((try? result.get()) == true)
        #expect(mock.requestAuthorizationCallCount == 1)
    }

    @Test(.container)
    func bloodPressureServiceIsRegistered() {
        guard #available(iOS 15, macOS 13.0, *) else { return }

        #expect(Container.shared.bloodPressureService() !== Container.shared.bloodPressureService())
    }
}
#endif
