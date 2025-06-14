//
// Copyright © 2022 Alexander Romanov
// OversizeServicesTests.swift
//

import FactoryKit
@testable import OversizeServices
import XCTest

final class OversizeServicesTests: XCTestCase {
    override func setUpWithError() throws {
        Container.shared.appStateService.reset()
    }

    func testAppRunCount() throws {
        Container.shared.appStateService.register { AppStateService() }
        let newRunCount = Container.shared.appStateService().appRunCount + 1
        Container.shared.appStateService().appRun()
        XCTAssertEqual(Container.shared.appStateService().appRunCount, newRunCount)
    }
}
