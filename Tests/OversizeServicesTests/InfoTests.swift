//
// Copyright © 2026 Alexander Romanov
// InfoTests.swift
//

import Foundation
@testable import OversizeServices
import Testing

struct InfoTests {
    @Test
    func appStoreUrlsAreNilWithoutAppStoreId() {
        #expect(Info.App.appStoreId == nil)
        #expect(Info.App.appStoreUrl == nil)
        #expect(Info.App.appStoreReviewUrl == nil)
    }

    @Test
    func websiteDerivedUrlsAreNilWithoutCompanyWebsite() {
        #expect(Info.Company.websiteUrl == nil)
        #expect(Info.App.websiteUrl == nil)
        #expect(Info.App.privacyPolicyUrl == nil)
        #expect(Info.App.termsOfUseUrl == nil)
    }

    @Test
    func telegramChatUrlIsNilWithoutChatId() {
        #expect(Info.App.telegramChatId == nil)
        #expect(Info.App.telegramChatUrl == nil)
    }

    @Test
    func developerUrlsAreNilWithoutConfiguration() {
        #expect(Info.Developer.email == nil)
        #expect(Info.Developer.emailUrl == nil)
        #expect(Info.Developer.websiteUrl == nil)
        #expect(Info.Developer.appsUrl == nil)
    }

    @Test
    func companySocialUrlsAreNilWithoutUsernames() {
        #expect(Info.Company.telegramUrl == nil)
        #expect(Info.Company.facebookUrl == nil)
        #expect(Info.Company.twitterUrl == nil)
        #expect(Info.Company.dribbbleUrl == nil)
        #expect(Info.Company.instagramUrl == nil)
        #expect(Info.Company.emailUrl == nil)
    }

    @Test
    func alternateIconNamesAreEmptyWithoutBundleIcons() {
        #expect(Info.App.alternateIconNames.isEmpty)
        #expect(Info.App.iconName == nil)
        #expect(Info.App.icon == nil)
    }

    @Test
    func localeIdentifierIsAvailable() {
        #expect(Info.App.localeIdentifier == Locale.current.identifier)
    }
}
