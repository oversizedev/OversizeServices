//
// Copyright © 2024 Alexander Romanov
// BloodPressureService.swift, created on 24.03.2024
//

import Foundation
import HealthKit
import OversizeCore
import OversizeModels

public class BloodPressureService {
    private var healthStore: HKHealthStore?
    private let bloodPressureType = HKQuantityType.correlationType(forIdentifier: HKCorrelationTypeIdentifier.bloodPressure)
    private let bloodPressureSystolicType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureSystolic)
    private let bloodPressureDiastolicType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureDiastolic)
    private let heartRateType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)

    public init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        }
    }
}

public extension BloodPressureService {
    func requestAuthorization() async -> Result<Bool, AppError> {
        guard let healthStore,
              let bloodPressureSystolicType,
              let bloodPressureDiastolicType,
              let heartRateType
        else { return .failure(AppError.healthKit(type: .notAccess)) }

        do {
            try await healthStore.requestAuthorization(
                toShare: [
                    bloodPressureSystolicType,
                    bloodPressureDiastolicType,
                    heartRateType,
                ],
                read: [
                    bloodPressureSystolicType,
                    bloodPressureDiastolicType,
                    heartRateType,
                ]
            )
            return .success(true)
        } catch {
            return .failure(AppError.healthKit(type: .notAccess))
        }
    }

    func fetchBloodPressure(startDate: Date, endDate: Date = Date()) async -> Result<[(UUID, Double, Double, Date)], AppError> {
        guard let bloodPressureType, let bloodPressureSystolicType, let bloodPressureDiastolicType else { return .failure(AppError.healthKit(type: .fetchItems)) }
        let result = await fetchCorrelation(startDate: startDate, endDate: endDate, type: bloodPressureType)
        switch result {
        case let .success(data):
            var resultItems: [(UUID, Double, Double, Date)] = []
            for correlation in data {
                if let sisData = correlation.objects(for: bloodPressureSystolicType).first as? HKQuantitySample,
                   let diaData = correlation.objects(for: bloodPressureDiastolicType).first as? HKQuantitySample
                {
                    resultItems.append((
                        correlation.uuid,
                        sisData.quantity.doubleValue(for: HKUnit.millimeterOfMercury()),
                        diaData.quantity.doubleValue(for: HKUnit.millimeterOfMercury()),
                        correlation.endDate
                    ))
                }
            }
            return .success(resultItems)
        case let .failure(error):
            return .failure(error)
        }
    }

    func fetchBloodPressureObjectById(uuid: UUID) async -> Result<HKObject, AppError> {
        guard let bloodPressureType else { return .failure(AppError.healthKit(type: .fetchItems)) }
        return await fetchCorrelationById(uuid: uuid, type: bloodPressureType)
    }

    func deleteBloodPressure(uuid: UUID) async -> Result<HKObject, AppError> {
        let result = await fetchBloodPressureObjectById(uuid: uuid)
        switch result {
        case let .success(object):
            return await deleteObject(object)
        case let .failure(error):
            return .failure(error)
        }
    }

    func replaceBloodPressure(uuid: UUID, systolic: Int, diastolic: Int, date: Date) async -> Result<HKCorrelation, AppError> {
        let result = await fetchBloodPressureObjectById(uuid: uuid)
        switch result {
        case let .success(object):
            let deleteResult = await deleteObject(object)
            switch deleteResult {
            case .success:
                return await saveBloodPressure(systolic: systolic, diastolic: diastolic, date: date)
            case .failure:
                return .failure(AppError.healthKit(type: .updateItem))
            }
        case .failure:
            return .failure(AppError.healthKit(type: .updateItem))
        }
    }

    func replaceBloodPressure(bpUuid: UUID, hrUuid: UUID, systolic: Int, diastolic: Int, heartRate: Int, date: Date) async -> Result<(HKCorrelation, HKQuantitySample), AppError> {
        let resultBloodPressureObject = await fetchBloodPressureObjectById(uuid: bpUuid)
        let resultHeartRateObject = await fetchHeartRateObjectById(uuid: hrUuid)
        if case let .success(bloodPressureObject) = resultBloodPressureObject, case let .success(heartRateObject) = resultHeartRateObject {
            let deleteResult = await deleteObjects([bloodPressureObject, heartRateObject])
            switch deleteResult {
            case .success:
                return await saveBloodPressure(systolic: systolic, diastolic: diastolic, heartRate: heartRate, date: date)
            case .failure:
                return .failure(AppError.healthKit(type: .updateItem))
            }
        } else {
            return .failure(AppError.healthKit(type: .updateItem))
        }
    }

    func saveBloodPressure(systolic: Int, diastolic: Int, date: Date = Date()) async -> Result<HKCorrelation, AppError> {
        guard let bloodPressureType,
              let bloodPressureSystolicType,
              let bloodPressureDiastolicType
        else { return .failure(AppError.healthKit(type: .savingItem)) }

        let unit = HKUnit.millimeterOfMercury()

        let systolicQuantity = HKQuantity(unit: unit, doubleValue: Double(systolic))
        let diastolicQuantity = HKQuantity(unit: unit, doubleValue: Double(diastolic))

        let systolicSample = HKQuantitySample(type: bloodPressureSystolicType, quantity: systolicQuantity, start: date, end: date)
        let diastolicSample = HKQuantitySample(type: bloodPressureDiastolicType, quantity: diastolicQuantity, start: date, end: date)

        let objects: Set<HKSample> = [systolicSample, diastolicSample]
        let correlation = HKCorrelation(type: bloodPressureType, start: date, end: date, objects: objects)

        return await saveCorrelation(correlation)
    }

    func saveBloodPressure(systolic: Int, diastolic: Int, heartRate: Int, date: Date = Date()) async -> Result<(HKCorrelation, HKQuantitySample), AppError> {
        guard let bloodPressureType,
              let bloodPressureSystolicType,
              let bloodPressureDiastolicType,
              let heartRateType
        else {
            return .failure(AppError.healthKit(type: .savingItem))
        }

        let unit = HKUnit.millimeterOfMercury()

        let systolicQuantity = HKQuantity(unit: unit, doubleValue: Double(systolic))
        let diastolicQuantity = HKQuantity(unit: unit, doubleValue: Double(diastolic))

        let systolicSample = HKQuantitySample(type: bloodPressureSystolicType, quantity: systolicQuantity, start: date, end: date)
        let diastolicSample = HKQuantitySample(type: bloodPressureDiastolicType, quantity: diastolicQuantity, start: date, end: date)

        let objects: Set<HKSample> = [systolicSample, diastolicSample]
        let correlation = HKCorrelation(type: bloodPressureType, start: date, end: date, objects: objects)

        let beatsCountUnit = HKUnit.count()
        let heartRateQuantity = HKQuantity(unit: beatsCountUnit.unitDivided(by: HKUnit.minute()), doubleValue: Double(heartRate))
        let heartRateSample = HKQuantitySample(type: heartRateType, quantity: heartRateQuantity, start: date, end: date)

        let result = await saveObjects([correlation, heartRateSample])
        switch result {
        case .success:
            return .success((correlation, heartRateSample))
        case let .failure(error):
            return .failure(error)
        }
    }

    func saveHeartRate(value: Int, date: Date) async -> Result<HKQuantitySample, AppError> {
        guard let heartRateType else { return .failure(AppError.healthKit(type: .savingItem)) }
        let beatsCountUnit = HKUnit.count()
        let heartRateQuantity = HKQuantity(unit: beatsCountUnit.unitDivided(by: HKUnit.minute()), doubleValue: Double(value))
        let heartRateSample = HKQuantitySample(type: heartRateType, quantity: heartRateQuantity, start: date, end: date)
        return await saveQuantitySample(heartRateSample)
    }

    func fetcHeartRate(startDate: Date, endDate: Date = Date()) async throws -> Result<[(UUID, Double, Date)], AppError> {
        let result = await fetchHeartRateSample(startDate: startDate, endDate: endDate)
        switch result {
        case let .success(samples):
            let data = samples.compactMap { ($0.uuid, $0.quantity.doubleValue(for: HKUnit.minute()), $0.endDate) }
            return .success(data)
        case let .failure(error):
            return .failure(error)
        }
    }

    func fetchHeartRateSample(startDate: Date, endDate: Date = Date()) async -> Result<[HKQuantitySample], AppError> {
        guard let heartRateType else { return .failure(.healthKit(type: .fetchItems)) }
        return await fetchHKQuantitySample(startDate: startDate, endDate: endDate, type: heartRateType)
    }

    func fetchHeartRateObjectById(uuid: UUID) async -> Result<HKObject, AppError> {
        guard let heartRateType else { return .failure(AppError.healthKit(type: .fetchItems)) }
        return await fetchObjectById(uuid: uuid, type: heartRateType)
    }

    func deleteHeartRate(uuid: UUID) async -> Result<HKObject, AppError> {
        let result = await fetchHeartRateObjectById(uuid: uuid)
        switch result {
        case let .success(object):
            return await deleteObject(object)
        case let .failure(error):
            return .failure(error)
        }
    }

    func replaceHeartRate(uuid: UUID, value: Int, date: Date) async -> Result<HKQuantitySample, AppError> {
        let result = await fetchHeartRateObjectById(uuid: uuid)
        switch result {
        case let .success(object):
            let deleteResult = await deleteObject(object)
            switch deleteResult {
            case .success:
                return await saveHeartRate(value: value, date: date)
            case .failure:
                return .failure(AppError.healthKit(type: .updateItem))
            }
        case .failure:
            return .failure(AppError.healthKit(type: .updateItem))
        }
    }

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
