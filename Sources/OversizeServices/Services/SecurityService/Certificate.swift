//
// Copyright © 2024 Alexander Romanov
// Certificate.swift, created on 05.11.2024
//

import Foundation

// public extension SecureStorageService {
//    func addCertificate(_ certificate: String, for account: String) {
//        var query: [CFString: Any] = [:]
//        query[kSecClass] = kSecClassCertificate
//        query[kSecAttrAccount] = account
//        query[kSecAttrAccessible] = kSecAttrAccessibleAfterFirstUnlock
//        query[kSecValueData] = certificate.data(using: .utf8)
//        do {
//            try addItem(query: query)
//        } catch {
//            return
//        }
//    }
//
//    func updateCertificate(_ certificate: String, for account: String) {
//        guard let _ = getCertificate(for: account) else {
//            addCertificate(certificate, for: account)
//            return
//        }
//
//        var query: [CFString: Any] = [:]
//        query[kSecClass] = kSecClassCertificate
//        query[kSecAttrAccount] = account
//        var attributesToUpdate: [CFString: Any] = [:]
//        attributesToUpdate[kSecValueData] = certificate.data(using: .utf8)
//
//        do {
//            try updateItem(query: query, attributesToUpdate: attributesToUpdate)
//        } catch {
//            return
//        }
//    }
//
//    func getCertificate(for account: String) -> String? {
//        var query: [CFString: Any] = [:]
//        query[kSecClass] = kSecClassCertificate
//        query[kSecAttrAccount] = account
//        var result: [CFString: Any]?
//
//        do {
//            result = try findItem(query: query)
//        } catch {
//            return nil
//        }
//
//        if let data = result?[kSecValueData] as? Data {
//            return String(data: data, encoding: .utf8)
//        } else {
//            return nil
//        }
//    }
//
//    func deleteCertificate(for account: String) {
//        var query: [CFString: Any] = [:]
//        query[kSecClass] = kSecClassCertificate
//        query[kSecAttrAccount] = account
//        do {
//            try deleteItem(query: query)
//        } catch {
//            return
//        }
//    }
// }
