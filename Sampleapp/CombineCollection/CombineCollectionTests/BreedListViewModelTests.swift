//
//  BreedListViewModelTests_pattern2.swift
//  CombineCollectionTests
//
//

import Combine
import XCTest
@testable import CombineCollection

// receive(on: DispatchQueue.main)を使用しているため
// 結果をwaitする必要がある

class BreedListViewModelTests: XCTestCase {
    var cancellabels = Set<AnyCancellable>()

    func test_whenInit_thenNotGetData() {
        // Given
        let viewModel = BreedListViewModel(loader: .emptyLoader)

        // When

        // Then
        let exp = expectation(description: #function)
        _ = viewModel.$breeds
            .assert(outputs: [[]], expectation: exp)

        wait(for: [exp], timeout: 1.0)
    }

    func test_whenFetchSuccess_thenGetList() {
        // Given
        let apiResponse = [anyBreed]
        let expected = apiResponse.map { $0.toDisplayBreed }
        let viewModel = BreedListViewModel(loader: .loader(apiResponse))

        // Then
        let exp = expectation(description: #function)
        viewModel.$breeds
            .assert(outputs: [[], expected], expectation: exp)
            .store(in: &cancellabels)

        // When
        viewModel.fetchList()

        wait(for: [exp], timeout: 1.0)
    }

    func test_whenFetchFailure_thenGetError() {
        // Given
        struct TestError: Error {}
        let expected = TestError()
        let viewModel = BreedListViewModel(loader: .error(expected))

        // Then
        let exp = expectation(description: #function)
        viewModel.$error
            .assert(outputs: [nil, nil, expected], expectation: exp, isEqual: {
                $0?.localizedDescription == $1?.localizedDescription
            })
            .store(in: &cancellabels)

        // When
        viewModel.fetchList()

        wait(for: [exp], timeout: 1.0)
    }

    func test_whenFetchTwiceSuccess_thenGetSameList() {
        // Given
        let apiResponse = [anyBreed]
        let expected = apiResponse.map { $0.toDisplayBreed }
        let viewModel = BreedListViewModel(loader: .loader(apiResponse))

        // Then
        let exp = expectation(description: #function)
        viewModel.$breeds
            .assert(outputs: [[], expected, expected], expectation: exp)
            .store(in: &cancellabels)

        // When
        viewModel.fetchList()
        viewModel.fetchList()

        wait(for: [exp], timeout: 1.0)
    }
}

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
