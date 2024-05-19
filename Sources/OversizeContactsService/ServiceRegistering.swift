//
// Copyright © 2022 Alexander Romanov
// ServiceRegistering.swift
//

import Factory
import Foundation

#if os(iOS) || os(macOS)
    public extension Container {
        var contactsService: Factory<ContactsService> {
            self { ContactsService() }
        }
    }
#endif
