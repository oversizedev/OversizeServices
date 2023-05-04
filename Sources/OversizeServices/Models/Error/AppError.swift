//
// Copyright © 2022 Alexander Romanov
// AppError.swift
//

import SwiftUI

public protocol AppErrorProtocol {
    var title: String { get }
    var subtitle: String? { get }
    var image: Image? { get }
    var icon: Image? { get }
}

public enum AppError: Error {
    case network(type: Enums.NetworkError)
    case cloudKit(type: Enums.CloudKit)
    case location(type: Enums.Location)
    case coreData(type: Enums.CoreData)
    case eventKit(type: Enums.EventKit)
    case contacts(type: Enums.Contacts)
    case notifications(type: Enums.Notification)
    case cloudDocuments(type: Enums.CloudDocuments)
    case fileManager(type: Enums.FileManager)
    case custom(title: String, subtitle: String? = nil, image: Image? = nil)
    public class Enums {}
}

extension AppError: AppErrorProtocol {
    public var title: String {
        switch self {
        case let .network(type): return type.title
        case let .cloudKit(type): return type.title
        case let .location(type): return type.title
        case let .coreData(type): return type.title
        case let .eventKit(type): return type.title
        case let .contacts(type): return type.title
        case let .notifications(type): return type.title
        case let .cloudDocuments(type): return type.title
        case let .fileManager(type): return type.title
        case let .custom(title, _, _): return title
        }
    }

    public var subtitle: String? {
        switch self {
        case let .network(type): return type.subtitle
        case let .cloudKit(type): return type.subtitle
        case let .location(type): return type.subtitle
        case let .coreData(type): return type.subtitle
        case let .eventKit(type): return type.subtitle
        case let .contacts(type): return type.subtitle
        case let .notifications(type): return type.subtitle
        case let .cloudDocuments(type): return type.subtitle
        case let .fileManager(type): return type.subtitle
        case let .custom(_, subtitle, _): return subtitle
        }
    }

    public var image: Image? {
        switch self {
        case let .network(type): return type.image
        case let .cloudKit(type): return type.image
        case let .location(type): return type.image
        case let .coreData(type): return type.image
        case let .eventKit(type): return type.image
        case let .contacts(type): return type.image
        case let .notifications(type): return type.image
        case let .cloudDocuments(type): return type.image
        case let .fileManager(type): return type.image
        case let .custom(_, _, image): return image
        }
    }

    public var icon: Image? {
        switch self {
        case let .network(type): return type.icon
        case let .cloudKit(type): return type.icon
        case let .location(type): return type.icon
        case let .coreData(type): return type.icon
        case let .eventKit(type): return type.image
        case let .contacts(type): return type.image
        case let .notifications(type): return type.icon
        case let .cloudDocuments(type): return type.icon
        case let .fileManager(type): return type.icon
        case let .custom(_, _, image): return image
        }
    }
}
