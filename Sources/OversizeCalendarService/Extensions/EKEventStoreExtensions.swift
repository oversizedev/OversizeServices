//
// Copyright © 2022 Alexander Romanov
// EKEventStoreExtensions.swift
//

#if canImport(EventKit)
    import EventKit
#endif

#if os(iOS) || os(macOS)
    public extension EKEventStore {
        func fetchEvent(identifier: String) -> EKEvent? {
            event(withIdentifier: identifier)
        }
    }
#endif
