//
// Copyright © 2026 Alexander Romanov
// StoreSpecialOfferEventTypeTests.swift
//

import Foundation
@testable import OversizeStoreService
import Testing

struct StoreSpecialOfferEventTypeTests {
    private let audienceCases: [StoreSpecialOfferEventType] = [.newUser, .activeUser, .oldUser]
    private let calendarCases: [StoreSpecialOfferEventType] = [
        .newYear, .christmas, .halloween, .blackFriday, .foolsDay, .backToSchool, .cyberMonday,
    ]

    @Test
    func audienceCasesHaveNoEventInterval() {
        for event in audienceCases {
            #expect(event.eventInterval == nil)
            #expect(event.isNow == false)
        }
    }

    @Test
    func calendarCasesCoverExactlyOneDay() throws {
        for event in calendarCases {
            let interval = try #require(event.eventInterval)

            #expect(interval.duration > 0)
            #expect(Calendar.current.isDate(interval.start, inSameDayAs: interval.end.addingTimeInterval(-1)))
            #expect(Calendar.current.startOfDay(for: interval.start) == interval.start)
        }
    }

    @Test
    func isNowMatchesEventInterval() throws {
        let now = Date()

        for event in calendarCases {
            let interval = try #require(event.eventInterval)

            #expect(event.isNow == (now >= interval.start && now < interval.end))
        }
    }

    @Test
    func calendarCasesUseCurrentYear() throws {
        let currentYear = Calendar.current.component(.year, from: Date())

        for event in calendarCases {
            let interval = try #require(event.eventInterval)

            #expect(Calendar.current.component(.year, from: interval.start) == currentYear)
        }
    }

    @Test
    func identifiersMatchRawValues() {
        for event in StoreSpecialOfferEventType.allCases {
            #expect(event.id == event.rawValue)
        }
        #expect(StoreSpecialOfferEventType.allCases.count == 10)
    }

    @Test
    func everyCaseHasImage() {
        for event in StoreSpecialOfferEventType.allCases {
            #expect(event.specialOfferImageURL.hasSuffix("/large.png"))
        }
        #expect(Set(StoreSpecialOfferEventType.allCases.map(\.specialOfferImageURL)).count == 9)
    }

    @Test
    func trialDescriptionIsHiddenForExistingUsers() {
        #expect(StoreSpecialOfferEventType.activeUser.isNeedTrialDescription == false)
        #expect(StoreSpecialOfferEventType.oldUser.isNeedTrialDescription == false)
        #expect(StoreSpecialOfferEventType.newUser.isNeedTrialDescription)
        #expect(StoreSpecialOfferEventType.newYear.isNeedTrialDescription)
    }

    @Test
    func subtitlesAndTitlesForKnownCases() {
        #expect(StoreSpecialOfferEventType.activeUser.specialOfferSubtitle == "You have a gift")
        #expect(StoreSpecialOfferEventType.newUser.specialOfferSubtitle == "Special introductory Offer")
        #expect(StoreSpecialOfferEventType.newYear.specialOfferSubtitle == "Special New Year's offer")
        #expect(StoreSpecialOfferEventType.cyberMonday.specialOfferSubtitle == "Special offer")

        #expect(StoreSpecialOfferEventType.activeUser.specialOfferTitle == "Special Offer\nfor active Users")
        #expect(StoreSpecialOfferEventType.oldUser.specialOfferTitle == "Special Offer\nfor Longtime Users")
        #expect(StoreSpecialOfferEventType.newUser.specialOfferTitle == "Free full access\nfor")

        #expect(StoreSpecialOfferEventType.halloween.specialOfferBannerTitle == "Halloween Special Offer")
        #expect(StoreSpecialOfferEventType.blackFriday.specialOfferBannerTitle == "Black Friday Special Offer")
    }
}
