//
// Copyright © 2022 Alexander Romanov
// ContactsService.swift
//

#if canImport(Contacts)
    import Contacts
#endif
import Foundation
import OversizeModels

#if os(iOS) || os(macOS)
    public actor ContactsService {
        private let contactStore: CNContactStore = .init()
        public init() {}

        public func requestAccess() async -> Result<Bool, AppError> {
            do {
                let status = try await contactStore.requestAccess(for: .contacts)
                if status {
                    return .success(true)
                } else {
                    return .failure(AppError.contacts(type: .notAccess))
                }
            } catch {
                return .failure(AppError.contacts(type: .notAccess))
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
                    continuation.resume(throwing: AppError.contacts(type: .unknown))
                }
            }
        }
    }
#endif
