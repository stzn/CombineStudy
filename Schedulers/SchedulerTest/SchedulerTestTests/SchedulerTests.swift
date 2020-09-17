//
//  AnySchedulerTests.swift
//  CombineCollectionTests
//
//

import Combine
import Foundation
import UIKit
import XCTest

private class HomeViewModel: ObservableObject {
    @Published private(set) var episodes: [Episode] = []

    private let apiClient: ApiClient
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }

    func reloadButtonTapped() {
        Just(())
            .flatMap { self.apiClient.fetchEpisodes() }
            .receive(on: DispatchQueue.main)
            .assign(to: &$episodes)
    }
}

class SchedulerTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()

    func testViewModel() {
        let viewModel = HomeViewModel(apiClient: .mock)

        let exp = expectation(description: #function)
        exp.expectedFulfillmentCount = 2

        var output: [[Episode]] = []
        viewModel.$episodes
            .sink { value in
                output.append(value)
                exp.fulfill()
            }
            .store(in: &self.cancellables)

        viewModel.reloadButtonTapped()
        _ = XCTWaiter.wait(for: [exp], timeout: 1)
        XCTAssertEqual(output, [[], [Episode(id: 42)]])
    }

    func testViewModel_withAssert() {
        // Given
        let viewModel = HomeViewModel(apiClient: .mock)

        // Then
        let exp = expectation(description: #function)
        viewModel.$episodes
            .assert(outputs: [[], [Episode(id: 42)]], expectation: exp)
            .store(in: &self.cancellables)

        // When
        viewModel.reloadButtonTapped()

        wait(for: [exp], timeout: 1.0)
    }


}

private extension Publisher {
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

private extension Publisher where Output: Equatable {
    func assert(outputs: [Output], expectation: XCTestExpectation,
                file: StaticString = #filePath,
                line: UInt = #line) -> AnyCancellable {
        return assert(outputs: outputs, expectation: expectation, isEqual: ==)
    }
}
