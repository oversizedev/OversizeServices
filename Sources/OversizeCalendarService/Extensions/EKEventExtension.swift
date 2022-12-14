//
// Copyright © 2022 Alexander Romanov
// EKEventExtension.swift
//

import EventKit
import OversizeCore

public extension EKEvent {
    var membersCount: Int {
        if organizer != nil, hasAttendees {
            return 1 + (attendees?.count ?? 0)
        } else if organizer != nil {
            return 1
        } else {
            return 1
        }
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

    var listId: String {
        guard let id = eventIdentifier else { return startDate.formatted() }
        return id + startDate.formatted()
    }
}
