//
//  APIClient.swift
//  SwiftUICombineCollection
//
//

import Combine
import Foundation

struct URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    init(session: URLSession) {
        self.session = session
    }

    func send(request: URLRequest) -> AnyPublisher<Data, Error> {
        session.dataTaskPublisher(for: request)
            .tryMap { (data, response) in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .eraseToAnyPublisher()
    }
}

