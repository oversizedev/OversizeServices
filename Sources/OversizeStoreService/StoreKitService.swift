//
// Copyright © 2022 Alexander Romanov
// StoreKitService.swift
//

import Foundation
import OversizeCore
import OversizeModels
import OversizeServices
import StoreKit

public struct StoreKitProducts: Sendable {
    public var consumable: [Product] = []
    public var nonConsumable: [Product] = []
    public var autoRenewable: [Product] = []
    public var nonRenewable: [Product] = []

    public var purchasedNonConsumable: [Product] = []
    public var purchasedAutoRenewable: [Product] = []
    public var purchasedNonRenewable: [Product] = []
    public var subscriptionGroupStatus: RenewalState?
}

public typealias Transaction = StoreKit.Transaction
public typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo
public typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState

public enum StoreError: Error, Sendable {
    case failedVerification
}

public enum SubscriptionTier: Int, Comparable, Sendable {
    case none = 0
    case monthly = 1
    case yearly = 2

    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

public final class StoreKitService: Sendable {
    public func requestProducts(productIds: [String]) async -> Result<StoreKitProducts, AppError> {
        do {
            let storeProducts = try await Product.products(for: productIds)

            var newNonConsumable: [Product] = []
            var newAutoRenewable: [Product] = []
            var newNonRenewables: [Product] = []
            var newConsumable: [Product] = []

            for product in storeProducts {
                switch product.type {
                case .consumable:
                    newConsumable.append(product)
                case .nonConsumable:
                    newNonConsumable.append(product)
                case .autoRenewable:
                    newAutoRenewable.append(product)
                case .nonRenewable:
                    newNonRenewables.append(product)
                default:
                    log("Unknown product")
                }
            }

            let products = StoreKitProducts(
                consumable: sortByPrice(newConsumable),
                nonConsumable: sortByPrice(newNonConsumable),
                autoRenewable: sortByPrice(newAutoRenewable),
                nonRenewable: sortByPrice(newNonRenewables),
            )

            return .success(products)
        } catch {
            log("Failed product request from the App Store server: \(error)")
            return .failure(.custom(title: "Failed product request from the App Store server"))
        }
    }

    public func purchase(_ product: Product) async throws -> Result<Transaction, AppError> {
        let result = try await product.purchase()

        switch result {
        case let .success(verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()

            return .success(transaction)
        case .userCancelled, .pending:
            return .failure(.custom(title: "Error"))
        default:
            return .failure(.custom(title: "Error"))
        }
    }

    public func isPurchased(_ product: Product, prducts: StoreKitProducts) async throws -> Bool {
        // Determine whether the user purchases a given product.
        switch product.type {
        case .nonRenewable:
            prducts.purchasedNonRenewable.contains(product)
        case .nonConsumable:
            prducts.purchasedNonConsumable.contains(product)
        case .autoRenewable:
            prducts.purchasedAutoRenewable.contains(product)
        default:
            false
        }
    }

    public func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case let .verified(safe):
            return safe
        }
    }

    @MainActor
    public func updateCustomerProductStatus(products: StoreKitProducts) async -> Result<StoreKitProducts, AppError> {
        var purchasedNonConsumable: [Product] = []
        var purchasedAutoRenewable: [Product] = []
        var purchasedNonRenewable: [Product] = []
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                switch transaction.productType {
                case .nonConsumable:
                    if let nonConsumable = products.nonConsumable.first(where: { $0.id == transaction.productID }) {
                        purchasedNonConsumable.append(nonConsumable)
                    }
                case .nonRenewable:
                    if let nonRenewable = products.nonRenewable.first(where: { $0.id == transaction.productID }),
                       transaction.productID == "nonRenewing.standard"
                    {
                        let currentDate: Date = .init()
                        let expirationDate = Calendar(identifier: .gregorian).date(
                            byAdding: DateComponents(year: 1),
                            to: transaction.purchaseDate,
                        )!

                        if currentDate < expirationDate {
                            purchasedNonRenewable.append(nonRenewable)
                        }
                    }
                case .autoRenewable:
                    if let newAutoRenewable = products.autoRenewable.first(where: { $0.id == transaction.productID }) {
                        purchasedAutoRenewable.append(newAutoRenewable)
                    }
                default:
                    break
                }

            } catch {
                return .failure(.custom(title: error.localizedDescription))
            }
        }

        var prushedPrducts = products
        prushedPrducts.purchasedNonConsumable = purchasedNonConsumable
        prushedPrducts.purchasedNonRenewable = purchasedNonRenewable
        prushedPrducts.purchasedAutoRenewable = purchasedAutoRenewable
        prushedPrducts.subscriptionGroupStatus = try? await prushedPrducts.autoRenewable.first?.subscription?.status.first?.state

        return .success(prushedPrducts)
    }

    public func fetchPremiumStatus(productIds: [String]) async -> Bool {
        let products = await requestProducts(productIds: productIds)
        switch products {
        case let .success(preProducts):
            let result = await updateCustomerProductStatus(products: preProducts)
            switch result {
            case let .success(finalProducts):
                if !finalProducts.purchasedAutoRenewable.isEmpty || !finalProducts.purchasedNonRenewable.isEmpty {
                    return true
                } else {
                    return false
                }
            case .failure:
                return false
            }
        case .failure:
            return false
        }
    }

    public func fetchPremiumAndSubscriptionsStatus(productIds: [String]) async -> (Bool?, RenewalState?) {
        let products = await requestProducts(productIds: productIds)

        switch products {
        case let .success(preProducts):
            let result = await updateCustomerProductStatus(products: preProducts)
            switch result {
            case let .success(finalProducts):
                if !finalProducts.purchasedAutoRenewable.isEmpty || !finalProducts.purchasedNonConsumable.isEmpty {
                    return (true, finalProducts.subscriptionGroupStatus)
                } else {
                    return (false, finalProducts.subscriptionGroupStatus)
                }
            case .failure:
                return (nil, nil)
            }

        case .failure:
            return (nil, nil)
        }
    }

    public func sortByPrice(_ products: [Product]) -> [Product] {
        products.sorted(by: { $0.price < $1.price })
    }

    // Get a subscription's level of service using the product ID.
    public func tier(for productId: String) -> SubscriptionTier {
        if productId.contains(".yearly") {
            .yearly
        } else if productId.contains(".monthly") {
            .monthly
        } else {
            .none
        }
    }

    public func periodLabel(_ value: Int, unit: Product.SubscriptionPeriod.Unit) -> String {
        let text: String
        let plural = value > 1
        switch unit {
        case .day:
            text = plural ? "\(value) days" : "day"
        case .week:
            text = plural ? "\(value) weeks" : "week"
        case .month:
            text = plural ? "\(value) months" : "month"
        case .year:
            text = plural ? "\(value) years" : "year"
        @unknown default:
            text = "period"
        }
        return text
    }

    public func daysLabel(_ value: Int, unit: Product.SubscriptionPeriod.Unit) -> String {
        let text: String
        let plural = value > 1
        switch unit {
        case .day:
            text = plural ? "\(value) days" : "day"
        case .week:
            text = "\(value * 7) days"
        case .month:
            text = "\(value * 30) days"
        case .year:
            text = "\(value * 366) days"
        @unknown default:
            text = "period"
        }
        return text
    }

    public func paymentTypeLabel(paymentMode: Product.SubscriptionOffer.PaymentMode) -> String {
        let trialTypeLabel: String = if #available(iOS 15.4, macOS 12.3, tvOS 15.4, *) {
            paymentMode.localizedDescription
        } else {
            switch paymentMode {
            case .freeTrial:
                "Free trial"
            case .payAsYouGo:
                "PayAsYouGo"
            case .payUpFront:
                "PayUpFront"
            default:
                ""
            }
        }
        return trialTypeLabel
    }

    public func salePercent(product: Product, products: StoreKitProducts) -> Decimal {
        if let monthSubscriptionProduct = products.autoRenewable.first(where: { $0.subscription?.subscriptionPeriod.unit == .month }) {
            let yearPriceMonthly = monthSubscriptionProduct.price * 12
            let procent = (yearPriceMonthly - product.price) / yearPriceMonthly
            return (procent * 100).rounded(0)
        } else {
            return 0
        }
    }
}
