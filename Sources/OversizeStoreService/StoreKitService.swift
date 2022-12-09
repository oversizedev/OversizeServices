//
// Copyright © 2022 Alexander Romanov
// StoreKitService.swift
//

import Foundation
import OversizeCore
import OversizeServices
import StoreKit

public struct StoreKitProducts {
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

public enum StoreError: Error {
    case failedVerification
}

// Define our app's subscription tiers by level of service, in ascending order.
public enum SubscriptionTier: Int, Comparable {
    case none = 0
    case monthly = 1
    case yearly = 2

    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

public final class StoreKitService: ObservableObject {
    public init() {}

    public func requestProducts() async -> Result<StoreKitProducts, AppError> {
        do {
            let productsIds = Info.store.productIdentifiers

            let storeProducts = try await Product.products(for: productsIds)

            var newNonConsumable: [Product] = []
            var newAutoRenewable: [Product] = []
            var newNonRenewables: [Product] = []
            var newConsumable: [Product] = []

            // Filter the products into categories based on their type.
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
                    // Ignore this product.
                    log("Unknown product")
                }
            }

            let products = StoreKitProducts(consumable: sortByPrice(newConsumable),
                                            nonConsumable: sortByPrice(newNonConsumable),
                                            autoRenewable: sortByPrice(newAutoRenewable),
                                            nonRenewable: sortByPrice(newNonRenewables))

            return .success(products)
            // Sort each product category by price, lowest to highest, to update the store.

        } catch {
            log("Failed product request from the App Store server: \(error)")
            return .failure(.custom(title: "Failed product request from the App Store server"))
        }
    }

    public func purchase(_ product: Product) async throws -> Result<Transaction, AppError> {
        // Begin purchasing the `Product` the user selects.
        let result = try await product.purchase()

        switch result {
        case let .success(verification):
            // Check whether the transaction is verified. If it isn't,
            // this function rethrows the verification error.
            let transaction = try checkVerified(verification)

            // Always finish a transaction.
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
            return prducts.purchasedNonRenewable.contains(product)
        case .nonConsumable:
            return prducts.purchasedNonConsumable.contains(product)
        case .autoRenewable:
            return prducts.purchasedAutoRenewable.contains(product)
        default:
            return false
        }
    }

    public func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        // Check whether the JWS passes StoreKit verification.
        switch result {
        case .unverified:
            // StoreKit parses the JWS, but it fails verification.
            throw StoreError.failedVerification
        case let .verified(safe):
            // The result is verified. Return the unwrapped value.
            return safe
        }
    }

    @MainActor
    public func updateCustomerProductStatus(products: StoreKitProducts) async -> Result<StoreKitProducts, AppError> {
        var purchasedNonConsumable: [Product] = []
        var purchasedAutoRenewable: [Product] = []
        var purchasedNonRenewable: [Product] = []

        // Iterate through all of the user's purchased products.
        for await result in Transaction.currentEntitlements {
            do {
                // Check whether the transaction is verified. If it isn’t, catch `failedVerification` error.
                let transaction = try checkVerified(result)

                // Check the `productType` of the transaction and get the corresponding product from the store.
                switch transaction.productType {
                case .nonConsumable:
                    if let nonConsumable = products.nonConsumable.first(where: { $0.id == transaction.productID }) {
                        purchasedNonConsumable.append(nonConsumable)
                    }
                case .nonRenewable:
                    if let nonRenewable = products.nonRenewable.first(where: { $0.id == transaction.productID }),
                       transaction.productID == "nonRenewing.standard"
                    {
                        // Non-renewing subscriptions have no inherent expiration date, so they're always
                        // contained in `Transaction.currentEntitlements` after the user purchases them.
                        // This app defines this non-renewing subscription's expiration date to be one year after purchase.
                        // If the current date is within one year of the `purchaseDate`, the user is still entitled to this
                        // product.
                        let currentDate: Date = .init()
                        let expirationDate = Calendar(identifier: .gregorian).date(byAdding: DateComponents(year: 1),
                                                                                   to: transaction.purchaseDate)!

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
        // Update the store information with the purchased products.
        prushedPrducts.purchasedNonConsumable = purchasedNonConsumable
        prushedPrducts.purchasedNonRenewable = purchasedNonRenewable

        // Update the store information with auto-renewable subscription products.
        prushedPrducts.purchasedAutoRenewable = purchasedAutoRenewable

        // Check the `subscriptionGroupStatus` to learn the auto-renewable subscription state to determine whether the customer
        // is new (never subscribed), active, or inactive (expired subscription). This app has only one subscription
        // group, so products in the subscriptions array all belong to the same group. The statuses that
        // `product.subscription.status` returns apply to the entire subscription group.
        prushedPrducts.subscriptionGroupStatus = try? await prushedPrducts.autoRenewable.first?.subscription?.status.first?.state

        return .success(prushedPrducts)
    }

    public func fetchPremiumStatus() async -> Bool {
        let products = await requestProducts()
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

    public func fetchPremiumAndSubscriptionsStatus() async -> (Bool?, RenewalState?) {
        let products = await requestProducts()

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
            return .yearly
        } else if productId.contains(".monthly") {
            return .monthly
        } else {
            return .none
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
        let trialTypeLabel: String
        if #available(iOS 15.4, *) {
            trialTypeLabel = paymentMode.localizedDescription
        } else {
            switch paymentMode {
            case .freeTrial:
                trialTypeLabel = "Free trial"
            case .payAsYouGo:
                trialTypeLabel = "PayAsYouGo"
            case .payUpFront:
                trialTypeLabel = "PayUpFront"
            default:
                trialTypeLabel = ""
            }
        }
        return trialTypeLabel
    }
}
