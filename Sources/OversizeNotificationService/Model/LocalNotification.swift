//
// Copyright © 2023 Alexander Romanov
// LocalNotification.swift
//

import Foundation

public struct LocalNotification: Sendable {
    public init(
        id: UUID,
        categoryIdentifier: String = "notification",
        title: String,
        subtitle: String? = nil,
        body: String,
        timeInterval: Double,
        repeats: Bool = false,
        bundleImageName _: String? = nil,
        userInfo: [String: String]? = nil
    ) {
        self.id = id
        scheduleType = .time
        self.title = title
        self.subtitle = subtitle
        self.body = body
        self.timeInterval = timeInterval
        dateComponents = nil
        self.repeats = repeats
        self.userInfo = userInfo
        bundleImageName = nil
        self.categoryIdentifier = categoryIdentifier
    }

    public init(
        id: UUID,
        categoryIdentifier: String = "notification",
        title: String,
        subtitle: String? = nil,
        body: String,
        dateComponents: DateComponents,
        repeats: Bool,
        bundleImageName _: String? = nil,
        userInfo: [String: String]? = nil
    ) {
        self.id = id
        scheduleType = .calendar
        self.title = title
        self.subtitle = subtitle
        self.body = body
        timeInterval = nil
        self.dateComponents = dateComponents
        self.repeats = repeats
        self.userInfo = userInfo
        bundleImageName = nil
        self.categoryIdentifier = categoryIdentifier
    }

    public init(
        id: UUID,
        categoryIdentifier: String = "notification",
        title: String,
        subtitle: String? = nil,
        body: String,
        date: Date,
        repeats: Bool,
        bundleImageName _: String? = nil,
        userInfo: [String: String]? = nil
    ) {
        self.id = id
        scheduleType = .calendar
        self.title = title
        self.subtitle = subtitle
        self.body = body
        timeInterval = nil
        dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        self.repeats = repeats
        self.userInfo = userInfo
        bundleImageName = nil
        self.categoryIdentifier = categoryIdentifier
    }

    public enum ScheduleType: Sendable {
        case time, calendar
    }

    public let id: UUID
    public let scheduleType: ScheduleType
    public let title: String
    public let body: String
    public let subtitle: String?
    public let bundleImageName: String?
    public let userInfo: [String: String]?
    public let timeInterval: Double?
    public let dateComponents: DateComponents?
    public let repeats: Bool
    public let categoryIdentifier: String
}
