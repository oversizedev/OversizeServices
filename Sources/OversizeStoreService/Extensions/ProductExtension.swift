//
// Copyright © 2022 Alexander Romanov
// ProductExtension.swift
//

import Foundation
import OversizeCore
import StoreKit

public extension Product {
    var displayMonthsCount: String {
        switch type {
        case .autoRenewable, .nonRenewable:
            if let subscription {
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
            if let subscription {
                switch subscription.subscriptionPeriod.unit {
                case .day:
                    return "\((price * 30).rounded(2))"
                case .week:
                    return "\((price * 4).rounded(2))"
                case .month:
                    return "\(price.rounded(2))"
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
            " / month"
        } else {
            " / mo"
        }
    }

    var perYearLabel: String {
        if displayPrice.count < 6 {
            " / year"
        } else {
            " / yr"
        }
    }
}

public extension Product {
    var displayMonthPricePeriod: String {
        switch type {
        case .autoRenewable, .nonRenewable:
            " / month"
        default:
            ""
        }
    }
}

public extension Product {
    var displayMonthsCountDescription: String {
        switch type {
        case .autoRenewable, .nonRenewable:
            if let subscription {
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
            if #available(iOS 15.4, macOS 12.3, tvOS 15.4, *) {
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
            if #available(iOS 15.4, macOS 12.3, tvOS 15.4, *) {
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

public extension Product {
    var isOffer: Bool {
        if id.contains(".offerYearly") {
            true
        } else {
            false
        }
    }
}

public extension Product {
    var trialDaysCount: Int? {
        guard let value = subscription?.introductoryOffer?.period.value,
              let unit = subscription?.introductoryOffer?.period.unit
        else {
            return nil
        }
        switch unit {
        case .day:
            return 1 * value
        case .week:
            return 7 * value
        case .month:
            return 30 * value
        case .year:
            return 366 * value
        default:
            return nil
        }
    }
}
