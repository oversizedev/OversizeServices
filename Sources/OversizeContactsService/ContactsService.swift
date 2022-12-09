//
// Copyright © 2022 Alexander Romanov
// ContactsService.swift
//

import Contacts
import Foundation
import OversizeServices

public actor ContactsService {
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
}
