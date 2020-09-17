//
//  DogImage.swift
//  SwiftUICombineCollection
//
//

import Foundation

struct DogImage: Equatable, Decodable, Hashable {
    let imageURL: URL
}

extension DogImage: Identifiable {
    var id: Self { self }
}

extension DogImage {
    static var anyDogImage: DogImage {
        DogImage(imageURL: URL(string: "https://\(UUID().uuidString).image.com")!)
    }
}
