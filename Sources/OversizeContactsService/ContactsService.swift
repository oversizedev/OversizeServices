//
// Copyright © 2022 Alexander Romanov
// ContactsService.swift
//

import Contacts
import Foundation
import OversizeServices

public class ContactsService {
    private let contactStore: CNContactStore = .init()
    public init() {}

    public func requestAccess() async -> Result<Bool, AppError> {
        do {
            try await contactStore.requestAccess(for: .contacts)
            return .success(true)
        } catch {
            return .failure(AppError.custom(title: "Not Access"))
        }
    }

    public func fetchContacts(keysToFetch: [CNKeyDescriptor] = [CNContactVCardSerialization.descriptorForRequiredKeys()], order: CNContactSortOrder = .none, unifyResults: Bool = true) async throws -> Result<[CNContact], AppError> {
        try await withCheckedThrowingContinuation { continuation in
            do {
                var contacts: [CNContact] = []
                let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
                fetchRequest.unifyResults = unifyResults
                fetchRequest.sortOrder = order
                try contactStore.enumerateContacts(with: fetchRequest) { contact, _ in
                    contacts.append(contact)
                }
                continuation.resume(returning: .success(contacts))
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

//    let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey]
//                    let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
//                    do {
//                        try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
//
//                     //       DispatchQueue.main.async {
//                                self.contacts.append(Contact(firstName: contact.givenName, lastName: contact.familyName, phoneNumbers: contact.phoneNumbers.map { $0.value.stringValue }, emailAddresses: contact.emailAddresses.map { $0.value as String }
//                                ))
//
//                                self.contacts.sort(by: { $0.firstName < $1.firstName })
//                       //     }
//                        })
//
//                    } catch let error {
//                        print("Failed to enumerate contact", error)
//                    }
}
