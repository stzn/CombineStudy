//
//  ImageDataWebLoader.swift
//  CombineCollection
//
//

import Combine
import Foundation

final class ImageDataWebLoader {
    private let queue = DispatchQueue(label: "ImageWebAPI")
    private let client: HTTPClient
    init(client: HTTPClient) {
        self.client = client
    }

    var loader: ImageDataLoader {
        ImageDataLoader { [self] url in
            client.send(request: URLRequest(url: url))
                .subscribe(on: queue)
                .eraseToAnyPublisher()
        }
    }
}
