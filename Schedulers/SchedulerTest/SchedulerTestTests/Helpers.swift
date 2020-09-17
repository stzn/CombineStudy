//
//  Helpers.swift
//  CombineCollectionTests
//
//

import Combine
import Foundation
import XCTest

struct Episode: Equatable {
    let id: Int
}

struct ApiClient {
    static let mock = ApiClient()

    func fetchEpisodes() -> AnyPublisher<[Episode], Never> {
        Deferred {
            Future { promise in
                promise(.success([Episode(id: 42)]))
            }
        }
        .eraseToAnyPublisher()
    }
}
