//
// Copyright © 2022 Alexander Romanov
// CredentialsPropertyWrapper.swift
//

import SwiftUI

@propertyWrapper
public struct Credentials: DynamicProperty {
    private let label: String
    private let storage = SecureStorageService()

    public init(_ label: String) {
        self.label = label
    }

    public var wrappedValue: SecureStorageService.Credentials? {
        get { storage.getCredentials(with: label) }
        nonmutating set {
            if let newValue = newValue {
                storage.updateCredentials(newValue, with: label)
            } else {
                storage.deleteCredentials(with: label)
            }
        }
    }
}

/* Use code
 Code form https://habr.com/ru/post/670490/
 final class SecureSettings {
     @Credentials("account")
     var account: SecureStorage.Credentials?

     @Credentials("subAccount")
     var subAccount: SecureStorage.Credentials?

     @Password("authToken")
     var authToken: String?

     @Password("refreshToken")
     var refreshToken: String?

     func clear() {
         account = nil
         subAccount = nil
         accessToken = nil
         refreshToken = nil
     }
 }
 */
