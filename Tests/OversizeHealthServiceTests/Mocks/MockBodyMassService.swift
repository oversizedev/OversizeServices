//
// Copyright © 2026 Alexander Romanov
// MockBodyMassService.swift
//

#if os(iOS) || os(macOS)
import Foundation
import HealthKit
import OversizeHealthService

@available(iOS 15, macOS 13.0, *)
final class MockBodyMassService: BodyMassServiceProtocol, @unchecked Sendable {
    private let requestAuthorizationCalls: LockedBox<Int> = .init(0)
    private let savedSamples: LockedBox<[(date: Date, bodyMass: Double)]> = .init([])

    var requestAuthorizationCallCount: Int {
        requestAuthorizationCalls.current
    }

    var savedBodyMass: [(date: Date, bodyMass: Double)] {
        savedSamples.current
    }

    func requestAuthorization() async -> Result<Bool, Error> {
        requestAuthorizationCalls.mutate { $0 += 1 }
        return .success(true)
    }

    func fetchBodyMass() async throws -> HKStatisticsCollection? {
        nil
    }

    func calculateSteps(completion: @Sendable @escaping (HKStatisticsCollection?) -> Void) {
        completion(nil)
    }

    func getWeightData(forDay _: Int, completion: @Sendable @escaping (_ weight: Double?, _ date: Date?) -> Void) {
        completion(nil, nil)
    }

    func fetchBodyMass(forDay _: Int) async throws -> [HKQuantitySample]? {
        nil
    }

    func saveMass(date: Date, bodyMass: Double, unit _: HKUnit) async throws {
        savedSamples.mutate { $0.append((date, bodyMass)) }
    }

    func saveBodyMass(date: Date, bodyMass: Double, unit: HKUnit) async throws -> HKQuantitySample {
        try await saveMass(date: date, bodyMass: bodyMass, unit: unit)
        return HKQuantitySample(
            type: HKQuantityType(.bodyMass),
            quantity: HKQuantity(unit: unit, doubleValue: bodyMass),
            start: date,
            end: date,
        )
    }

    func deleteBodyMass(userWeightUUID _: UUID) async throws -> Bool {
        true
    }
}
#endif
