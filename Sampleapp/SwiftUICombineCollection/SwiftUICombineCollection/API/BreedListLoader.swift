//
//  BreedListLoader.swift
//  SwiftUICombineCollection
//
//

import Combine
import Foundation

struct BreedListLoader {
    let load: () -> AnyPublisher<[Breed], Error>
}

#if DEBUG
extension BreedListLoader {
    static var stub: Self {
        BreedListLoader {
            Just([Breed.anyBreed, Breed.anyBreed, Breed.anyBreed])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
}
#endif
