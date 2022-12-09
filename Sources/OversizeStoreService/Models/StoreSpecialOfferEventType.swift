//
// Copyright © 2022 Alexander Romanov
// StoreSpecialOfferEventType.swift
//

import Foundation
import OversizeCDN

public enum StoreSpecialOfferEventType: String, Identifiable, CaseIterable, Hashable {
    case newUser, activeUser, oldUser, newYear, christmas, halloween, blackFriday, foolsDay, backToSchool, cyberMonday

    private var eventStartDate: Date? {
        let caledar = Calendar.current
        let currentYear = caledar.component(.year, from: .init())
        switch self {
        case .newYear:
            // TODO: NEW YEAR DATE
            let dateComponents = DateComponents(calendar: caledar, year: currentYear, month: 1, day: 1)
            return caledar.date(from: dateComponents)
        case .foolsDay:
            let dateComponents = DateComponents(calendar: caledar, year: currentYear, month: 4, day: 1)
            return caledar.date(from: dateComponents)
        case .backToSchool:
            let dateComponents = DateComponents(calendar: caledar, year: currentYear, month: 9, day: 1)
            return caledar.date(from: dateComponents)
        case .halloween:
            let dateComponents = DateComponents(calendar: caledar, year: currentYear, month: 10, day: 31)
            return caledar.date(from: dateComponents)
        case .blackFriday:
            let dateComponents = DateComponents(calendar: caledar, year: currentYear, month: 11, day: 25)
            return caledar.date(from: dateComponents)
        case .cyberMonday:
            let dateComponents = DateComponents(calendar: caledar, year: currentYear, month: 11, day: 28)
            return caledar.date(from: dateComponents)
        case .christmas:
            let dateComponents = DateComponents(calendar: caledar, year: currentYear, month: 12, day: 25)
            return caledar.date(from: dateComponents)
        default: return nil
        }
    }

    public var eventInterval: DateInterval? {
        let caledar = Calendar.current
        guard let startDate = eventStartDate else { return nil }
        let interval = caledar.dateInterval(of: .day, for: startDate)
        return interval
    }

    public var isNow: Bool {
        guard let interval = eventInterval else { return false }
        let date = Date()
        if date >= interval.start, date < interval.end {
            return true
        } else {
            return false
        }
    }

    public var specialOfferSubtitle: String {
        switch self {
        case .activeUser, .oldUser: return "You have a gift"
        case .newUser: return "Special introductory Offer"
        case .newYear: return "Special New Year's offer"
        case .halloween: return "Halloween Special"
        case .blackFriday: return "Black Friday Special"
        default: return "Special offer"
        }
    }

    public var isNeedTrialDescription: Bool {
        switch self {
        case .activeUser, .oldUser: return false
        default: return true
        }
    }

    public var specialOfferTitle: String {
        switch self {
        case .newUser: return "Free full access\nfor" // \(trialDaysPeriodText)"
        case .activeUser: return "Special Offer\nfor active Users"
        case .oldUser: return "Special Offer\nfor Longtime Users"
        default: return "Free full access\nfor" // \(trialDaysPeriodText)"
        }
    }

    public var specialOfferBannerTitle: String {
        switch self {
        case .activeUser, .oldUser: return "You have a gift"
        case .newUser: return "Special introductory Offer"
        case .newYear: return "Special New Year's offer"
        case .halloween: return "Halloween Special Offer"
        case .blackFriday: return "Black Friday Special Offer"
        default: return "Special offer"
        }
    }

    public var specialOfferDescription: String {
        switch self {
        case .newUser: return "Use the offer at low price\n and long trial periods for new users"
        case .activeUser: return "Take advantage of the low price\n offer and long trial periods"
        default: return "Take advantage of the low price\n offer and long trial periods"
        }
    }

    public var specialOfferImageURL: String {
        switch self {
        case .newUser: return IllustrationCDN.Objects.Christmas.Gift1.large
        case .activeUser: return IllustrationCDN.Objects.Christmas.Gift1.large
        case .oldUser: return IllustrationCDN.Objects.Sundry.Hand.large
        case .newYear: return IllustrationCDN.Objects.Christmas.Snowman.large
        case .halloween: return IllustrationCDN.Objects.Tools.Broom.large
        case .blackFriday: return IllustrationCDN.Objects.Tools.Bolt.large
        case .foolsDay: return IllustrationCDN.Objects.Sundry.Smile.large
        case .backToSchool: return IllustrationCDN.Objects.Education.Pencil2a.large
        case .christmas: return IllustrationCDN.Objects.Christmas.Sock.large
        case .cyberMonday: return IllustrationCDN.Objects.Toys.Gamepad.large
        }
    }

    public var id: String {
        rawValue
    }
}
