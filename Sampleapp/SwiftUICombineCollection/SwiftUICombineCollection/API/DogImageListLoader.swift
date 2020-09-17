//
//  DogImageListLoader.swift
//  SwiftUICombineCollection
//
//

import Combine
import Foundation

struct DogImageListLoader {
    let load: (BreedType) -> AnyPublisher<[DogImage], Error>
}

#if DEBUG
extension DogImageListLoader {
    static var stub = DogImageListLoader { _ in
        Just([DogImage.anyDogImage, DogImage.anyDogImage, DogImage.anyDogImage])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
#endif
