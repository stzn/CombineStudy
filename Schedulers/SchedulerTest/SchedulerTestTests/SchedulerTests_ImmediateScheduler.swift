//
//  SchedulerTests_ImmediateScheduler.swift
//  SchedulerTestTests
//
//

import Combine
import Foundation
import UIKit
import XCTest

private class HomeViewModel<S: Scheduler>: ObservableObject {
    @Published private(set) var episodes: [Episode] = []

    private let apiClient: ApiClient
    private let scheduler: S
    init(apiClient: ApiClient, scheduler: S) {
        self.apiClient = apiClient
        self.scheduler = scheduler
    }

    func reloadButtonTapped() {
        Just(())
            .delay(for: .seconds(10), scheduler: scheduler)
            .flatMap { self.apiClient.fetchEpisodes() }
            .receive(on: scheduler)
            .assign(to: &$episodes)
    }
}

class SchedulerTests_ImmediateScheduler: XCTestCase {
    var cancellables = Set<AnyCancellable>()

    func testViewModel() {
        let viewModel = HomeViewModel(
            apiClient: .mock,
            scheduler: Combine.ImmediateScheduler.shared
        )

        var output: [[Episode]] = []
        viewModel.$episodes
            .sink { output.append($0) }
            .store(in: &self.cancellables)

        viewModel.reloadButtonTapped()
        XCTAssertEqual(output, [[], [Episode(id: 42)]])
    }
}
