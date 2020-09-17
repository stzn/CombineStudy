//
//  SchedulerTests_RunOnMainQueue.swift
//  SchedulerTestTests
//
//

import Combine
import XCTest

private class HomeViewModel: ObservableObject {
    @Published private(set) var episodes: [Episode] = []

    private let apiClient: ApiClient
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }

    func reloadButtonTapped() {
        Just(())
            .delay(for: .seconds(10), scheduler: DispatchQueue.runOnMainQueueScheduler)
            .flatMap { self.apiClient.fetchEpisodes() }
            .receiveOnMainQueue()
            .assign(to: &$episodes)
    }
}

class SchedulerTests_RunOnMainQueue: XCTestCase {

    var cancellables = Set<AnyCancellable>()

    func testViewModel() {
        let viewModel = HomeViewModel(apiClient: .mock)

        var output: [[Episode]] = []
        viewModel.$episodes
            .sink { value in
                output.append(value)
            }
            .store(in: &self.cancellables)

        viewModel.reloadButtonTapped()
        _ = XCTWaiter().wait(for: [XCTestExpectation()], timeout: 11)
        XCTAssertEqual(output, [[], [Episode(id: 42)]])
    }

    func testViewModel_reloadTwice() {
        let viewModel = HomeViewModel(apiClient: .mock)

        var output: [[Episode]] = []
        viewModel.$episodes
            .sink { value in
                output.append(value)
            }
            .store(in: &self.cancellables)

        viewModel.reloadButtonTapped()
        viewModel.reloadButtonTapped()
        _ = XCTWaiter().wait(for: [XCTestExpectation()], timeout: 12)
        XCTAssertEqual(output, [[], [Episode(id: 42)], [Episode(id: 42)]])
    }
}
