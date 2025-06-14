//
// Copyright © 2022 Alexander Romanov
// ServiceRegistering.swift
//

import FactoryKit
import Foundation

#if !os(tvOS)
public extension Container {
    var contactsService: Factory<ContactsService> {
        self { ContactsService() }
    }
}
#endif
