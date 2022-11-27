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

        //
    }

    public func fetchCalendars() async -> Result<[EKCalendar], AppError> {
        let access = await requestAccess()
        if case let .failure(error) = access { return .failure(error) }
        let calendars = eventStore.calendars(for: .event)
        return .success(calendars)
    }

//    func getEvents() -> [EKEvent] {
//        var allEvents: [EKEvent] = []
//
//        // calendars
//        let calendars = self.eventStore.calendars(for: .event)
//
//        // iterate over all selected calendars
//        for (_, calendar) in calendars.enumerated() where isCalendarSelected(calendar.calendarIdentifier) {
//
//            // predicate for today (start to end)
//            let predicate = self.eventStore.predicateForEvents(withStart: self.initialDates.first!, end: self.initialDates.last!, calendars: [calendar])
//
//            let matchingEvents = self.eventStore.events(matching: predicate)
//
//            // iterate through events
//            for event in matchingEvents {
//                allEvents.append(event)
//            }
//        }
//
//        return allEvents
//    }
}

extension CalendarService {
    func fetchCalendars() async -> [EKCalendar] {
        var responseCalendars = [EKCalendar]()

        eventStore.requestAccess(to: .event, completion: { (granted: Bool, _) in
            if granted {
                let calendars = self.eventStore.calendars(for: .event)

                responseCalendars = calendars

//                for calendar in calendars {
//                    responseCalendars.append(calendar)
//                    // print("Title: \(calendar.title)")
//                    // self.calendarsNames.append(calendar.title)
//                }
            }
        })
        return responseCalendars
    }

    func fetchCalendarNames() -> [String] {
        var responseCalendars = [String]()

        eventStore.requestAccess(to: .event, completion: { (granted: Bool, _) in
            if granted {
                print("Ok")

                let calendars = self.eventStore.calendars(for: .event)

                for calendar in calendars {
                    log(calendar.title)
                    // self.epic.append(calendar.title)
                    // print("Title: \(calendar.title)")
                    // self.calendarsNames.append(calendar.title)
                }

                responseCalendars.append("ada")
            }
        })

        print(responseCalendars)
        return responseCalendars
    }
}
