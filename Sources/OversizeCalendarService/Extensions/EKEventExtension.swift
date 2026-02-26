//
// Copyright © 2022 Alexander Romanov
// EKEventExtension.swift
//

#if canImport(EventKit)
import EventKit
#endif
import OversizeCore
import SwiftUI

#if os(iOS) || os(macOS)
extension EKEvent: Identifiable {
    public var color: Color {
        Color(calendar.cgColor)
    }
}

public extension EKEvent {
    var locationShortTitle: String? {
        if let meetType {
            return meetType.title
        } else if let location = location?.components(separatedBy: .newlines), let locationText: String = location.first {
            if locationText.count < 16 {
                return locationText.trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                var clean = locationText.trimmingCharacters(in: .whitespacesAndNewlines)
                let range = clean.index(clean.startIndex, offsetBy: 16) ..< clean.endIndex
                clean.removeSubrange(range)
                return clean + "..."
            }
        } else {
            return nil
        }
    }

    var membersCount: Int {
        if organizer != nil, hasAttendees {
            1 + (attendees?.count ?? 0)
        } else if organizer != nil {
            1
        } else {
            1
        }
    }

    var isExpired: Bool {
        Date() > endDate
    }

    var isNow: Bool {
        startDate > Date() && Date() < endDate
    }
}

// MARK: - URLs

public extension EKEvent {
    var allURLs: [URL]? {
        var urls: [URL] = .init()
        if let url {
            urls.append(url)
        }
        if let noteURLs {
            urls.append(contentsOf: noteURLs)
        }
        if urls.isEmpty {
            return nil
        } else {
            return urls
        }
    }

    var noteURLs: [URL]? {
        guard let text = notes else { return nil }
        let types: NSTextCheckingResult.CheckingType = .link
        do {
            let detector = try NSDataDetector(types: types.rawValue)
            let matches = detector.matches(in: text, options: .reportCompletion, range: NSMakeRange(0, text.count))
            return matches.compactMap { $0.url }
        } catch {
            debugPrint(error.localizedDescription)
        }
        return nil
    }

    var locationURLs: [URL]? {
        guard let text = location else { return nil }
        let types: NSTextCheckingResult.CheckingType = .link
        do {
            let detector = try NSDataDetector(types: types.rawValue)
            let matches = detector.matches(in: text, options: .reportCompletion, range: NSMakeRange(0, text.count))
            return matches.compactMap { $0.url }
        } catch {
            debugPrint(error.localizedDescription)
        }
        return nil
    }

    var meetType: EKEventMeetType? {
        var urls: [URL] = .init()

        if let url { urls.append(url) }
        if let noteURLs { urls.append(contentsOf: noteURLs) }
        if let locationURLs { urls.append(contentsOf: locationURLs) }
        guard urls.isEmpty == false else { return nil }

        if let _ = urls.first(where: { url in
            if let dmain = url.hostWithoutSubdomain, let pathFirst = url.pathComponents.first {
                guard url.pathComponents.count > 1 else { return false }
                let zoomURL = dmain + pathFirst + url.pathComponents[1]
                return zoomURL == "zoom.us/j" || zoomURL == "zoom.us/my"
            } else {
                return false
            }
        }) {
            return .zoom
        }
        if let _ = urls.first(where: { url in
            guard url.pathComponents.count > 1,
                  let host = url.host,
                  let pathFirst = url.pathComponents.first else { return false }
            let teamsURL: String = host + pathFirst + url.pathComponents[1]
            return teamsURL == "teams.live.com/meet"
        }) {
            return .teams
        }
        if let _ = urls.first(where: { url in
            guard let host = url.host else { return false }
            return host == "teams.microsoft.com" && url.path.hasPrefix("/l/meetup-join/")
        }) {
            return .teams
        }
        if let _ = urls.first(where: { $0.host == "meet.google.com" }) {
            return .googleMeet
        }
        if let _ = urls.first(where: { $0.host == "facetime.apple.com" }) {
            return .facetime
        }
        if let _ = urls.first(where: { $0.hostWithoutSubdomain == "webex.com" }) {
            return .webex
        }
        if let _ = urls.first(where: { url in
            guard let host = url.host else { return false }
            return host == "discord.gg" || (host == "discord.com" && url.path.hasPrefix("/invite/"))
        }) {
            return .discord
        }
        if let _ = urls.first(where: { $0.host == "app.slack.com" && $0.path.hasPrefix("/huddle/") }) {
            return .slackHuddle
        }
        if let _ = urls.first(where: { $0.host == "meet.jit.si" }) {
            return .jitsi
        }
        if let _ = urls.first(where: { $0.hostWithoutSubdomain == "whereby.com" }) {
            return .whereby
        }
        if let _ = urls.first(where: { $0.host == "telemost.yandex.ru" }) {
            return .telemost
        }
        if let _ = urls.first(where: { $0.host == "meeting.tencent.com" && $0.path.hasPrefix("/dm/") }) {
            return .tencentMeeting
        }
        if let _ = urls.first(where: { $0.host == "vc.feishu.cn" && $0.path.hasPrefix("/j/") }) {
            return .feishu
        }
        if let _ = urls.first(where: { $0.host == "vc.larksuite.com" && $0.path.hasPrefix("/j/") }) {
            return .lark
        }
        if let _ = urls.first(where: { $0.host == "voovmeeting.com" }) {
            return .voov
        }
        if let _ = urls.first(where: { $0.host == "meet.goto.com" }) {
            return .goToMeeting
        }
        if let _ = urls.first(where: { $0.host == "v.ringcentral.com" && $0.path.hasPrefix("/join/") }) {
            return .ringCentral
        }
        if let _ = urls.first(where: { $0.host?.hasPrefix("meet.zoho.") == true }) {
            return .zohoMeeting
        }
        if let _ = urls.first(where: { $0.host == "8x8.vc" }) {
            return .meet8x8
        }
        if let _ = urls.first(where: { $0.host == "meetings.dialpad.com" }) {
            return .dialpad
        }
        if let _ = urls.first(where: { $0.host == "signal.link" && $0.path.hasPrefix("/call/") }) {
            return .signal
        }
        if let _ = urls.first(where: { $0.hostWithoutSubdomain == "daily.co" }) {
            return .daily
        }
        return nil
    }

    var meetURL: URL? {
        var urls: [URL] = .init()

        if let url { urls.append(url) }
        if let noteURLs { urls.append(contentsOf: noteURLs) }
        if let locationURLs { urls.append(contentsOf: locationURLs) }
        guard urls.isEmpty == false else { return nil }

        if let zoomLink = urls.first(where: { url in
            if let dmain = url.hostWithoutSubdomain, let pathFirst = url.pathComponents.first {
                guard url.pathComponents.count > 1 else { return false }
                let zoomURL = dmain + pathFirst + url.pathComponents[1]
                return zoomURL == "zoom.us/j" || zoomURL == "zoom.us/my"
            } else {
                return false
            }
        }) {
            return zoomLink
        }
        if let teamsLink = urls.first(where: { url in
            guard url.pathComponents.count > 1,
                  let host = url.host,
                  let pathFirst = url.pathComponents.first else { return false }
            let teamsURL: String = host + pathFirst + url.pathComponents[1]
            return teamsURL == "teams.live.com/meet"
        }) {
            return teamsLink
        }
        if let teamsWorkLink = urls.first(where: { url in
            guard let host = url.host else { return false }
            return host == "teams.microsoft.com" && url.path.hasPrefix("/l/meetup-join/")
        }) {
            return teamsWorkLink
        }
        if let googleMeetLink = urls.first(where: { $0.host == "meet.google.com" }) {
            return googleMeetLink
        }
        if let facetimeLink = urls.first(where: { $0.host == "facetime.apple.com" }) {
            return facetimeLink
        }
        if let webexLink = urls.first(where: { $0.hostWithoutSubdomain == "webex.com" }) {
            return webexLink
        }
        if let discordLink = urls.first(where: { url in
            guard let host = url.host else { return false }
            return host == "discord.gg" || (host == "discord.com" && url.path.hasPrefix("/invite/"))
        }) {
            return discordLink
        }
        if let slackHuddleLink = urls.first(where: { $0.host == "app.slack.com" && $0.path.hasPrefix("/huddle/") }) {
            return slackHuddleLink
        }
        if let jitsiLink = urls.first(where: { $0.host == "meet.jit.si" }) {
            return jitsiLink
        }
        if let wherebyLink = urls.first(where: { $0.hostWithoutSubdomain == "whereby.com" }) {
            return wherebyLink
        }
        if let telomostLink = urls.first(where: { $0.host == "telemost.yandex.ru" }) {
            return telomostLink
        }
        if let tencentLink = urls.first(where: { $0.host == "meeting.tencent.com" && $0.path.hasPrefix("/dm/") }) {
            return tencentLink
        }
        if let feishuLink = urls.first(where: { $0.host == "vc.feishu.cn" && $0.path.hasPrefix("/j/") }) {
            return feishuLink
        }
        if let larkLink = urls.first(where: { $0.host == "vc.larksuite.com" && $0.path.hasPrefix("/j/") }) {
            return larkLink
        }
        if let voovLink = urls.first(where: { $0.host == "voovmeeting.com" }) {
            return voovLink
        }
        if let goToMeetingLink = urls.first(where: { $0.host == "meet.goto.com" }) {
            return goToMeetingLink
        }
        if let ringCentralLink = urls.first(where: { $0.host == "v.ringcentral.com" && $0.path.hasPrefix("/join/") }) {
            return ringCentralLink
        }
        if let zohoLink = urls.first(where: { $0.host?.hasPrefix("meet.zoho.") == true }) {
            return zohoLink
        }
        if let meet8x8Link = urls.first(where: { $0.host == "8x8.vc" }) {
            return meet8x8Link
        }
        if let dialpadLink = urls.first(where: { $0.host == "meetings.dialpad.com" }) {
            return dialpadLink
        }
        if let signalLink = urls.first(where: { $0.host == "signal.link" && $0.path.hasPrefix("/call/") }) {
            return signalLink
        }
        if let dailyLink = urls.first(where: { $0.hostWithoutSubdomain == "daily.co" }) {
            return dailyLink
        }
        return nil
    }

    var hasURLInLocation: Bool {
        guard let text = location else { return false }
        let types: NSTextCheckingResult.CheckingType = .link
        do {
            let detector = try NSDataDetector(types: types.rawValue)
            let matches = detector.matches(in: text, options: .reportCompletion, range: NSMakeRange(0, text.count))
            return !matches.compactMap { $0.url }.isEmpty
        } catch {
            debugPrint(error.localizedDescription)
        }
        return false
    }
}

public enum EKEventMeetType {
    case zoom, teams, googleMeet, facetime, webex
    case discord, slackHuddle, jitsi, whereby, telemost
    case tencentMeeting, feishu, lark, voov
    case goToMeeting, ringCentral, zohoMeeting, meet8x8, dialpad, signal, daily

    public var title: String {
        switch self {
        case .zoom:
            "Zoom"
        case .teams:
            "Microsoft Teams"
        case .googleMeet:
            "Google Meet"
        case .facetime:
            "FaceTime"
        case .webex:
            "Cisco Webex"
        case .discord:
            "Discord"
        case .slackHuddle:
            "Slack Huddle"
        case .jitsi:
            "Jitsi Meet"
        case .whereby:
            "Whereby"
        case .telemost:
            "Yandex Telemost"
        case .tencentMeeting:
            "Tencent Meeting"
        case .feishu:
            "Feishu"
        case .lark:
            "Lark"
        case .voov:
            "VooV Meeting"
        case .goToMeeting:
            "GoTo Meeting"
        case .ringCentral:
            "RingCentral"
        case .zohoMeeting:
            "Zoho Meeting"
        case .meet8x8:
            "8x8 Meet"
        case .dialpad:
            "Dialpad"
        case .signal:
            "Signal"
        case .daily:
            "Daily"
        }
    }
}

public extension EKEvent {
    var noteWithoutVideoCall: String? {
        guard let notes else { return nil }
        var noteWithoutVideoCall = notes
        if let startIndex = noteWithoutVideoCall.range(of: "----( Video Call )----")?.lowerBound,
           let endIndex = noteWithoutVideoCall.range(of: "---===---")?.upperBound
        {
            noteWithoutVideoCall.removeSubrange(startIndex ..< endIndex)
        }
        while noteWithoutVideoCall.last == "\n" {
            noteWithoutVideoCall.removeLast()
        }
        return noteWithoutVideoCall
    }

    var hasShortNotes: Bool {
        guard let noteWithoutVideoCall else { return false }
        if noteWithoutVideoCall.count < 160 {
            return false
        } else {
            return true
        }
    }

    var shortNotes: String? {
        guard let noteWithoutVideoCall else { return nil }
        if noteWithoutVideoCall.count < 160 {
            return noteWithoutVideoCall
        }
        var note = noteWithoutVideoCall
        let range = note.index(note.startIndex, offsetBy: 160) ..< note.endIndex
        note.removeSubrange(range)
        return note
    }

//    var listId: String {
//        guard let id = eventIdentifier else { return startDate.formatted() }
//        return id + startDate.formatted()
//    }

    var id: String {
        guard let id = eventIdentifier else { return startDate.formatted() }
        return id + startDate.formatted()
    }

    var urlTitle: String? {
        guard let url else { return nil }
        if url.absoluteString.count < 14 {
            return url.absoluteString
        }
        var urlString = url.absoluteString
        let range = urlString.index(urlString.startIndex, offsetBy: 14) ..< urlString.endIndex
        urlString.removeSubrange(range)
        return urlString + "..."
    }
}
#endif
