//
// Copyright © 2026 Alexander Romanov
// ShareParticipantTests.swift
//

import Foundation
@testable import OversizeCloudService
import Testing

struct ShareParticipantTests {
    private func makeParticipant(
        id: String = "participant",
        firstName: String? = nil,
        lastName: String? = nil,
        email: String? = nil,
        acceptanceStatus: ShareParticipant.AcceptanceStatus = .accepted,
        permission: ShareParticipant.Permission = .readOnly,
        isOwner: Bool = false,
    ) -> ShareParticipant {
        ShareParticipant(
            id: id,
            firstName: firstName,
            lastName: lastName,
            email: email,
            acceptanceStatus: acceptanceStatus,
            permission: permission,
            isOwner: isOwner,
        )
    }

    @Test
    func displayNameUsesFullName() {
        let participant = makeParticipant(firstName: "Ada", lastName: "Lovelace", email: "ada@example.com")

        #expect(participant.displayName == "Ada Lovelace")
    }

    @Test
    func displayNameUsesAvailableNamePart() {
        #expect(makeParticipant(firstName: "Ada").displayName == "Ada")
        #expect(makeParticipant(lastName: "Lovelace").displayName == "Lovelace")
    }

    @Test
    func displayNameFallsBackToEmail() {
        let participant = makeParticipant(email: "ada@example.com")

        #expect(participant.displayName == "ada@example.com")
    }

    @Test
    func displayNameFallsBackToOwnerLabel() {
        let participant = makeParticipant(isOwner: true)

        #expect(participant.displayName == "Me")
    }

    @Test
    func displayNameFallsBackToAcceptanceStatus() {
        #expect(makeParticipant(acceptanceStatus: .pending).displayName == "Invited")
        #expect(makeParticipant(acceptanceStatus: .accepted).displayName == "Unknown")
        #expect(makeParticipant(acceptanceStatus: .removed).displayName == "Unknown")
    }

    @Test
    func avatarFirstNameUsesFirstNameThenEmailThenOwner() {
        #expect(makeParticipant(firstName: "Ada", email: "ada@example.com").avatarFirstName == "Ada")
        #expect(makeParticipant(email: "ada@example.com").avatarFirstName == "ada")
        #expect(makeParticipant(isOwner: true).avatarFirstName == "M")
        #expect(makeParticipant().avatarFirstName == nil)
    }

    @Test
    func roleTitleDependsOnOwnership() {
        #expect(makeParticipant(isOwner: true).roleTitle == "Owner")
        #expect(makeParticipant(isOwner: false).roleTitle == "Participant")
    }

    @Test
    func toggledPermissionSwitchesBetweenModes() {
        #expect(makeParticipant(permission: .readOnly).toggledPermission == .readWrite)
        #expect(makeParticipant(permission: .readWrite).toggledPermission == .readOnly)
    }

    @Test(arguments: [
        (ShareParticipant.AcceptanceStatus.pending, ShareParticipant.Permission.readOnly, "clock.fill"),
        (ShareParticipant.AcceptanceStatus.pending, ShareParticipant.Permission.readWrite, "clock.fill"),
        (ShareParticipant.AcceptanceStatus.removed, ShareParticipant.Permission.readWrite, "xmark"),
        (ShareParticipant.AcceptanceStatus.accepted, ShareParticipant.Permission.readOnly, "eye.fill"),
        (ShareParticipant.AcceptanceStatus.accepted, ShareParticipant.Permission.readWrite, "pencil"),
        (ShareParticipant.AcceptanceStatus.unknown, ShareParticipant.Permission.readWrite, "pencil"),
    ])
    func badgeSymbolName(
        status: ShareParticipant.AcceptanceStatus,
        permission: ShareParticipant.Permission,
        expected: String,
    ) {
        let participant = makeParticipant(acceptanceStatus: status, permission: permission)

        #expect(participant.badgeSymbolName == expected)
    }

    @Test(arguments: [
        (ShareParticipant.AcceptanceStatus.pending, ShareParticipant.Permission.readWrite, ShareParticipant.BadgeColorRole.warning),
        (ShareParticipant.AcceptanceStatus.removed, ShareParticipant.Permission.readWrite, ShareParticipant.BadgeColorRole.error),
        (ShareParticipant.AcceptanceStatus.accepted, ShareParticipant.Permission.readWrite, ShareParticipant.BadgeColorRole.accent),
        (ShareParticipant.AcceptanceStatus.accepted, ShareParticipant.Permission.readOnly, ShareParticipant.BadgeColorRole.secondary),
        (ShareParticipant.AcceptanceStatus.unknown, ShareParticipant.Permission.readOnly, ShareParticipant.BadgeColorRole.secondary),
    ])
    func badgeColorRole(
        status: ShareParticipant.AcceptanceStatus,
        permission: ShareParticipant.Permission,
        expected: ShareParticipant.BadgeColorRole,
    ) {
        let participant = makeParticipant(acceptanceStatus: status, permission: permission)

        #expect(participant.badgeColorRole == expected)
    }

    @Test
    func acceptanceStatusTitles() {
        #expect(ShareParticipant.AcceptanceStatus.accepted.title == "Accepted")
        #expect(ShareParticipant.AcceptanceStatus.pending.title == "Pending")
        #expect(ShareParticipant.AcceptanceStatus.removed.title == "Removed")
        #expect(ShareParticipant.AcceptanceStatus.unknown.title == "Unknown")
    }

    @Test
    func permissionTitlesAndSymbols() {
        #expect(ShareParticipant.Permission.readOnly.title == "Can View")
        #expect(ShareParticipant.Permission.readWrite.title == "Can Edit")
        #expect(ShareParticipant.Permission.readOnly.symbolName == "eye.fill")
        #expect(ShareParticipant.Permission.readWrite.symbolName == "pencil")
        #expect(ShareParticipant.Permission.allCases.count == 2)
    }

    @Test
    func participantsAreComparedByAllProperties() {
        let first = makeParticipant(firstName: "Ada")
        let second = makeParticipant(firstName: "Ada")
        let third = makeParticipant(firstName: "Grace")

        #expect(first == second)
        #expect(first != third)
        #expect(Set([first, second, third]).count == 2)
    }
}
