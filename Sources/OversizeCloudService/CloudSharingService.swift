// Copyright © 2026 Alexander Romanov
// CloudSharingService.swift

import CloudKit
import Foundation

public actor CloudSharingService {
    public nonisolated let container: CKContainer
    private var privateCloudDatabase: CKDatabase {
        container.privateCloudDatabase
    }

    public init(containerIdentifier: String) {
        container = CKContainer(identifier: containerIdentifier)
    }

    // MARK: - Zone

    public nonisolated func zoneID(zoneName: String) -> CKRecordZone.ID {
        CKRecordZone.ID(zoneName: zoneName, ownerName: CKCurrentUserDefaultName)
    }

    public func ensureZone(zoneName: String) async throws -> CKRecordZone {
        let zone = CKRecordZone(zoneID: zoneID(zoneName: zoneName))
        return try await privateCloudDatabase.save(zone)
    }

    // MARK: - Share

    public func fetchShare(zoneID: CKRecordZone.ID) async throws -> CKShare? {
        let shareRecordID = CKRecord.ID(recordName: CKRecordNameZoneWideShare, zoneID: zoneID)
        do {
            return try await privateCloudDatabase.record(for: shareRecordID) as? CKShare
        } catch let error as CKError where error.code == .unknownItem {
            return nil
        }
    }

    public func createShare(
        zoneID: CKRecordZone.ID,
        records: [CKRecord],
        title: String,
        publicPermission: CKShare.ParticipantPermission,
    ) async throws -> (CKShare, CKContainer) {
        var allRecords = records
        let share = CKShare(recordZoneID: zoneID)
        share[CKShare.SystemFieldKey.title] = title as CKRecordValue
        share.publicPermission = publicPermission
        allRecords.append(share)

        let result = try await privateCloudDatabase.modifyRecords(
            saving: allRecords,
            deleting: [],
        )
        for case let .failure(error) in result.saveResults.values {
            throw error
        }
        guard let savedShare = result.saveResults.values
            .compactMap({ try? $0.get() })
            .first(where: { $0 is CKShare }) as? CKShare
        else {
            throw CKError(.serverResponseLost)
        }
        return (savedShare, container)
    }

    public func syncRecords(
        _ records: [CKRecord],
        inZone zoneID: CKRecordZone.ID,
        recordTypes: [String],
    ) async throws {
        let newIDs = Set(records.map { $0.recordID })
        var toDelete: [CKRecord.ID] = []
        for type in recordTypes {
            let existing = try await fetchZoneRecords(type: type, zoneID: zoneID)
            toDelete += existing.map { $0.recordID }.filter { !newIDs.contains($0) }
        }
        let result = try await privateCloudDatabase.modifyRecords(
            saving: records,
            deleting: toDelete,
        )
        for case let .failure(error) in result.saveResults.values {
            throw error
        }
        for case let .failure(error) in result.deleteResults.values {
            throw error
        }
    }

    // MARK: - Participants

    public func fetchOwner(zoneID: CKRecordZone.ID) async throws -> ShareParticipant? {
        guard let share = try await fetchShare(zoneID: zoneID) else { return nil }
        return share.participants
            .first(where: { $0.role == .owner })
            .map { ShareParticipant(from: $0) }
    }

    public func fetchParticipants(zoneID: CKRecordZone.ID) async throws -> [ShareParticipant] {
        guard let share = try await fetchShare(zoneID: zoneID) else { return [] }
        return share.participants
            .filter { $0.role != .owner }
            .map { ShareParticipant(from: $0) }
    }

    public func updatePermission(
        for participant: ShareParticipant,
        to permission: ShareParticipant.Permission,
        zoneID: CKRecordZone.ID,
    ) async throws {
        guard let share = try await fetchShare(zoneID: zoneID) else { return }
        guard let ckParticipant = ckParticipant(matching: participant.id, in: share) else { return }
        ckParticipant.permission = permission == .readWrite ? .readWrite : .readOnly
        let result = try await privateCloudDatabase.modifyRecords(saving: [share], deleting: [])
        for case let .failure(error) in result.saveResults.values {
            throw error
        }
    }

    public func removeParticipant(_ participant: ShareParticipant, zoneID: CKRecordZone.ID) async throws {
        guard let share = try await fetchShare(zoneID: zoneID) else { return }
        guard let ckParticipant = ckParticipant(matching: participant.id, in: share) else { return }
        share.removeParticipant(ckParticipant)
        let result = try await privateCloudDatabase.modifyRecords(saving: [share], deleting: [])
        for case let .failure(error) in result.saveResults.values {
            throw error
        }
    }

    // MARK: - Private

    private func ckParticipant(matching id: String, in share: CKShare) -> CKShare.Participant? {
        share.participants.first(where: {
            $0.userIdentity.userRecordID?.recordName == id || $0.userIdentity.lookupInfo?.emailAddress == id
        })
    }

    private func fetchZoneRecords(type: String, zoneID: CKRecordZone.ID) async throws -> [CKRecord] {
        let initial = try await privateCloudDatabase.records(
            matching: CKQuery(recordType: type, predicate: NSPredicate(value: true)),
            inZoneWith: zoneID,
        )
        var allRecords = initial.matchResults.compactMap { try? $0.1.get() }
        var cursor = initial.queryCursor
        while let currentCursor = cursor {
            let next = try await privateCloudDatabase.records(continuingMatchFrom: currentCursor)
            allRecords += next.matchResults.compactMap {
                try? $0.1.get()
            }
            cursor = next.queryCursor
        }
        return allRecords
    }
}
