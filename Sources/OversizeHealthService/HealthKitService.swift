//
// Copyright © 2024 Alexander Romanov
// HealthKitService.swift, created on 31.03.2024
//

import Foundation
import HealthKit
import OversizeCore
import OversizeModels

@available(iOS 15, macOS 13.0, *)
open class HealthKitService {
    var healthStore: HKHealthStore?

    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        }
    }
}

@available(iOS 15, macOS 13.0, *)
extension HealthKitService {
    func deleteObject(_ object: HKObject) async -> Result<HKObject, AppError> {
        await withCheckedContinuation { continuation in
            self.healthStore?.delete(object, withCompletion: { _, error in
                if error != nil {
                    continuation.resume(returning: .failure(AppError.healthKit(type: .deleteItem)))
                } else {
                    continuation.resume(returning: .success(object))
                }
            })
        }
    }

    func deleteObjects(_ objects: [HKObject]) async -> Result<[HKObject], AppError> {
        await withCheckedContinuation { continuation in
            self.healthStore?.delete(objects, withCompletion: { _, error in
                if error != nil {
                    continuation.resume(returning: .failure(AppError.healthKit(type: .deleteItem)))
                } else {
                    continuation.resume(returning: .success(objects))
                }
            })
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

    func saveQuantitySample(_ quantitySample: HKQuantitySample) async -> Result<HKQuantitySample, AppError> {
        guard let healthStore else {
            return .failure(AppError.healthKit(type: .savingItem))
        }
        return await withCheckedContinuation { continuation in
            healthStore.save(quantitySample) { _, error in
                if error != nil {
                    continuation.resume(returning: .failure(AppError.healthKit(type: .savingItem)))
                } else {
                    continuation.resume(returning: .success(quantitySample))
                }
            }
        }
    }

    func saveCorrelation(_ correlation: HKCorrelation) async -> Result<HKCorrelation, AppError> {
        guard let healthStore else {
            return .failure(AppError.healthKit(type: .savingItem))
        }
        return await withCheckedContinuation { continuation in
            healthStore.save(correlation) { _, error in
                if error != nil {
                    continuation.resume(returning: .failure(AppError.healthKit(type: .savingItem)))
                } else {
                    continuation.resume(returning: .success(correlation))
                }
            }
        }
    }

    func saveObjects(_ objects: [HKObject]) async -> Result<[HKObject], AppError> {
        guard let healthStore else {
            return .failure(AppError.healthKit(type: .savingItem))
        }
        return await withCheckedContinuation { continuation in
            healthStore.save(objects) { _, error in
                if error != nil {
                    continuation.resume(returning: .failure(AppError.healthKit(type: .savingItem)))
                } else {
                    continuation.resume(returning: .success(objects))
                }
            }
        }
    }
}
