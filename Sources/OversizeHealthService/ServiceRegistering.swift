//
// Copyright © 2022 Alexander Romanov
// ServiceRegistering.swift
//

import Factory
import Foundation

#if os(iOS) || os(macOS)
    public extension Container {
        @available(iOS 15, macOS 13.0, *)
        var bodyMassService: Factory<BodyMassServiceProtocol> {
            self { BodyMassService() }
        }

        @available(iOS 15, macOS 13.0, *)
        var bloodPressureService: Factory<BloodPressureService> {
            self { BloodPressureService() }
        }
    }
#endif
