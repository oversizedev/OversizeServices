//
// Copyright © 2022 Alexander Romanov
// ServiceRegistering.swift
//

import Factory
import Foundation
import OversizeServices

public extension Container {
    var calendarService: Factory<CalendarService> {
        self { CalendarService() }
    }
}
