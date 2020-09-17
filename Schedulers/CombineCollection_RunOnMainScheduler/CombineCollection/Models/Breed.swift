//
//  Breed.swift
//  CombineCollection
//
//

import Foundation

typealias BreedType = String

struct Breed: Equatable, Decodable, Hashable {
    let name: String
    let subBreeds: [Breed]

    var id: Self { self }
}
