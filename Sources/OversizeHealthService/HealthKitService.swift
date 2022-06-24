//
//  HealthKitService.swift
//
//
//  Created by aromanov on 01.06.2022.


import Foundation
import HealthKit
import OversizeCraft

public protocol HealthKitServiceProtocol {
    func requestAuthorization() async -> Result<Bool, AppError>
    //func currentBodyMass() async throws -> Double?
    func fetchBodyMass() async throws -> HKStatisticsCollection?
    func calculateSteps(completion: @escaping (HKStatisticsCollection?) -> Void)
    func getWeightData(forDay days: Int, completion: @escaping ((_ weight: Double?, _ date: Date?) -> Void))
}

open class HealthKitService {

    private var healthStore: HKHealthStore?
    
    private let bodyMassType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)
    
    private var query: HKStatisticsCollectionQuery?
    
    public init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        }
    }
}

extension HealthKitService: HealthKitServiceProtocol {
    
    public func requestAuthorization() async -> Result<Bool, AppError> {

        guard let healthStore = self.healthStore, let type = self.bodyMassType else { return .failure(AppError.custom(title: "Not StoreKit")) }
        
        do {
            try await healthStore.requestAuthorization(toShare: [type], read: [type])
            return  .success(true)
        } catch {
            return  .failure(AppError.custom(title: "Not get"))
        }
    }
    
    
    public func getWeightData(forDay days: Int, completion: @escaping ((_ weight: Double?, _ date: Date?) -> Void)) {
       // Getting quantityType as stepCount
       guard let bodyMassType = HKObjectType.quantityType(forIdentifier: .bodyMass) else {
           print("*** Unable to create a bodyMass type ***")
           return
       }

       let now = Date()
       let startDate = Calendar.current.date(byAdding: DateComponents(day: -days), to: now)!

       var interval = DateComponents()
       interval.day = 1

       var anchorComponents = Calendar.current.dateComponents([.day, .month, .year], from: now)
       anchorComponents.hour = 0
       let anchorDate = Calendar.current.date(from: anchorComponents)!

       // Note to myself:: StatisticsQuery!! Nicht Collection! Option .mostRecent. Achtung, unten auch setzen!!
       let query = HKStatisticsCollectionQuery(quantityType: bodyMassType,
                                               quantitySamplePredicate: nil,
                                               options: [.mostRecent],
                                               anchorDate: anchorDate,
                                               intervalComponents: interval)
       query.initialResultsHandler = { _, results, error in
           guard let results = results else {
               print("ERROR")
               return
           }

           results.enumerateStatistics(from: startDate, to: now) { statistics, _ in
               // hier wieder .mostRecent!
               if let sum = statistics.mostRecentQuantity() {
                   let bodyMassValue = sum.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                   completion(bodyMassValue, statistics.startDate)
                   return
               }
           }
       }
        healthStore?.execute(query)
   }

    public func currentBodyMass() async throws -> Double? {
        
        guard let healthStore = healthStore else {
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
    
    public func calculateSteps(completion: @escaping (HKStatisticsCollection?) -> Void) {
        
        let stepType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
        
        let startDate = Calendar.current.date(byAdding: .day, value: -100, to: Date())
        
        let anchorDate = Date.mondayAt12AM()
        
        let daily = DateComponents(day: 1)
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        
        query = HKStatisticsCollectionQuery(quantityType: stepType, quantitySamplePredicate: predicate, anchorDate: anchorDate, intervalComponents: daily)
        
        query!.initialResultsHandler = { query, statisticsCollection, error in
            completion(statisticsCollection)
        }
        
        if let healthStore = healthStore, let query = self.query {
            healthStore.execute(query)
        }
        
    }
    
//    func waterConsumptionGraphData(completion: @escaping ([WaterGraphData]?) -> Void) throws {
//        guard let healthStore = healthStore else {
//            throw HKError(.errorHealthDataUnavailable)
//        }
//
//        // 1
//        var start = Calendar.current.date(
//            byAdding: .day, value: -6, to: Date.now
//        )!
//        start = Calendar.current.startOfDay(for: start)
//
//        let predicate = HKQuery.predicateForSamples(
//            withStart: start,
//            end: nil,
//            options: .strictStartDate
//        )
//
//        // 2
//        let query = HKStatisticsCollectionQuery(
//            quantityType: waterQuantityType,
//            quantitySamplePredicate: predicate,
//            options: .cumulativeSum,
//            anchorDate: start,
//            intervalComponents: .init(day: 1)
//        )
//
//        query.initialResultsHandler = { _, results, _ in
//          self.updateGraph(
//            start: start, results: results, completion: completion
//          )
//        }
//
//        query.statisticsUpdateHandler = { _, _, results, _ in
//          self.updateGraph(
//            start: start, results: results, completion: completion
//          )
//        }
//
//
//        healthStore.execute(query)
//    }

    
    
    public func fetchBodyMass() async throws -> HKStatisticsCollection? {

        guard let healthStore = healthStore else {
            throw HKError(.errorHealthDataUnavailable)
        }

        let stepType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!

        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())

        let anchorDate = Date.mondayAt12AM()

        let daily = DateComponents(day: 1)

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in

            let query = HKStatisticsCollectionQuery(quantityType: stepType,
                                                    quantitySamplePredicate: predicate,
                                                    options: .mostRecent,
                                                    anchorDate: anchorDate,
                                                    intervalComponents: daily)




            query.initialResultsHandler = { query, statisticsCollection, error in


                continuation.resume(returning: statisticsCollection)

            }

            healthStore.execute(query)
        }
    }
}

extension Date {
    static func mondayAt12AM() -> Date {
        return Calendar(identifier: .iso8601).date(from: Calendar(identifier: .iso8601).dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
    }
}
