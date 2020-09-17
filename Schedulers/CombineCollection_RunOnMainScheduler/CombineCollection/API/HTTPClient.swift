//
//  APIClient.swift
//  CombineCollection
//
//

import Combine
import Foundation

protocol HTTPClient {
    func send(request: URLRequest) -> AnyPublisher<Data, Error>
}
