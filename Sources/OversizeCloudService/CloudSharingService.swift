// Copyright © 2026 Alexander Romanov
// CloudSharingService.swift

import CloudKit
import Foundation

public actor CloudSharingService {
    public nonisolated let container: CKContainer

    public nonisolated var privateCloudDatabase: CKDatabase {
        container.privateCloudDatabase
    }

    public nonisolated var sharedCloudDatabase: CKDatabase {
        container.sharedCloudDatabase
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

    public func deleteZone(zoneName: String) async throws {
        let id = zoneID(zoneName: zoneName)
        try await privateCloudDatabase.deleteRecordZone(withID: id)
    }

    public func sharedZoneID(for planId: UUID) async throws -> CKRecordZone.ID? {
        let zoneName = "plan-\(planId.uuidString)"
        let zones = try await sharedCloudDatabase.allRecordZones()
        return zones.first(where: { $0.zoneID.zoneName == zoneName })?.zoneID
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
        database: CKDatabase? = nil,
    ) async throws {
        let db = database ?? privateCloudDatabase
        let newIDs = Set(records.map { $0.recordID })
        var toDelete: [CKRecord.ID] = []
        for type in recordTypes {
            let existing = try await fetchZoneRecords(type: type, zoneID: zoneID, database: db)
            toDelete += existing.map { $0.recordID }.filter { !newIDs.contains($0) }
        }
        let result = try await db.modifyRecords(
            saving: records,
            deleting: toDelete,
            savePolicy: .allKeys,
        )
        for case let .failure(error) in result.saveResults.values {
            throw error
        }
        for case let .failure(error) in result.deleteResults.values {
            throw error
        }
    }

    // MARK: - Incremental Sync

    public func fetchZoneChanges(
        zoneID: CKRecordZone.ID,
        changeToken: CKServerChangeToken?,
        database: CKDatabase? = nil,
    ) async throws -> (records: [CKRecord], deleted: [CKRecord.ID], newToken: CKServerChangeToken?) {
        let db = database ?? privateCloudDatabase
        let (stream, continuation) = AsyncThrowingStream<ZoneChangeEvent, Error>.makeStream()

        let config = CKFetchRecordZoneChangesOperation.ZoneConfiguration()
        config.previousServerChangeToken = changeToken

        let operation = CKFetchRecordZoneChangesOperation(
            recordZoneIDs: [zoneID],
            configurationsByRecordZoneID: [zoneID: config],
        )
        operation.recordWasChangedBlock = { _, result in
            if case let .success(record) = result {
                continuation.yield(.changed(record))
            }
        }
        operation.recordWithIDWasDeletedBlock = { recordID, _ in
            continuation.yield(.deleted(recordID))
        }
        operation.recordZoneChangeTokensUpdatedBlock = { _, token, _ in
            if let token { continuation.yield(.tokenUpdated(token)) }
        }
        operation.fetchRecordZoneChangesResultBlock = { result in
            switch result {
            case .success: continuation.finish()
            case let .failure(error): continuation.finish(throwing: error)
            }
        }
        db.add(operation)

        var records: [CKRecord] = []
        var deletedIDs: [CKRecord.ID] = []
        var newToken: CKServerChangeToken?
        for try await event in stream {
            switch event {
            case let .changed(record): records.append(record)
            case let .deleted(id): deletedIDs.append(id)
            case let .tokenUpdated(token): newToken = token
            }
        }
        return (records: records, deleted: deletedIDs, newToken: newToken)
    }

    // MARK: - Subscriptions

    public func setupZoneSubscription(zoneID: CKRecordZone.ID, database: CKDatabase? = nil) async throws {
        let db = database ?? privateCloudDatabase
        let subscriptionID = "zone-\(zoneID.zoneName)"
        let subscription = CKRecordZoneSubscription(zoneID: zoneID, subscriptionID: subscriptionID)
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
        _ = try await db.save(subscription)
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

    public func canCurrentUserEdit(zoneID: CKRecordZone.ID) async throws -> Bool {
        guard let share = try await fetchShare(zoneID: zoneID) else { return true }
        guard let participant = share.currentUserParticipant else { return true }
        return participant.role == .owner || participant.permission == .readWrite
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

    private func fetchZoneRecords(type: String, zoneID: CKRecordZone.ID, database: CKDatabase) async throws -> [CKRecord] {
        let (stream, continuation) = AsyncThrowingStream<CKRecord, Error>.makeStream()
        let operation = CKFetchRecordZoneChangesOperation(
            recordZoneIDs: [zoneID],
            configurationsByRecordZoneID: [zoneID: .init()],
        )
        operation.recordWasChangedBlock = { _, result in
            if case let .success(record) = result, record.recordType == type {
                continuation.yield(record)
            }
        }
        operation.fetchRecordZoneChangesResultBlock = { result in
            switch result {
            case .success: continuation.finish()
            case let .failure(error): continuation.finish(throwing: error)
            }
        }
        database.add(operation)
        var records: [CKRecord] = []
        for try await record in stream {
            records.append(record)
        }
        return records
    }
}

// MARK: - Private Types

private enum ZoneChangeEvent: @unchecked Sendable {
    case changed(CKRecord)
    case deleted(CKRecord.ID)
    case tokenUpdated(CKServerChangeToken)
}
