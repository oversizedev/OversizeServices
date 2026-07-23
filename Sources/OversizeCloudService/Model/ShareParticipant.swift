// Copyright © 2026 Alexander Romanov
// ShareParticipant.swift

import CloudKit
import Foundation

public struct ShareParticipant: Identifiable, Sendable, Hashable {
    public let id: String
    public let firstName: String?
    public let lastName: String?
    public let email: String?
    public let acceptanceStatus: AcceptanceStatus
    public let permission: Permission
    public let isOwner: Bool

    public init(
        id: String,
        firstName: String?,
        lastName: String?,
        email: String?,
        acceptanceStatus: AcceptanceStatus,
        permission: Permission,
        isOwner: Bool,
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.acceptanceStatus = acceptanceStatus
        self.permission = permission
        self.isOwner = isOwner
    }

    public var displayName: String {
        let full = [firstName, lastName].compactMap { $0 }.joined(separator: " ")
        if !full.isEmpty {
            return full
        }
        if let email {
            return email
        }
        if isOwner {
            return "Me"
        }
        return acceptanceStatus == .pending ? "Invited" : "Unknown"
    }

    public var avatarFirstName: String? {
        if let firstName {
            return firstName
        }
        if let email {
            return email.components(separatedBy: "@").first
        }
        if isOwner {
            return "M"
        }
        return nil
    }

    public var roleTitle: String {
        isOwner ? "Owner" : "Participant"
    }

    public var toggledPermission: Permission {
        permission == .readWrite ? .readOnly : .readWrite
    }

    public var badgeSymbolName: String {
        switch acceptanceStatus {
        case .pending:
            "clock.fill"
        case .removed:
            "xmark"
        case .accepted, .unknown:
            permission.symbolName
        }
    }

    public var badgeColorRole: BadgeColorRole {
        switch acceptanceStatus {
        case .pending:
            .warning
        case .removed:
            .error
        case .accepted, .unknown:
            permission == .readWrite ? .accent : .secondary
        }
    }

    public enum BadgeColorRole: Sendable, Hashable {
        case warning
        case error
        case accent
        case secondary
    }

    public enum AcceptanceStatus: Sendable, Hashable {
        case accepted
        case pending
        case removed
        case unknown

        public var title: String {
            switch self {
            case .accepted: "Accepted"
            case .pending: "Pending"
            case .removed: "Removed"
            case .unknown: "Unknown"
            }
        }
    }

    public enum Permission: String, Sendable, Hashable, CaseIterable {
        case readOnly
        case readWrite

        public var title: String {
            switch self {
            case .readOnly: "Can View"
            case .readWrite: "Can Edit"
            }
        }

        public var symbolName: String {
            switch self {
            case .readOnly: "eye.fill"
            case .readWrite: "pencil"
            }
        }
    }
}

// MARK: - CKShare.Participant conversion

public extension ShareParticipant {
    init(from participant: CKShare.Participant) {
        let userRecordName = participant.userIdentity.userRecordID?.recordName
        let email = participant.userIdentity.lookupInfo?.emailAddress
        id = userRecordName ?? email ?? UUID().uuidString

        let components = participant.userIdentity.nameComponents
        firstName = components?.givenName
        lastName = components?.familyName

        self.email = email

        switch participant.acceptanceStatus {
        case .accepted: acceptanceStatus = .accepted
        case .pending: acceptanceStatus = .pending
        case .removed: acceptanceStatus = .removed
        default: acceptanceStatus = .unknown
        }

        switch participant.permission {
        case .readWrite: permission = .readWrite
        default: permission = .readOnly
        }

        isOwner = participant.role == .owner
    }
}
