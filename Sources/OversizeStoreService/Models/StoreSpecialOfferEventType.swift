//
// Copyright © 2022 Alexander Romanov
// StoreSpecialOfferEventType.swift
//

import Foundation

public enum StoreSpecialOfferEventType: String, Identifiable, CaseIterable, Hashable {
    case newUser, activeUser, oldUser, newYear, christmas, halloween, blackFriday, foolsDay, backToSchool, cyberMonday

    private var eventStartDate: Date? {
        let caledar = Calendar.current
        let currentYear = caledar.component(.year, from: .init())
        switch self {
        case .newYear:
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
            let dateComponents = DateComponents(calendar: caledar, year: currentYear, month: 12, day: 21)
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
        case .activeUser, .oldUser: "You have a gift"
        case .newUser: "Special introductory Offer"
        case .newYear: "Special New Year's offer"
        case .halloween: "Halloween Special"
        case .blackFriday: "Black Friday Special"
        default: "Special offer"
        }
    }

    public var isNeedTrialDescription: Bool {
        switch self {
        case .activeUser, .oldUser: false
        default: true
        }
    }

    public var specialOfferTitle: String {
        switch self {
        case .newUser: "Free full access\nfor" // \(trialDaysPeriodText)"
        case .activeUser: "Special Offer\nfor active Users"
        case .oldUser: "Special Offer\nfor Longtime Users"
        default: "Free full access\nfor" // \(trialDaysPeriodText)"
        }
    }

    public var specialOfferBannerTitle: String {
        switch self {
        case .activeUser, .oldUser: "You have a gift"
        case .newUser: "Special introductory Offer"
        case .newYear: "Special New Year's offer"
        case .halloween: "Halloween Special Offer"
        case .blackFriday: "Black Friday Special Offer"
        default: "Special offer"
        }
    }

    public var specialOfferDescription: String {
        switch self {
        case .newUser: "Use the offer at low price\n and long trial periods for new users"
        case .activeUser: "Take advantage of the low price\n offer and long trial periods"
        default: "Take advantage of the low price\n offer and long trial periods"
        }
    }

    public var specialOfferImageURL: String {
        switch self {
        case .newUser: "objects/christmas/gift1/large.png"
        case .activeUser: "objects/christmas/gift1/large.png"
        case .oldUser: "objects/sundry/hand/large.png"
        case .newYear: "objects/christmas/snowman/large.png"
        case .halloween: "objects/tools/broom/large.png"
        case .blackFriday: "objects/tools/bolt/large.png"
        case .foolsDay: "objects/sundry/smile/large.png"
        case .backToSchool: "objects/education/pencil2a/large.png"
        case .christmas: "objects/christmas/sock/large.png"
        case .cyberMonday: "objects/toys/gamepad/large.png"
        }
    }

    public var id: String {
        rawValue
    }
}
