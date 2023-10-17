//
// Copyright © 2022 Alexander Romanov
// CalendarService.swift
//

import EventKit
import Foundation
import OversizeCore
import OversizeModels

public actor CalendarService {
    private let eventStore: EKEventStore = .init()
    public init() {}

    func requestFullAccess() async -> Result<Bool, AppError> {
        do {
            let status: Bool
            if #available(iOS 17.0, macOS 14.0, *) {
                status = try await eventStore.requestFullAccessToEvents()
            } else {
                status = try await eventStore.requestAccess(to: .event)
            }
            if status {
                return .success(true)
            } else {
                return .failure(AppError.eventKit(type: .notAccess))
            }
        } catch {
            return .failure(AppError.eventKit(type: .notAccess))
        }
    }

    func requestWriteOnlyAccess() async -> Result<Bool, AppError> {
        do {
            let status: Bool
            if #available(iOS 17.0, macOS 14.0, *) {
                status = try await eventStore.requestWriteOnlyAccessToEvents()
            } else {
                status = try await eventStore.requestAccess(to: .event)
            }
            if status {
                return .success(true)
            } else {
                return .failure(AppError.eventKit(type: .notAccess))
            }
        } catch {
            return .failure(AppError.eventKit(type: .notAccess))
        }
    }

    public func fetchEvents(start: Date, end: Date = Date(), filtredCalendarsIds: [String] = []) async -> Result<[EKEvent], AppError> {
        let access = await requestFullAccess()
        if case let .failure(error) = access { return .failure(error) }
        let calendars = eventStore.calendars(for: .event)
        var filtredCalendars: [EKCalendar] = []
        for calendar in calendars {
            if let _ = filtredCalendarsIds.first(where: { calendar.calendarIdentifier == $0 }) {
                break
            } else {
                filtredCalendars.append(calendar)
            }
        }
        var events: [EKEvent] = []
        for calendar in filtredCalendars {
            let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: [calendar])
            let matchingEvents = eventStore.events(matching: predicate)
            events += matchingEvents
        }
        return .success(events)
    }

    public func fetchCalendars() async -> Result<[EKCalendar], AppError> {
        let access = await requestFullAccess()
        if case let .failure(error) = access { return .failure(error) }
        let calendars = eventStore.calendars(for: .event)
        return .success(calendars)
    }

    public func fetchDefaultCalendar() async -> Result<EKCalendar?, AppError> {
        let access = await requestFullAccess()
        if case let .failure(error) = access { return .failure(error) }
        let calendar = eventStore.defaultCalendarForNewEvents
        return .success(calendar)
    }

    public func fetchSourses() async -> Result<[EKSource], AppError> {
        let access = await requestFullAccess()
        if case let .failure(error) = access { return .failure(error) }
        let calendars = eventStore.sources
        return .success(calendars)
    }

    public func createEvent(
        event: EKEvent? = nil,
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
        recurrenceEndRules: CalendarEventEndRecurrenceRules = .never,
        span: EKSpan = .thisEvent
    ) async -> Result<Bool, AppError> {
        let access = await requestWriteOnlyAccess()
        if case let .failure(error) = access { return .failure(error) }
        let newEvent: EKEvent
        if let event {
            newEvent = eventStore.event(withIdentifier: event.eventIdentifier ?? "") ?? .init(eventStore: eventStore)
        } else {
            newEvent = .init(eventStore: eventStore)
        }
        newEvent.title = title
        newEvent.notes = notes
        newEvent.startDate = startDate
        newEvent.endDate = endDate
        newEvent.isAllDay = isAllDay
        newEvent.location = location
        newEvent.structuredLocation = structuredLocation
        newEvent.url = url

        if let alarms {
            newEvent.alarms = alarms.compactMap { $0.alarm }
        }

        if recurrenceRules != .never {
            let rule = recurrenceRules.rule
            rule?.recurrenceEnd = recurrenceEndRules.end
            if let rule {
                newEvent.recurrenceRules = [rule]
            }
        }

        if let calendar {
            newEvent.calendar = calendar
        } else {
            newEvent.calendar = eventStore.defaultCalendarForNewEvents
        }

        var attendees = [EKParticipant]()
        if !memberEmails.isEmpty {
            for email in memberEmails {
                if let attendee = EKParticipant.fromEmail(email) {
                    attendees.append(attendee)
                }
            }
            newEvent.setValue(attendees, forKey: "attendees")
        }

        do {
            try eventStore.save(newEvent, span: span, commit: true)
            return .success(true)
        } catch {
            return .failure(.eventKit(type: .savingItem))
        }
    }

    public func deleteEvent(identifier: String, span: EKSpan = .thisEvent) async -> Result<Bool, AppError> {
        let access = await requestFullAccess()
        if case let .failure(error) = access { return .failure(error) }
        guard let event = eventStore.fetchEvent(identifier: identifier) else { return .failure(.custom(title: "Not deleted")) }

        do {
            try eventStore.remove(event, span: span, commit: true)
            return .success(true)
        } catch {
            return .failure(.eventKit(type: .deleteItem))
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
