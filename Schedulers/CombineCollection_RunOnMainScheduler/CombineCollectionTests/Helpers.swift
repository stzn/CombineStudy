//
//  Helpers.swift
//  CombineCollectionTests
//
//

import Combine
import Foundation
@testable import CombineCollection

extension BreedListLoader {
    static let emptyLoader = BreedListLoader {
        Empty().setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    static func loader(_ response: [Breed]) -> BreedListLoader {
        BreedListLoader {
            Just(response)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }

    static func error(_ error: Error) -> BreedListLoader {
        BreedListLoader {
            Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
}

var anyBreed: Breed {
    Breed(name: "\(UUID().uuidString)", subBreeds: [])
}

extension Breed {
    var toDisplayBreed: DisplayBreed {
        let allKind = subBreedForAllKind(name: name)
        guard self.subBreeds.isEmpty else {
            return DisplayBreed(name: name, displayName: name,
                                subBreeds: [allKind])
        }
        let subBreeds = self.subBreeds.map {
            DisplayBreed(
                name: $0.name, displayName: $0.name, subBreeds: [])
        }
        return DisplayBreed(name: name, displayName: name,
                            subBreeds: [allKind] + subBreeds)
    }

    private func subBreedForAllKind(name: String) -> DisplayBreed {
        DisplayBreed(name: name, displayName: "\(name)の全種別")
    }
}

import XCTest

extension Publisher {
    func assert(outputs: [Output], expectation: XCTestExpectation,
                isEqual: @escaping (Output, Output) -> Bool,
                file: StaticString = #filePath,
                line: UInt = #line) -> AnyCancellable {
        var expectedOutputs = outputs
        return self.sink { _ in
            // 何もしない
        }
        receiveValue: { output in
            guard let expectedOutput = expectedOutputs.first else {
                XCTFail("too many outputs published", file: file, line: line)
                return
            }
            guard isEqual(expectedOutput, output) else {
                XCTFail("unmatched output published", file: file, line: line)
                return
            }

            expectedOutputs = Array(expectedOutputs.dropFirst())

            if expectedOutputs.isEmpty {
                expectation.fulfill()
            }
        }
    }
}

extension Publisher where Output: Equatable {
    func assert(outputs: [Output], expectation: XCTestExpectation,
                file: StaticString = #filePath,
                line: UInt = #line) -> AnyCancellable {
        return assert(outputs: outputs, expectation: expectation, isEqual: ==)
    }
}

// https://gist.github.com/CassiusPacheco/4353b7655595af254a14b7270bf29f64
extension XCTestCase {
    func waitForCompletion<P: Publisher>(for publisher: P) -> Result<[P.Output], P.Failure> {
        let exp = expectation(description: "wait for completion")
        var outputs: [P.Output] = []
        var result: Result<[P.Output], P.Failure>!

        _ = publisher.sink { finished in
            defer { exp.fulfill() }

            switch finished {
            case .finished:
                result = .success(outputs)
            case .failure(let error):
                result = .failure(error)
            }
        }
        receiveValue: { output in
            outputs.append(output)
        }

        wait(for: [exp], timeout: 1.0)

        return result
    }
}
