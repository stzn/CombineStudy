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
