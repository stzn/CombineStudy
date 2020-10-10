//
//  ImageDataWebLoader.swift
//  SwiftUICombineCollection
//
//

import Combine
import Foundation

final class ImageDataWebLoader {
    private let queue: DispatchQueue
    private let client: HTTPClient
    init(client: HTTPClient,
         queue: DispatchQueue = DispatchQueue(label: "ImageDataWebLoaderQueue", attributes: .concurrent)) {
        self.client = client
        self.queue = queue
    }

    func load(_ url: URL) -> AnyPublisher<Data, Error> {
        client.send(request: URLRequest(url: url))
            .subscribe(on: queue)
            .eraseToAnyPublisher()
    }
}
