//
//  SchedulerTests_AnyScheduler.swift
//  SchedulerTestTests
//
//

import Combine
import Foundation
import UIKit
import XCTest

private class HomeViewModel: ObservableObject {
    @Published private(set) var episodes: [Episode] = []

    private let apiClient: ApiClient
    private let scheduler: AnySchedulerOf<DispatchQueue>
    init(apiClient: ApiClient, scheduler: AnySchedulerOf<DispatchQueue>) {
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

class SchedulerTests_AnyScheduler: XCTestCase {
    var cancellables = Set<AnyCancellable>()

    func testViewModel() {
        let viewModel = HomeViewModel(
            apiClient: .mock,
            scheduler: DispatchQueue.immediateScheduler.eraseToAnyScheduler())

        var output: [[Episode]] = []
        viewModel.$episodes
            .sink { output.append($0) }
            .store(in: &self.cancellables)

        viewModel.reloadButtonTapped()
        XCTAssertEqual(output, [[], [Episode(id: 42)]])
    }
}
