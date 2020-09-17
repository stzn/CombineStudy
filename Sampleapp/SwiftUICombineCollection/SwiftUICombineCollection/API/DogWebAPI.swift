//
//  DogWebAPI.swift
//  SwiftUICombineCollection
//
//

import Combine
import Foundation

final class DogWebAPI {
    let baseURL = URL(string: "https://dog.ceo/api")!
    let client: HTTPClient
    let queue: DispatchQueue
    init(client: HTTPClient,
         queue: DispatchQueue = DispatchQueue(label: "DogWebAPIQueue")) {
        self.client = client
        self.queue = queue
    }

    var breedListLoader: BreedListLoader {
        struct BreedListAPIModel: Decodable {
            let message: [String: [String]]
            let status: String
        }

        func convert(from model: BreedListAPIModel) -> [Breed] {
            let messages = model.message
            return messages.map { message in
                Breed(name: message.key,
                      subBreeds: message.value
                        .map { Breed(name: $0, subBreeds: []) })
            }
        }

        return BreedListLoader { [self] in
            let request = URLRequest(url: baseURL.appendingPathComponent("breeds/list/all"))
            return client.send(request: request)
                .subscribe(on: queue)
                .decode(type: BreedListAPIModel.self, decoder: JSONDecoder())
                .map(convert(from:))
                .eraseToAnyPublisher()
        }
    }

    var dogImageListLoader: DogImageListLoader {
        struct DogImageListAPIModel: Decodable {
            let message: [String]
            let status: String
        }

        func convert(from model: DogImageListAPIModel) -> [DogImage] {
            let urlStrings = model.message
            let dogImages = urlStrings.compactMap { urlString -> DogImage? in
                guard let url = URL(string: urlString) else {
                    return nil
                }
                return DogImage(imageURL: url)
            }
            return dogImages
        }

        return DogImageListLoader { [self] breedType in
            let request = URLRequest(url: baseURL.appendingPathComponent("/breed/\(breedType)/images"))
            return client.send(request: request)
                .subscribe(on: queue)
                .decode(type: DogImageListAPIModel.self, decoder: JSONDecoder())
                .map(convert(from:))
                .eraseToAnyPublisher()
        }
    }
}
