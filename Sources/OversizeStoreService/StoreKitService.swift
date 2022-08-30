//
// Copyright © 2022 Alexander Romanov
// StoreKitService.swift
//

import Foundation
import OversizeServices
import OversizeSettingsService
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
            // Request products from the App Store using the identifiers that the Products.plist file defines.

            let productsIds = ["romanov.cc.ScaleDown.lifetime", "romanov.cc.ScaleDown.monthly", "romanov.cc.ScaleDown.yearly"] // AppInfoService.productIdentifiers

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
                    print("Unknown product")
                }
            }

            let products = StoreKitProducts(consumable: sortByPrice(newConsumable),
                                            nonConsumable: sortByPrice(newNonConsumable),
                                            autoRenewable: sortByPrice(newAutoRenewable),
                                            nonRenewable: sortByPrice(newNonRenewables))

            return .success(products)
            // Sort each product category by price, lowest to highest, to update the store.

        } catch {
            print("Failed product request from the App Store server: \(error)")
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
                        let currentDate = Date()
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
                print("Purchased AutoRenewable: \(finalProducts.purchasedAutoRenewable.count)")
                print("Purchased NonConsumable: \(finalProducts.nonConsumable.count)")
                print("Purchased NonRenewable: \(finalProducts.purchasedNonRenewable.count)")
                if #available(iOS 15.4, *) {
                    print("SubscriptionGroupStatus: \(String(describing: finalProducts.subscriptionGroupStatus?.localizedDescription))")
                } else {
                    // Fallback on earlier versions
                }
                if finalProducts.subscriptionGroupStatus == .subscribed {
                    print("subscriptionGroupStatus == .subscribed")
                }

                if !finalProducts.purchasedAutoRenewable.isEmpty || !finalProducts.purchasedNonRenewable.isEmpty {
                    return true
                } else {
                    return false
//                    if let subscriptionGroupStatus = finalProducts.subscriptionGroupStatus {
//                        if subscriptionGroupStatus == .expired || subscriptionGroupStatus == .revoked {
//                            false
//                        } else if subscriptionGroupStatus == .inBillingRetryPeriod {
//                            //The best practice for subscriptions in the billing retry state is to provide a deep link
//                            //from your app to https://apps.apple.com/account/billing.
//                            //Text("Please verify your billing details.")
//                            return false
//                        }
//                    } else {
//                        return false
//                        //Text("You don't own any subscriptions. \nHead over to the shop to get started!")
//                    }
                }
            case let .failure(error):
                return false
            }

        case let .failure(error):
            return false
        }
    }

    public func sortByPrice(_ products: [Product]) -> [Product] {
        products.sorted(by: { $0.price < $1.price })
    }

    // Get a subscription's level of service using the product ID.
    public func tier(for productId: String) -> SubscriptionTier {
        switch productId {
        case "romanov.cc.ScaleDown.monthly":
            return .monthly
        case "romanov.cc.ScaleDown.yearly":
            return .yearly
        default:
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

public extension Product {
    var displayMonthsCount: String {
        switch type {
        case .autoRenewable, .nonRenewable:
            if let subscription = subscription {
                switch subscription.subscriptionPeriod.unit {
                case .day:
                    return "\(subscription.subscriptionPeriod.value)"
                case .week:
                    return "\(subscription.subscriptionPeriod.value)"
                case .month:
                    return "\(subscription.subscriptionPeriod.value)"
                case .year:
                    return "\(subscription.subscriptionPeriod.value * 12)"
                @unknown default:
                    return "-"
                }
            }
        case .nonConsumable:
            return "∞"
        default:
            return "-"
        }
        return "-"
    }
}

public extension Product {
    var displayMonthPrice: String {
        switch type {
        case .autoRenewable, .nonRenewable:
            if let subscription = subscription {
                switch subscription.subscriptionPeriod.unit {
                case .day:
                    return "\((price * 30).rounded(2))"
                case .week:
                    return "\((price * 4).rounded(2))"
                case .month:
                    return "\(price)"
                case .year:
                    return "\((price / 12).rounded(2))"
                @unknown default:
                    return "-"
                }
            }
        case .nonConsumable, .consumable:
            return "Forever"
        default:
            return ""
        }
        return "-"
    }
}

public extension Product {
    var perMonthLabel: String {
        if displayPrice.count < 6 {
            return " / month"
        } else {
            return " / mo"
        }
    }

    var perYearLabel: String {
        if displayPrice.count < 6 {
            return " / month"
        } else {
            return " / mo"
        }
    }
}

public extension Product {
    var displayMonthPricePeriod: String {
        switch type {
        case .autoRenewable, .nonRenewable:
            return " / month"
        default:
            return ""
        }
    }
}

public extension Product {
    var displayMonthsCountDescription: String {
        switch type {
        case .autoRenewable, .nonRenewable:
            if let subscription = subscription {
                switch subscription.subscriptionPeriod.unit {
                case .day:
                    return "Day"
                case .week:
                    return "Week"
                case .month:
                    return "Month"
                case .year:
                    return "Months"
                @unknown default:
                    return "-"
                }
            }
        case .nonConsumable:
            return "Lifetime"
        default:
            return "-"
        }
        return "-"
    }
}

public extension Product {
    var displayPriceWithPeriod: String {
        var price = displayPrice
        if let unit = subscription?.subscriptionPeriod.unit {
            if #available(iOS 15.4, *) {
                price = self.displayPrice + " / " + unit.localizedDescription.lowercased()
            } else {
                switch unit {
                case .day:
                    price = displayPrice + " / day"
                case .week:
                    price = displayPrice + " / week"
                case .month:
                    price = displayPrice + " / month"
                case .year:
                    price = displayPrice + " / year"
                @unknown default:
                    price = displayPrice + " / -"
                }
            }
        }
        return price
    }
}

public extension Product {
    var displayCurrency: String {
        let courency: String = displayPrice.components(separatedBy: .decimalDigits).joined()
        return courency.trimmingCharacters(in: .punctuationCharacters)
    }
}

public extension Product {
    var displayPeriod: String {
        var period = ""
        if let unit = subscription?.subscriptionPeriod.unit {
            if #available(iOS 15.4, *) {
                period = " / " + unit.localizedDescription.lowercased()
            } else {
                switch unit {
                case .day:
                    period = " / day"
                case .week:
                    period = " / week"
                case .month:
                    period = " / month"
                case .year:
                    period = " / year"
                @unknown default:
                    period = ""
                }
            }
        }
        return period
    }
}

public extension Decimal {
    /// Round `Decimal` number to certain number of decimal places.
    ///
    /// - Parameters:
    ///   - scale: How many decimal places.
    ///   - roundingMode: How should number be rounded. Defaults to `.plain`.
    /// - Returns: The new rounded number.

    func rounded(_ scale: Int, roundingMode: RoundingMode = .plain) -> Decimal {
        var value = self
        var result: Decimal = 0
        NSDecimalRound(&result, &value, scale, roundingMode)
        return result
    }
}
