//
// Copyright © 2022 Alexander Romanov
// TapticEngine.swift
//

import SwiftUI

@MainActor
public enum TapticEngine: Sendable {
    case error
    case success
    case warning
    case light
    case medium
    case heavy
    case soft
    case rigid
    case selection

    public func vibrate() {
        switch self {
        case .error:
            #if os(iOS)
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            #endif
        case .success:
            #if os(iOS)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            #endif
        case .warning:
            #if os(iOS)
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            #endif
        case .light:
            #if os(iOS)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
        case .medium:
            #if os(iOS)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            #endif
        case .heavy:
            #if os(iOS)
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            #endif
        case .soft:
            #if os(iOS)
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            #endif
        case .rigid:
            #if os(iOS)
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            #endif
        case .selection:
            #if os(iOS)
            UISelectionFeedbackGenerator().selectionChanged()
            #endif
        }
    }
}
