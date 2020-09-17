//
//  BreedListViewModelTests_pattern3.swift
//  CombineCollectionTests
//
//

import Combine
import XCTest
@testable import CombineCollection

// RunOnMainQueueSchedulerを使用すると
// DispatchQueueを切り替えが起きないため
// 結果をwaitする必要がなくなる

class BreedListViewModelTests_usingRunOnMainQueueScheduler: XCTestCase {
    var cancellabels = Set<AnyCancellable>()

    func test_whenInit_thenNotGetData() {
        // Given
        let viewModel = BreedListViewModel(loader: .emptyLoader)

        var received: [[DisplayBreed]] = []
        viewModel.$breeds
            .sink { received.append($0) }
            .store(in: &cancellabels)

        // When

        // Then
        XCTAssertEqual(received, [[DisplayBreed]()])
    }

    func test_whenFetchSuccess_thenGetList() {
        // Given
        let apiResponse = [anyBreed]
        let expected = apiResponse.map { $0.toDisplayBreed }
        let viewModel = BreedListViewModel(loader: .loader(apiResponse))
        var received: [[DisplayBreed]] = []
        viewModel.$breeds
            .sink { received.append($0) }
            .store(in: &cancellabels)

        // When
        viewModel.fetchList()

        // Then
        XCTAssertEqual(received, [[DisplayBreed](), expected])
    }

    func test_whenFetchFailure_thenGetError() {
        // Given
        struct TestError: Error {}
        let expected = TestError()
        let viewModel = BreedListViewModel(loader: .error(expected))

        var received: [[DisplayBreed]] = []
        viewModel.$breeds
            .sink { received.append($0) }
            .store(in: &cancellabels)

        var receivedError: [String?] = []
        viewModel.errorPublisher
            .sink { receivedError.append($0?.localizedDescription) }
            .store(in: &cancellabels)

        // When
        viewModel.fetchList()

        // Then
        XCTAssertEqual(received, [[DisplayBreed](), [DisplayBreed]()])
        XCTAssertEqual(receivedError, [nil, expected.localizedDescription])
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

    private var anyBreed: Breed {
        Breed(name: "\(UUID().uuidString)", subBreeds: [])
    }
}
