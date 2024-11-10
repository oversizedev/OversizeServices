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
extension EKEvent: @retroactive Identifiable {
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
                    let clean = locationText.trimmingCharacters(in: .whitespacesAndNewlines)
                    return clean
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
                return 1 + (attendees?.count ?? 0)
            } else if organizer != nil {
                return 1
            } else {
                return 1
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

        var zoomURL: URL? {
            if let url = noteURLs?.first(where: { url in
                if let dmain = url.hostWithoutSubdomain, let pathFirst = url.pathComponents.first {
                    guard url.pathComponents.count > 1 else { return false }
                    let zoomURL = dmain + pathFirst + url.pathComponents[1]
                    return zoomURL == "zoom.us/j"
                } else {
                    return false
                }
            }) {
                return url
            } else {
                return nil
            }
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
                    return zoomURL == "zoom.us/j"
                } else {
                    return false
                }
            }) {
                return .zoom
            }
            if let _ = urls.first(where: { $0.host == "meet.google.com" }) {
                return .googleMeet
            }
            if let _ = urls.first(where: { url in
                guard url.pathComponents.count > 1,
                      let host = url.host,
                      let pathFirst = url.pathComponents.first else { return false }

                let temsURL: String = host + pathFirst + url.pathComponents[1]
                return temsURL == "teams.live.com/meet"
            }) {
                return .googleMeet
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
                    return zoomURL == "zoom.us/j"
                } else {
                    return false
                }
            }) {
                return zoomLink
            }
            if let googleMeetLink = urls.first(where: { $0.host == "meet.google.com" }) {
                return googleMeetLink
            }
            if let teamsLink = urls.first(where: { url in
                guard url.pathComponents.count > 1,
                      let host = url.host,
                      let pathFirst = url.pathComponents.first else { return false }

                let temsURL: String = host + pathFirst + url.pathComponents[1]
                return temsURL == "teams.live.com/meet"
            }) {
                return teamsLink
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
        case zoom, googleMeet, teams

        public var title: String {
            switch self {
            case .zoom:
                return "Zoom"
            case .googleMeet:
                return "Google Meet"
            case .teams:
                return "Microsoft Teams"
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
