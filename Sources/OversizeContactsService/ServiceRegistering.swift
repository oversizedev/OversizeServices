//
// Copyright © 2022 Alexander Romanov
// ServiceRegistering.swift
//

import Factory
import Foundation

public extension Container {
    var contactsService: Factory<ContactsService> {
        self { ContactsService() }
    }
}
