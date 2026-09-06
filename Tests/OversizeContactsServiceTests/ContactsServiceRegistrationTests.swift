//
// Copyright © 2026 Alexander Romanov
// ContactsServiceRegistrationTests.swift
//

#if !os(tvOS)
import FactoryKit
import FactoryTesting
@testable import OversizeContactsService
import Testing

struct ContactsServiceRegistrationTests {
    @Test(.container)
    func contactsServiceResolvesToProductionType() {
        #expect(Container.shared.contactsService() is ContactsService)
    }

    @Test(.container)
    func contactsServiceUsesUniqueScope() {
        #expect(Container.shared.contactsService() !== Container.shared.contactsService())
    }

    @Test(.container)
    func registeredSubclassReplacesProductionType() {
        Container.shared.contactsService.register { StubContactsService() }

        #expect(Container.shared.contactsService() is StubContactsService)
    }
}

private final class StubContactsService: ContactsService, @unchecked Sendable {}
#endif
