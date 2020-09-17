//
//  Breed.swift
//  SwiftUICombineCollection
//
//

import Foundation

typealias BreedType = String

struct Breed: Hashable, Equatable, Decodable {
    let name: String
    let subBreeds: [Breed]
}

extension Breed: Identifiable {
    var id: Self { self }
}

extension Breed {
    static var anyBreed: Breed {
        let anyID = UUID().uuidString
        return Breed(name: "test\(anyID)", subBreeds: [])
    }
}
