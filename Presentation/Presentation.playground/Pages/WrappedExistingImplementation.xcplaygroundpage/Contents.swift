//: [Previous](@previous)

import Combine
import Foundation

func load(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
    completion(.success(Data()))
}

func loadPublisher(from url: URL) -> AnyPublisher<Data, Error> {
    Deferred {
        Future { promise in
            load(from: url, completion: promise)
        }
    }.eraseToAnyPublisher()
}

//: [Next](@next)
