//
// Copyright © 2022 Alexander Romanov
// CalendarService.swift
//

import EventKit
import Foundation
import OversizeCore
import OversizeServices

open class CalendarService {
    let eventStore: EKEventStore = .init()
    public init() {}

    func requestAccess() async -> Result<Bool, AppError> {
        do {
            try await eventStore.requestAccess(to: .event)
            return .success(true)
        } catch {
            return .failure(AppError.custom(title: "Not Access"))
        }
    }

    public func fetchEvents(start: Date, end: Date = Date() /* , calendars: [EKCalendar]? = nil */ ) async -> Result<[EKEvent], AppError> {
        let access = await requestAccess()
        if case let .failure(error) = access { return .failure(error) }
        let calendars = eventStore.calendars(for: .event)
        var events: [EKEvent] = []
        for calendar in calendars {
            let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: [calendar])
            let matchingEvents = eventStore.events(matching: predicate)
            events += matchingEvents
        }
        return .success(events)
    }

    public func fetchCalendars() async -> Result<[EKCalendar], AppError> {
        let access = await requestAccess()
        if case let .failure(error) = access { return .failure(error) }
        let calendars = eventStore.calendars(for: .event)
        return .success(calendars)
    }

    public func fetchSourses() async -> Result<[EKSource], AppError> {
        let access = await requestAccess()
        if case let .failure(error) = access { return .failure(error) }
        let calendars = eventStore.sources
        return .success(calendars)
    }

    public func createEvent(
        title: String,
        notes: String? = nil,
        startDate: Date,
        endDate: Date,
        calendar: EKCalendar? = nil,
        isAllDay: Bool = false,
        structuredLocation: EKStructuredLocation? = nil,
        alarm: [EKAlarm]? = nil,
        url: URL? = nil,
        recurrenceRules: CalendarEventRecurrenceRules = .never,
        recurrenceEndRules: CalendarEventEndRecurrenceRules = .never
    ) async -> Result<Bool, AppError> {
        let access = await requestAccess()
        if case let .failure(error) = access { return .failure(error) }
        var event: EKEvent = .init(eventStore: eventStore)
        event.title = title
        event.notes = notes
        event.startDate = startDate
        event.endDate = endDate
        event.isAllDay = isAllDay
        event.structuredLocation = structuredLocation
        event.alarms = alarm
        event.url = url
        if recurrenceRules != .never {
            var rule = recurrenceRules.rule
            rule?.recurrenceEnd = recurrenceEndRules.end
            if let rule {
                event.recurrenceRules = [rule]
            }
        }
        if let calendar {
            event.calendar = calendar
        } else {
            event.calendar = eventStore.defaultCalendarForNewEvents
        }
        do {
            try eventStore.save(event, span: .thisEvent)
            return .success(true)
        } catch {
            return .failure(.custom(title: "Not save event"))
        }
    }
}