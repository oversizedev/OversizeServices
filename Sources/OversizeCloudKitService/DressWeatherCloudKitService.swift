//
// Copyright © 2022 Alexander Romanov
// DressWeatherCloudKitService.swift
//

import CloudKit
import Foundation
import OversizeCraft

public protocol DressWeatherCloudKitServiceProtocol {
    func fetchAccountStatus() async -> Result<CKAccountStatus, AppError>
    func fetchCities() async -> Result<[WeatherCity], AppError>
    func fetchPlaces() async -> Result<[WeatherPlace], AppError>
    func fetchDresses() async -> Result<[WeatherDress], AppError>

    func deleteCity(_ recordId: CKRecord.ID) async -> Result<CKRecord.ID, AppError>
    func deletePlace(_ recordId: CKRecord.ID) async -> Result<CKRecord.ID, AppError>
    func deleteDress(_ recordId: CKRecord.ID) async -> Result<CKRecord.ID, AppError>

    func saveCity(_ city: WeatherCity) async -> Result<WeatherCity, AppError>
    // func savePlace(_ cityRecordId: CKRecord.ID, place: WeatherPlace) async -> Result<WeatherPlace, AppError>
    func savePlace(_ place: WeatherPlace) async -> Result<WeatherPlace, AppError>
    func saveDress(_ dress: WeatherDress) async -> Result<WeatherDress, AppError>
}

open class DressWeatherCloudKitService {
    private var database: CKDatabase
    private var container: CKContainer

    public init() {
        container = CKContainer(identifier: CloudKitIdentifier.dressWeather.rawValue)
        database = container.privateCloudDatabase
    }
}

@MainActor
extension DressWeatherCloudKitService: DressWeatherCloudKitServiceProtocol {
    public func fetchAccountStatus() async -> Result<CKAccountStatus, AppError> {
        do {
            let result = try await CKContainer.default().accountStatus()
            return .success(result)
        } catch {
            return .failure(.cloudKit(type: .unknown))
        }
    }

    public func deleteCity(_ recordId: CKRecord.ID) async -> Result<CKRecord.ID, AppError> {
        do {
            let result = try await database.deleteRecord(withID: recordId)
            return .success(result)
        } catch {
            return .failure(.cloudKit(type: .unknown))
        }
    }

    public func deleteDress(_ recordId: CKRecord.ID) async -> Result<CKRecord.ID, AppError> {
        do {
            let result = try await database.deleteRecord(withID: recordId)
            return .success(result)
        } catch {
            return .failure(.cloudKit(type: .unknown))
        }
    }

    public func deletePlace(_ recordId: CKRecord.ID) async -> Result<CKRecord.ID, AppError> {
        do {
            let result = try await database.deleteRecord(withID: recordId)
            return .success(result)
        } catch {
            return .failure(.cloudKit(type: .unknown))
        }
    }

    public func fetchCities() async -> Result<[WeatherCity], AppError> {
        do {
            let query = CKQuery(recordType: WeatherCity.WeatherCityRecordKeys.type.rawValue, predicate: NSPredicate(value: true))
            if #available(iOS 15.0, *) {
                let data = try await database.records(matching: query)
                let records = data.matchResults.compactMap { try? $0.1.get() }
                return .success(records.compactMap(WeatherCity.init))
            } else {
                print("🔴 Method FetchCities dont work in iOS 14")
                return .failure(.cloudKit(type: .unknown))
            }
        } catch {
            return .failure(.cloudKit(type: .unknown))
        }
    }

    public func fetchDresses() async -> Result<[WeatherDress], AppError> {
        do {
            let query = CKQuery(recordType: WeatherDress.WeatherDressRecordKeys.type.rawValue, predicate: NSPredicate(value: true))
            if #available(iOS 15.0, *) {
                let data = try await database.records(matching: query)
                let records = data.matchResults.compactMap { try? $0.1.get() }
                return .success(records.compactMap(WeatherDress.init))
            } else {
                print("🔴 Method FetchCities dont work in iOS 14")
                return .failure(.cloudKit(type: .unknown))
            }
        } catch {
            return .failure(.cloudKit(type: .unknown))
        }
    }

    // swiftformat:disable all
    public func fetchPlaces(for cityId: CKRecord.ID) async -> Result<[WeatherPlace], AppError> {
        do {
            let reference = CKRecord.Reference(recordID: cityId, action: .deleteSelf)
            let query = CKQuery(recordType: WeatherPlace.WeatherPlaceRecordKeys.type.rawValue,
                                predicate: NSPredicate(format: "\(WeatherPlace.WeatherPlaceRecordKeys.type.rawValue) == %@", reference))
            if #available(iOS 15.0, *) {
                let data = try await database.records(matching: query)
                let records = data.matchResults.compactMap { try? $0.1.get() }
                return .success(records.compactMap(WeatherPlace.init))
            } else {
                print("🔴 Method FetchCities dont work in iOS 14")
                return .failure(.cloudKit(type: .unknown))
            }
        } catch {
            return .failure(.cloudKit(type: .unknown))
        }
    }

    // swiftformat:disable all
    public func fetchPlaces() async -> Result<[WeatherPlace], AppError> {
        do {
            let query = CKQuery(recordType: WeatherPlace.WeatherPlaceRecordKeys.type.rawValue, predicate: NSPredicate(value: true))
            if #available(iOS 15.0, *) {
                let data = try await database.records(matching: query)
                let records = data.matchResults.compactMap { try? $0.1.get() }
                return .success(records.compactMap(WeatherPlace.init))
            } else {
                print("🔴 Method FetchCities dont work in iOS 14")
                return .failure(.cloudKit(type: .unknown))
            }
        } catch {
            return .failure(.cloudKit(type: .unknown))
        }
    }

    public func saveCity(_ city: WeatherCity) async -> Result<WeatherCity, AppError> {
        do {
            let result = try await database.save(city.record)
            guard let city = WeatherCity(from: result) else { return .failure(.cloudKit(type: .unknown)) }
            return .success(city)
        } catch {
            return .failure(.cloudKit(type: .unknown))
        }
    }
    
    public func saveDress(_ dress: WeatherDress) async -> Result<WeatherDress, AppError> {
        do {
            let result = try await database.save(dress.record)
            guard let dress = WeatherDress(from: result) else { return .failure(.cloudKit(type: .unknown)) }
            return .success(dress)
        } catch {
            return .failure(.cloudKit(type: .unknown))
        }
    }



    public func savePlace(_ place: WeatherPlace) async -> Result<WeatherPlace, AppError> {
        do {
            let result = try await database.save(place.record)
            guard let city = WeatherPlace(from: result) else { return .failure(.cloudKit(type: .unknown)) }
            return .success(city)
        } catch {
            return .failure(.cloudKit(type: .unknown))
        }
    }
}

//    public func savePlace(_ cityRecordId: CKRecord.ID,
//                          place: WeatherPlace) async -> Result<WeatherPlace, CloudKitError> {
//        do {
//            let record = CKRecord(recordType: place.recordType)
//            record.setValue(place.name, forKey: "name")
//            record.setValue(place.icon, forKey: "icon")
//            record.setValue(place.location, forKey: "location")
//            let cityReference = CKRecord.Reference(recordID: cityRecordId, action: .deleteSelf)
//            record.setObject(cityReference, forKey: CloudKitSheme.city.rawValue)
//            let result = try await database.save(record)
//            let place = WeatherPlace(record: result)
//            return .success(place)
//        } catch {
//            return .failure(.unknown)
//        }
//    }

/*
public func fetchCitiesWithPlaces() async -> Result<[WeatherCity], CloudKitError> {
    do {
        let query = CKQuery(recordType: CloudKitSheme.city.rawValue, predicate: NSPredicate(value: true))
        var items: [WeatherCity] = []
        if #available(iOS 15.0, *) {
            let data = try await database.records(matching: query)
            
//                let dataItems = data.matchResults.compactMap { $0.1 }
//                return await withTaskGroup(of: Void.self) { group in
//                    var cities: [WeatherCity] = []
//                    for item in dataItems {
//                        group.addTask(priority: .background) {
//
//                            if case let .success(record) = item {
//                                var city = WeatherCity(record: record)
//                                if let recordId = city.recordId {
//                                    let response = await self.fetchPlaces(for: recordId)
//                                    switch response {
//                                    case let .success(data):
//                                        city.places = data
//                                    case .failure:
//                                        break
//                                    }
//                                }
//                                //await store.append(ids: ids)
//                                await cities.append(city)
//                            }
//
//
//                        }
//                        return .success(cities)
//                    }
//                    return .success(cities)
//                }
        } else {
            print("🔴 Method FetchCities dont work in iOS 14")
        }
        return .success(items)
    } catch {
        return .failure(.unknown)
    }
}*/
