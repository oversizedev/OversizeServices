//
// Copyright © 2026 Alexander Romanov
// LocationServiceRegistrationTests.swift
//

import FactoryKit
import FactoryTesting
@testable import OversizeLocationService
import Testing

struct LocationServiceRegistrationTests {
    @Test(.container)
    func locationServiceResolvesToProductionType() {
        #expect(Container.shared.locationService() is LocationService)
    }

    @Test(.container)
    func registeredMockReplacesLocationService() {
        Container.shared.locationService.register { MockLocationService() }

        #expect(Container.shared.locationService() is MockLocationService)
    }
}
