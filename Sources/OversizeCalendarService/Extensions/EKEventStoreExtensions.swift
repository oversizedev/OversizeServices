//
// Copyright © 2022 Alexander Romanov
// EKEventStoreExtensions.swift
//

import EventKit

public extension EKEventStore {
    func fetchEvent(identifier: String) -> EKEvent? {
        event(withIdentifier: identifier)
    }
}
