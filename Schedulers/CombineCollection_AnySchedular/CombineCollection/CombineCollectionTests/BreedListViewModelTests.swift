//
//  BreedListViewModelTests.swift
//  CombineCollectionTests
//
//

import Combine
import XCTest
@testable import CombineCollection

// ImmediateSchedulerを使用すると
// DispatchQueueを切り替えが起きないため
// 結果をwaitする必要がなくなる

class BreedListViewModelTests: XCTestCase {
    var cancellabels = Set<AnyCancellable>()

    func test_whenInit_thenNotGetData() {
        // Given
        let viewModel = BreedListViewModel(loader: .emptyLoader)

        // When

        // Then
        let exp = expectation(description: #function)
        viewModel.$breeds
            .assert(outputs: [[]], expectation: exp)
            .store(in: &cancellabels)

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

        wait(for: [exp], timeout: 2.0)
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
