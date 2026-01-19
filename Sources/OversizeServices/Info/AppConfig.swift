//
// Copyright © 2022 Alexander Romanov
// AppConfig.swift
//

import Foundation

public struct PlistConfiguration: Codable, Sendable {
    public var links: Links

    private enum CodingKeys: String, CodingKey, Sendable {
        case links = "Links"
    }

    public struct Links: Codable, Sendable {
        public var app: App
        public var developer: Developer
        public var company: Company

        private enum CodingKeys: String, CodingKey, Sendable {
            case app = "App"
            case developer = "Developer"
            case company = "Company"
        }

        public struct App: Codable, Hashable, Sendable {
            public var telegramChat: String?
            public var appStoreId: String

            private enum CodingKeys: String, CodingKey, Sendable {
                case telegramChat = "TelegramChat"
                case appStoreId = "AppStoreID"
            }
        }

        public struct Developer: Codable, Hashable, Sendable {
            public var name: String?
            public var url: String?
            public var email: String?
            public var facebook: String?
            public var telegram: String?

            private enum CodingKeys: String, CodingKey, Sendable {
                case name = "Name"
                case url = "Url"
                case email = "Email"
                case facebook = "Facebook"
                case telegram = "Telegram"
            }
        }

        public struct Company: Codable, Hashable, Sendable {
            public var name: String?
            public var urlString: String?
            public var email: String?
            public var appStoreId: String
            public var facebook: String?
            public var telegram: String?
            public var dribbble: String?
            public var instagram: String?
            public var twitter: String?
            public var cdnString: String?

            public var url: URL? {
                URL(string: urlString ?? "")
            }

            private enum CodingKeys: String, CodingKey {
                case name = "Name"
                case urlString = "Url"
                case email = "Email"
                case appStoreId = "AppStoreID"
                case facebook = "Facebook"
                case telegram = "Telegram"
                case dribbble = "Dribbble"
                case instagram = "Instagram"
                case twitter = "Twitter"
                case cdnString = "CDNUrl"
            }
        }
    }
}
