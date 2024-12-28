//
// Copyright © 2022 Alexander Romanov
// ServiceRegistering.swift
//

import Factory
import Foundation

#if !os(tvOS)
public extension Container {
    var calendarService: Factory<CalendarService> {
        self { CalendarService() }
    }
}
#endif
