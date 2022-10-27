//
// Copyright © 2022 Alexander Romanov
// Router.swift
//

// import SwiftUI
/*
 public final class Router: ObservableObject {

     @Published public var fullScreenSheet: Screens?

     public init() {}

     public func present(_ sceeen: Screens?) {
         self.fullScreenSheet = sceeen
     }
 }
 */

// private struct RouterKey: EnvironmentKey {
//    public static var defaultValue: RouterStateAction = .init()
// }
//
// public extension EnvironmentValues {
//    var router: RouterStateAction {
//        get { self[RouterKey.self] }
//        set { self[RouterKey.self] = newValue }
//    }
// }
//
// public extension View {
//    func sheetSceen(_ rootSheet: SceetScreens?) -> some View {
//        environment(\.router, RouterStateAction(rootSheet))
//    }
// }
//
// public class RouterStateAction {
//    public var fullScreenSheet: SceetScreens?
//
//    public init(_ sheet: SceetScreens? = nil) {
//        self.fullScreenSheet = sheet
//    }
//
//    public func present(_ sheet: SceetScreens?) {
//        fullScreenSheet = sheet
//        //sendState()
//    }
// }
//
// public enum SceetScreens: Identifiable, Equatable {
//    case onboarding
//    case payWall
//    case rate
//    case specialOffer(event: String)
//    case webView(url: URL)
//    public var id: Int {
//        switch self {
//        case .onboarding: return 0
//        case .payWall: return 1
//        case .rate: return 2
//        case .specialOffer: return 3
//        case .webView: return 4
//
//        }
//    }
// }

// private struct RootRouterKey: EnvironmentKey {
//    public static var defaultValue: Router = .init()
// }
//
// public extension EnvironmentValues {
//    var router: Router {
//        get { self[RootRouterKey.self] }
//        set { self[RootRouterKey.self] = newValue }
//    }
// }
//
// public extension View {
//    func router(_ rootSheet: Router.Screens?) -> some View {
//        environment(\.router, .init())
//    }
// }

// public struct Router {
//
//    public var fullScreenSheet: Screens?
//
//    public init() {}
//
//    public init(_ sceeen: Screens?) {
//        fullScreenSheet = sceeen
//    }
//
//    public enum Screens: Identifiable, Equatable {
//        case onboarding
//        case payWall
//        case rate
//        case specialOffer(event: String)
//        case webView(url: URL)
//        public var id: Int {
//            switch self {
//            case .onboarding: return 0
//            case .payWall: return 1
//            case .rate: return 2
//            case .specialOffer: return 3
//            case .webView: return 4
//
//            }
//        }
//    }
//
////    public func present(_ sceeen: Screens?) {
////        fullScreenSheet = sceeen
////    }
// }
