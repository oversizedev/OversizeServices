//
// Copyright © 2022 Alexander Romanov
// CalendarService.swift
//

import EventKit
import Foundation
import OversizeCore
import OversizeServices

public actor CalendarService {
    private let eventStore: EKEventStore = .init()
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
        location: String? = nil,
        structuredLocation: EKStructuredLocation? = nil,
        alarms: [CalendarAlertsTimes]? = nil,
        url: URL? = nil,
        memberEmails: [String] = [],
        recurrenceRules: CalendarEventRecurrenceRules = .never,
        recurrenceEndRules: CalendarEventEndRecurrenceRules = .never
    ) async -> Result<Bool, AppError> {
        let access = await requestAccess()
        if case let .failure(error) = access { return .failure(error) }
        let event: EKEvent = .init(eventStore: eventStore)
        event.title = title
        event.notes = notes
        event.startDate = startDate
        event.endDate = endDate
        event.isAllDay = isAllDay
        event.location = location
        event.structuredLocation = structuredLocation
        event.url = url

        if let alarms {
            event.alarms = alarms.compactMap { $0.alarm }
        }

        if recurrenceRules != .never {
            let rule = recurrenceRules.rule
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

        var attendees = [EKParticipant]()
        if !memberEmails.isEmpty {
            for email in memberEmails {
                if let attendee = EKParticipant.fromEmail(email) {
                    attendees.append(attendee)
                }
            }
            event.setValue(attendees, forKey: "attendees")
        }

        do {
            try eventStore.save(event, span: .thisEvent)
            return .success(true)
        } catch {
            return .failure(.custom(title: "Not save event"))
        }
    }
}

extension CalendarService {
    private func convertEventToCalendarEventRecurrenceRules(event: EKEvent) -> CalendarEventRecurrenceRules {
        let eventRule = event.recurrenceRules?.first

        if let rule = CalendarEventRecurrenceRules.allCases.first(where: {
            $0.rule?.frequency == eventRule?.frequency
                && $0.rule?.interval == eventRule?.interval
                && $0.rule?.daysOfTheWeek == eventRule?.daysOfTheWeek
                && $0.rule?.daysOfTheWeek == eventRule?.daysOfTheWeek
        }) {
            return rule
        } else {
            return .custom(eventRule)
        }
    }

    private func convertRecurrenceRuleToCalendarEventRecurrenceRules(rule: EKRecurrenceRule) -> CalendarEventRecurrenceRules {
        if let rule = CalendarEventRecurrenceRules.allCases.first(where: {
            $0.rule?.frequency == rule.frequency
                && $0.rule?.interval == rule.interval
                && $0.rule?.daysOfTheWeek == rule.daysOfTheWeek
                && $0.rule?.daysOfTheWeek == rule.daysOfTheWeek
        }) {
            return rule
        } else {
            return .custom(rule)
        }
    }

    private func convertRecurrenceRuleToCalendarEventEndRecurrenceRules(ruleEnd: EKRecurrenceEnd?) -> CalendarEventEndRecurrenceRules {
        if let endDate = ruleEnd?.endDate {
            return .endDate(endDate)
        } else if let count = ruleEnd?.occurrenceCount, count != 0 {
            return .occurrenceCount(count)
        } else {
            return .never
        }
    }
}
