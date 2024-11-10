//
// Copyright © 2024 Alexander Romanov
// HealthKitService.swift, created on 31.03.2024
//

import Foundation
#if canImport(HealthKit)
    import HealthKit
#endif
import OversizeCore
import OversizeModels

#if os(iOS) || os(macOS)
    @available(iOS 15, macOS 13.0, *)
    open class HealthKitService: @unchecked Sendable {
        var healthStore: HKHealthStore?

        init() {
            if HKHealthStore.isHealthDataAvailable() {
                healthStore = HKHealthStore()
            }
        }
    }

    @available(iOS 15, macOS 13.0, *)
    extension HealthKitService {
        func saveQuantitySample(_ quantitySample: HKQuantitySample) async -> Result<HKQuantitySample, AppError> {
            guard let healthStore else {
                return .failure(AppError.healthKit(type: .savingItem))
            }
            do {
                try await healthStore.save(quantitySample)
                return .success(quantitySample)
            } catch {
                return .failure(AppError.healthKit(type: .savingItem))
            }
        }

        func saveCorrelation(_ correlation: HKCorrelation) async -> Result<HKCorrelation, AppError> {
            guard let healthStore else {
                return .failure(AppError.healthKit(type: .savingItem))
            }
            do {
                try await healthStore.save(correlation)
                return .success(correlation)
            } catch {
                return .failure(AppError.healthKit(type: .savingItem))
            }
        }

        func saveObjects(_ objects: [HKObject]) async -> Result<[HKObject], AppError> {
            do {
                let _ = try await healthStore?.save(objects)
                return .success(objects)
            } catch {
                return .failure(.healthKit(type: .deleteItem))
            }
        }

        func fetchObjectById(uuid: UUID, type: HKQuantityType) async -> Result<HKObject, AppError> {
            await withCheckedContinuation { continuation in
                let predicate = HKQuery.predicateForObject(with: uuid)
                let query = HKSampleQuery(
                    sampleType: type,
                    predicate: predicate,
                    limit: 1,
                    sortDescriptors: nil
                ) { _, results, error in
                    if error != nil {
                        continuation.resume(returning: .failure(AppError.healthKit(type: .fetchItems)))
                    } else if let item = results?.first {
                        return continuation.resume(returning: .success(item))
                    } else {
                        continuation.resume(returning: .failure(AppError.healthKit(type: .fetchItems)))
                    }
                }
                healthStore?.execute(query)
            }
        }

        func fetchHKQuantitySample(startDate: Date, endDate: Date = Date(), type: HKQuantityType) async -> Result<[HKQuantitySample], AppError> {
            await withCheckedContinuation { continuation in

                let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions.strictEndDate)

                let query = HKSampleQuery(
                    sampleType: type,
                    predicate: predicate,
                    limit: HKObjectQueryNoLimit,
                    sortDescriptors: nil
                ) { _, results, _ in

                    if let samples = results as? [HKQuantitySample] {
                        continuation.resume(returning: .success(samples))
                    } else {
                        continuation.resume(returning: .failure(.healthKit(type: .fetchItems)))
                    }
                }
                healthStore?.execute(query)
            }
        }

        func fetchCorrelation(startDate: Date, endDate: Date = Date(), type: HKCorrelationType) async -> Result<[HKCorrelation], AppError> {
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions.strictEndDate)
            return await withCheckedContinuation { continuation in
                let query = HKSampleQuery(
                    sampleType: type,
                    predicate: predicate,
                    limit: HKObjectQueryNoLimit,
                    sortDescriptors: nil
                ) { _, results, _ in

                    if let samples = results as? [HKCorrelation] {
                        continuation.resume(returning: .success(samples))
                    } else {
                        continuation.resume(returning: .failure(AppError.healthKit(type: .fetchItems)))
                    }
                }
                healthStore?.execute(query)
            }
        }

        func fetchCorrelationById(uuid: UUID, type: HKCorrelationType) async -> Result<HKObject, AppError> {
            await withCheckedContinuation { continuation in
                let predicate = HKQuery.predicateForObject(with: uuid)
                let query = HKSampleQuery(
                    sampleType: type,
                    predicate: predicate,
                    limit: 1,
                    sortDescriptors: nil
                ) { _, results, error in
                    if error != nil {
                        continuation.resume(returning: .failure(AppError.healthKit(type: .fetchItems)))
                    } else if let item = results?.first {
                        return continuation.resume(returning: .success(item))
                    } else {
                        continuation.resume(returning: .failure(AppError.healthKit(type: .fetchItems)))
                    }
                }
                healthStore?.execute(query)
            }
        }

        func delete(type: HKObjectType, syncId: UUID) async -> Result<Bool, AppError> {
            let predicate = HKQuery.predicateForObjects(
                withMetadataKey: HKMetadataKeySyncIdentifier,
                allowedValues: [syncId.uuidString]
            )
            do {
                let _ = try await healthStore?.deleteObjects(of: type, predicate: predicate)
                return .success(true)
            } catch {
                return .failure(.healthKit(type: .deleteItem))
            }
        }

        func deleteObject(_ object: HKObject) async -> Result<HKObject, AppError> {
            guard let healthStore else {
                return .failure(AppError.healthKit(type: .deleteItem))
            }
            do {
                try await healthStore.delete(object)
                return .success(object)
            } catch {
                return .failure(AppError.healthKit(type: .deleteItem))
            }
        }


        func deleteObjects(_ objects: [HKObject]) async -> Result<[HKObject], AppError> {
            guard let healthStore else {
                return .failure(AppError.healthKit(type: .deleteItem))
            }
            do {
                try await healthStore.delete(objects)
                return .success(objects)
            } catch {
                return .failure(AppError.healthKit(type: .deleteItem))
            }
        }
    }
#endif
