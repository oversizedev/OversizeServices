//
// Copyright © 2026 Alexander Romanov
// ResultExpectations.swift
//

import Foundation
import Testing

func expectFailure(
    _ result: Result<some Any, Error>,
    is expected: some Error,
    sourceLocation: SourceLocation = #_sourceLocation,
) {
    guard case let .failure(error) = result else {
        Issue.record("Expected failure, got success", sourceLocation: sourceLocation)
        return
    }
    #expect(String(describing: error) == String(describing: expected), sourceLocation: sourceLocation)
}

func expectSuccess<Value>(
    _ result: Result<Value, Error>,
    sourceLocation: SourceLocation = #_sourceLocation,
) -> Value? {
    switch result {
    case let .success(value):
        return value
    case let .failure(error):
        Issue.record("Expected success, got \(error)", sourceLocation: sourceLocation)
        return nil
    }
}
