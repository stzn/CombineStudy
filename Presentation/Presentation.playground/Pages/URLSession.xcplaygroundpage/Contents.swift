//: [Previous](@previous)

import Combine
import Foundation
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

struct Breed: Equatable, Decodable {
    let name: String
    let subBreeds: [Breed]
}

struct BreedListAPIModel: Decodable {
    let message: [String: [String]]
    let status: String
}

func load() -> AnyPublisher<[Breed], Error> {
    func convert(from model: BreedListAPIModel) -> [Breed] {
        let messages = model.message
        return messages.map { message in
            Breed(name: message.key,
                  subBreeds: message.value
                    .map { Breed(name: $0, subBreeds: []) })
        }
    }

    return URLSession.shared.dataTaskPublisher(for: URL(string: "https://dog.ceo/api/breeds/list/all")!)
        .map(\.data)
        .decode(type: BreedListAPIModel.self, decoder: JSONDecoder())
        .map(convert(from:))
        .eraseToAnyPublisher()
}

let subscription = load()
    .sink(receiveCompletion: { finished in
        print("receiveCompletion: \(finished)")
    }, receiveValue: { value in
        print("receiveValue: \(value)")
    })


//: [Next](@next)
