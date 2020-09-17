//
//  BreedListLoader.swift
//  CombineCollection
//
//

import Combine
import Foundation

struct BreedListLoader {
    let load: () -> AnyPublisher<[Breed], Error>
}
