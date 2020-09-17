//
//  DogImageListLoader.swift
//  CombineCollection
//
//

import Combine
import Foundation

struct DogImageListLoader {
    let load: (BreedType) -> AnyPublisher<[DogImage], Error>
}
