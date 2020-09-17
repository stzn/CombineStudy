//
//  ImageDataLoader.swift
//  CombineCollection
//
//

import Combine
import Foundation

struct ImageDataLoader {
    let load: (URL) -> AnyPublisher<Data, Error>
}
