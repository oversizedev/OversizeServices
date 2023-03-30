//
// Copyright © 2022 Alexander Romanov
// AssetsCloudKitService.swift
//

import CloudKit
import Foundation
import OversizeServices
import SwiftUI
import UIKit

public final class AssetsCloudKitService {
    private var database: CKDatabase
    private var container: CKContainer

    public init() {
        container = CKContainer(identifier: CloudKitIdentifier.dressWeather.rawValue)
        database = container.publicCloudDatabase
    }
}

public extension AssetsCloudKitService {
    func saveIcon(name: String, image _: URL? = nil) async -> Result<Bool, AppError> {
        guard let path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("\(name).svg") else { return .failure(.cloudKit(type: .unknown)) }
        do {
            let record = CKRecord(recordType: "AssetIcon")
            record.setValue(name, forKey: "name")

            let svg = URL(string: "https://openclipart.org/download/181651/manhammock.svg")!
            let data = try? Data(contentsOf: svg)

            try data!.write(to: path)
            let asset = CKAsset(fileURL: path)
            record.setValue(asset, forKey: "icon")

            _ = try await database.save(record)
            return .success(true)
        } catch {
            return .failure(.cloudKit(type: .unknown))
        }
    }

    func fetchIcons() async -> Result<[AssetIcon], AppError> {
        do {
            let query = CKQuery(recordType: "AssetIcon", predicate: NSPredicate(value: true))
            if #available(iOS 15.0, *) {
                let data = try await database.records(matching: query)
                let records = data.matchResults.compactMap { try? $0.1.get() }

                var icons = [AssetIcon]()

                for record in records {
                    let name = record["name"] as! String
                    let asset = record["icon"] as? CKAsset
                    let url = asset?.fileURL
                    let assetIcon = AssetIcon(name: name, imageUrl: url)
                    icons.append(assetIcon)
                }
                return .success(icons)
            } else {
                print("🔴 Method FetchCities dont work in iOS 14")
                return .failure(.cloudKit(type: .unknown))
            }
        } catch {
            return .failure(.cloudKit(type: .unknown))
        }
    }
}
