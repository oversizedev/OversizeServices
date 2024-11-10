//
// Copyright © 2022 Alexander Romanov
// BodyMassService.swift
//

import Foundation
#if canImport(HealthKit)
    import HealthKit
#endif
import OversizeCore
import OversizeModels

#if !os(tvOS)
    @available(iOS 15, macOS 13.0, *)
    public protocol BodyMassServiceProtocol {
        func requestAuthorization() async -> Result<Bool, AppError>
        func fetchBodyMass() async throws -> HKStatisticsCollection?
        func calculateSteps(completion: @Sendable @escaping (HKStatisticsCollection?) -> Void)
        func getWeightData(forDay days: Int, completion: @Sendable @escaping (_ weight: Double?, _ date: Date?) -> Void)
        func fetchBodyMass(forDay days: Int) async throws -> [HKQuantitySample]?
        func saveMass(date: Date, bodyMass: Double, unit: HKUnit) async throws
        func saveBodyMass(date: Date, bodyMass: Double, unit: HKUnit) async throws -> HKQuantitySample
        func deleteBodyMass(userWeightUUID: UUID) async throws -> Bool
    }

    @available(iOS 15, macOS 13.0, *)
    open class BodyMassService: @unchecked Sendable {
        private var healthStore: HKHealthStore?

        private let bodyMassType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)

        private var query: HKStatisticsCollectionQuery?

        public init() {
            if HKHealthStore.isHealthDataAvailable() {
                healthStore = HKHealthStore()
            }
        }
    }

    @available(iOS 15, macOS 13.0, *)
    extension BodyMassService: BodyMassServiceProtocol {
        public func requestAuthorization() async -> Result<Bool, AppError> {
            guard let healthStore, let type = bodyMassType else { return .failure(AppError.custom(title: "Not authorization")) }

            do {
                try await healthStore.requestAuthorization(toShare: [type], read: [type])
                return .success(true)
            } catch {
                return .failure(AppError.custom(title: "Not get"))
            }
        }

        public func getWeightData(forDay days: Int, completion: @Sendable @escaping (_ weight: Double?, _ date: Date?) -> Void) {
            guard let bodyMassType = HKObjectType.quantityType(forIdentifier: .bodyMass) else {
                return
            }

            let now: Date = .init()
            let startDate = Calendar.current.date(byAdding: DateComponents(day: -days), to: now)!

            var interval = DateComponents()
            interval.day = 1

            var anchorComponents = Calendar.current.dateComponents([.day, .month, .year], from: now)
            anchorComponents.hour = 0
            let anchorDate = Calendar.current.date(from: anchorComponents)!

            let query = HKStatisticsCollectionQuery(quantityType: bodyMassType,
                                                    quantitySamplePredicate: nil,
                                                    options: [.discreteMax, .separateBySource],
                                                    anchorDate: anchorDate,
                                                    intervalComponents: interval)
            query.initialResultsHandler = { _, results, _ in
                guard let results else {
                    return
                }

                results.enumerateStatistics(from: startDate, to: now) { statistics, _ in
                    if let sum = statistics.maximumQuantity() {
                        let bodyMassValue = sum.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                        completion(bodyMassValue, statistics.startDate)
                        return
                    }
                }
            }
            healthStore?.execute(query)
        }

        public func fetchBodyMass(forDay days: Int) async throws -> [HKQuantitySample]? {
            try await withCheckedThrowingContinuation { continuation in
                let sampleType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)

                let today: Date = .init()
                let startDate = Calendar.current.date(byAdding: DateComponents(day: -days), to: today)!

                let predicate = HKQuery.predicateForSamples(withStart: startDate, end: today, options: HKQueryOptions.strictEndDate)

                let query = HKSampleQuery(sampleType: sampleType!,
                                          predicate: predicate,
                                          limit: HKObjectQueryNoLimit,
                                          sortDescriptors: nil)
                { _, results, _ in

                    if let samples = results as? [HKQuantitySample] {
                        continuation.resume(returning: samples)
                    } else {
                        continuation.resume(returning: nil)
                    }
                }
                healthStore?.execute(query)
            }
        }

        private func queryHealthKit(forDay days: Int) async throws -> [HKSample]? {
            try await withCheckedThrowingContinuation { continuation in
                let sampleType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)

                let today: Date = .init()
                let startDate = Calendar.current.date(byAdding: DateComponents(day: -days), to: today)!

                let predicate = HKQuery.predicateForSamples(withStart: startDate, end: today, options: HKQueryOptions.strictEndDate)

                let query = HKSampleQuery(sampleType: sampleType!,
                                          predicate: predicate,
                                          limit: HKObjectQueryNoLimit,
                                          sortDescriptors: nil)
                { _, results, error in

                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: results)
                    }
                }
                healthStore?.execute(query)
            }
        }

        public func currentBodyMass() async throws -> Double? {
            guard let healthStore else {
                throw HKError(.errorHealthDataUnavailable)
            }

            let sort = NSSortDescriptor(
                key: HKSampleSortIdentifierStartDate,
                ascending: false
            )

            return try await withCheckedThrowingContinuation { continuation in

                let query = HKSampleQuery(
                    sampleType: bodyMassType!,
                    predicate: nil,
                    limit: 1,
                    sortDescriptors: [sort]
                ) { _, samples, _ in

                    guard let latest = samples?.first as? HKQuantitySample else {
                        continuation.resume(returning: nil)
                        return
                    }

                    let pounds = latest.quantity.doubleValue(for: .pound())
                    continuation.resume(returning: pounds)
                }

                healthStore.execute(query)
            }
        }

        public func calculateSteps(completion: @Sendable @escaping (HKStatisticsCollection?) -> Void) {
            let stepType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!

            let startDate = Calendar.current.date(byAdding: .day, value: -100, to: Date())

            let anchorDate = Date.mondayAt12AM()

            let daily: DateComponents = .init(day: 1)

            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)

            query = HKStatisticsCollectionQuery(quantityType: stepType, quantitySamplePredicate: predicate, anchorDate: anchorDate, intervalComponents: daily)

            query!.initialResultsHandler = { _, statisticsCollection, _ in
                completion(statisticsCollection)
            }

            if let healthStore, let query {
                healthStore.execute(query)
            }
        }

        func save(_ sample: HKSample) async throws {
            guard let healthStore else {
                throw HKError(.errorHealthDataUnavailable)
            }

            let _: Bool = try await withCheckedThrowingContinuation {
                continuation in

                healthStore.save(sample) { _, error in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }

                    continuation.resume(returning: true)
                }
            }
        }

        public func deleteBodyMass(userWeightUUID: UUID) async throws -> Bool {
            try await withCheckedThrowingContinuation { continuation in

                let sampleType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)
                let predicate = HKQuery.predicateForObject(with: userWeightUUID)

                let query = HKSampleQuery(sampleType: sampleType!,
                                          predicate: predicate,
                                          limit: 1,
                                          sortDescriptors: nil)
                { _, results, error in

                    if let error {
                        continuation.resume(throwing: error)
                    } else if let deleteObject = results?.first {
                        self.healthStore?.delete(deleteObject, withCompletion: { _, error in
                            if let error {
                                continuation.resume(throwing: error)
                            } else {
                                continuation.resume(returning: true)
                            }
                        })
                    } else {
                        continuation.resume(returning: false)
                    }
                }
                healthStore?.execute(query)
            }
        }

        public func saveMass(date: Date, bodyMass: Double, unit: HKUnit) async throws {
            guard let healthStore else {
                throw HKError(.errorHealthDataUnavailable)
            }

            let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)

            let bodyMass = HKQuantitySample(type: quantityType!,
                                            quantity: HKQuantity(unit: unit, doubleValue: bodyMass),
                                            start: date,
                                            end: date)

            let _: Bool = try await withCheckedThrowingContinuation {
                continuation in

                healthStore.save(bodyMass) { _, error in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }
                    continuation.resume(returning: true)
                }
            }
        }

        public func saveBodyMass(date: Date, bodyMass: Double, unit: HKUnit) async throws -> HKQuantitySample {
            guard let healthStore else {
                throw HKError(.errorHealthDataUnavailable)
            }

            let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)

            let bodyMass = HKQuantitySample(type: quantityType!,
                                            quantity: HKQuantity(unit: unit, doubleValue: bodyMass),
                                            start: date,
                                            end: date)

            return try await withCheckedThrowingContinuation { continuation in

                healthStore.save(bodyMass) { _, error in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }
                    continuation.resume(returning: bodyMass)
                }
            }
        }

        public func fetchBodyMass() async throws -> HKStatisticsCollection? {
            guard let healthStore else {
                throw HKError(.errorHealthDataUnavailable)
            }

            let stepType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!

            let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())

            let anchorDate = Date.mondayAt12AM()

            let daily: DateComponents = .init(day: 1)

            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)

            return try await withCheckedThrowingContinuation { continuation in

                let query = HKStatisticsCollectionQuery(quantityType: stepType,
                                                        quantitySamplePredicate: predicate,
                                                        options: .mostRecent,
                                                        anchorDate: anchorDate,
                                                        intervalComponents: daily)

                query.initialResultsHandler = { _, statisticsCollection, _ in

                    continuation.resume(returning: statisticsCollection)
                }

                healthStore.execute(query)
            }
        }
    }

    extension Date {
        static func mondayAt12AM() -> Date {
            Calendar(identifier: .iso8601).date(from: Calendar(identifier: .iso8601).dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        }
    }
#endif
