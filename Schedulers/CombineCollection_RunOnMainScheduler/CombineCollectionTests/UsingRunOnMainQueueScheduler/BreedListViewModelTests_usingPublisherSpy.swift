//
//  BreedListViewModelTests_usingPublisherSpy.swift
//  CombineCollectionTests
//
//

import Combine
import XCTest
@testable import CombineCollection

// RunOnMainQueueSchedulerの使用を前提としている
// PublisherSpyを利用することで
// publisherの出力するEventを時系列に追っていくことができる

class BreedListViewModelTests_usingPublisherSpy: XCTestCase {
    var cancellabels = Set<AnyCancellable>()

    func test_whenInit_thenNotGetData() {
        // Given
        let viewModel = BreedListViewModel(loader: .emptyLoader)
        let spy = PublisherSpy(viewModel.$breeds.eraseToAnyPublisher())

        // When

        // Then
        assertEquals(spy.receivedEvents, [.value([])])
    }

    func test_whenFetchSuccess_thenGetList() {
        // Given
        let apiResponse = [anyBreed]
        let expected = apiResponse.map { $0.toDisplayBreed }
        let viewModel = BreedListViewModel(loader: .loader(apiResponse))
        let spy = PublisherSpy(viewModel.$breeds.eraseToAnyPublisher())

        // When
        viewModel.fetchList()

        // Then
        assertEquals(spy.receivedEvents,
                     [.value([]), .value(expected)])
    }

    func test_whenFetchFailure_thenGetError() {
        // Given
        struct TestError: Error {}
        let expected = TestError()
        let viewModel = BreedListViewModel(loader: .error(expected))
        let errorSpy = PublisherSpy(viewModel.$error.eraseToAnyPublisher())

        // When
        viewModel.fetchList()

        // Then
        assertEquals(
            errorSpy.receivedEvents,
            [.value(nil), .value(nil), .value(expected)],
            isEqual: {
               switch ($0, $1) {
               case (.value(let l), .value(let r)):
                   return l?.localizedDescription == r?.localizedDescription
               default:
                   return false
               }
            })
    }

    func test_whenFetchTwiceSuccess_thenGetSameList() {
        // Given
        let apiResponse = [anyBreed]
        let expected = apiResponse.map { $0.toDisplayBreed }
        let viewModel = BreedListViewModel(loader: .loader(apiResponse))
        let spy = PublisherSpy(viewModel.$breeds.eraseToAnyPublisher())

        // When
        viewModel.fetchList()
        viewModel.fetchList()

        // Then
        assertEquals(spy.receivedEvents,
                     [.value([]), .value(expected), .value(expected)])
    }
}

// MARK: - PublisherSpy

final class PublisherSpy<Success, Failure: Error> {
    enum Event {
        case value(Success)
        case finished
        case failure(Error)
    }

    var cancellable: AnyCancellable?
    var receivedEvents: [Event] = []
    init(_ publisher: AnyPublisher<Success, Failure>) {
        cancellable = publisher.sink { [self] finished in
            switch finished {
            case .finished:
                receivedEvents.append(.finished)
            case .failure(let error):
                receivedEvents.append(.failure(error))
            }
        }
        receiveValue: { [self] value in
            receivedEvents.append(.value(value))
        }
    }
}

extension XCTestCase {
    func assertEquals<Success, Failure>(
        _ expected: [PublisherSpy<Success, Failure>.Event],
        _ received: [PublisherSpy<Success, Failure>.Event],
        isEqual: @escaping (PublisherSpy<Success, Failure>.Event, PublisherSpy<Success, Failure>.Event) -> Bool,
        file: StaticString = #filePath, line: UInt = #line) {
        for (e, r) in zip(expected, received) {
            e.assertEqual(r, isEqual: isEqual, file: file, line: line)
        }
    }

    func assertEquals<Success, Failure>(
        _ expected: [PublisherSpy<Success, Failure>.Event],
        _ received: [PublisherSpy<Success, Failure>.Event],
        file: StaticString = #filePath, line: UInt = #line)
    where Success: Equatable {
        for (e, r) in zip(expected, received) {
            e.assertEqual(r, file: file, line: line)
        }
    }
}

extension PublisherSpy.Event {
    func assertEqual(
        _ expected: Self,
        isEqual: @escaping (Self, Self) -> Bool,
        file: StaticString = #filePath, line: UInt = #line) {
        if !isEqual(self, expected) {
            XCTFail("unmatched", file: file, line: line)
        }
    }

    func assertEqual(
        _ expected: PublisherSpy.Event,
        file: StaticString = #filePath, line: UInt = #line) where Success: Equatable {
        switch (self, expected) {
        case (let .value(l), let .value(r)):
            if l != r {
                XCTFail("unmatched", file: file, line: line)
            }
        case (.finished, .finished):
            break
        case (let .failure(l), let .failure(r)):
            if l.localizedDescription != r.localizedDescription {
                XCTFail("unmatched", file: file, line: line)
            }
        default:
            XCTFail("unmatched", file: file, line: line)
        }
    }
}
