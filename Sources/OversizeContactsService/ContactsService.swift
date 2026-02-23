//
// Copyright © 2022 Alexander Romanov
// ContactsService.swift
//

#if canImport(Contacts)
import Contacts
#endif
import Foundation
import OversizeCore

#if canImport(Contacts)
public class ContactsService: @unchecked Sendable {
    private let contactStore: CNContactStore = .init()
    public init() {}

    public func requestAccess() async -> Result<Bool, Error> {
        do {
            let status = try await contactStore.requestAccess(for: .contacts)
            if status {
                return .success(true)
            } else {
                return .failure(ContactsError.notAccess)
            }
        } catch {
            return .failure(ContactsError.notAccess)
        }
    }

    public func fetchContacts(
        keysToFetch: [CNKeyDescriptor] = [CNContactVCardSerialization.descriptorForRequiredKeys()],
        order: CNContactSortOrder = .none,
        unifyResults: Bool = true,
    ) async -> Result<[CNContact], Error> {
        var contacts: [CNContact] = []
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
        fetchRequest.unifyResults = unifyResults
        fetchRequest.sortOrder = order
        do {
            try contactStore.enumerateContacts(with: fetchRequest) { contact, _ in
                contacts.append(contact)
            }
            return .success(contacts)
        } catch {
            return .failure(ContactsError.unknown(error))
        }
    }
}
#endif
