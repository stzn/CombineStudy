//: [Previous](@previous)

import PlaygroundSupport
import Foundation
import Combine

let urls: [URL] = "... この文字順通りに出力されます"
    .map(String.init).compactMap { (parameter) in
        var components = URLComponents()
        components.scheme = "https"
        components.path = "postman-echo.com/get"
        components.queryItems = [URLQueryItem(name: parameter, value: nil)]
        return components.url
}
struct Postman: Decodable {
    var args: [String: String]
}

var stream = ""
let s = urls.compactMap { value in
    URLSession.shared.dataTaskPublisher(for: value)
    .tryMap { data, response -> Data in
        return data
    }
    .decode(type: Postman.self, decoder: JSONDecoder())
    .catch {_ in
        Just(Postman(args: [:]))
    }
}
.publisher
.flatMap(maxPublishers: .max(1)){$0}
.sink(receiveCompletion: { (c) in
    print(stream)
}, receiveValue: { (postman) in
    print(postman.args.keys.joined(), terminator: "", to: &stream)
})

extension Collection where Element: Publisher {
    func serialize() -> AnyPublisher<Element.Output, Element.Failure>? {
        guard let start = self.first else { return nil }
        return self.dropFirst().reduce(start.eraseToAnyPublisher()) {
            return $0.append($1).eraseToAnyPublisher()
        }
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true

//: [Next](@next)
