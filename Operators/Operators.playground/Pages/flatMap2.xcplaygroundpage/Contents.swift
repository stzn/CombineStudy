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

//let collection = urls.compactMap { value in
//        URLSession.shared.dataTaskPublisher(for: value)
//        .tryMap { data, response -> Data in
//            return data
//        }
//        .decode(type: Postman.self, decoder: JSONDecoder())
//        .catch {_ in
//            Just(Postman(args: [:]))
//    }
//}
//
extension Collection where Element: Publisher {
    func serialize() -> AnyPublisher<Element.Output, Element.Failure>? {
        guard let start = self.first else { return nil }
        return self.dropFirst().reduce(start.eraseToAnyPublisher()) {
            return $0.append($1).eraseToAnyPublisher()
        }
    }
}
//
//var streamA = ""
////let A = collection
////    .publisher.flatMap{$0}
////
////    .sink(receiveCompletion: { (c) in
////        print(streamA, "     ", c, "    .publisher.flatMap{$0}")
////    }, receiveValue: { (postman) in
////        print(postman.args.keys.joined(), terminator: "", to: &streamA)
////    })
////
//
//var streamC = ""
//let C = collection
//    .serialize()?
//
//    .sink(receiveCompletion: { (c) in
//        print(streamC, "     ", c, "    .serialize()?")
//    }, receiveValue: { (postman) in
//        print(postman.args.keys.joined(), terminator: "", to: &streamC)
//    })
//
//var streamD = ""
//let D = collection
//    .publisher
//    .flatMap(maxPublishers: .max(1)){$0}
//
//    .sink(receiveCompletion: { (c) in
//        print(streamD, "     ", c, "    .publisher.flatMap(maxPublishers: .max(1)){$0}")
//    }, receiveValue: { (postman) in
//        print(postman.args.keys.joined(), terminator: "", to: &streamD)
//    })

PlaygroundPage.current.needsIndefiniteExecution = true

//let sequencePublisher = Publishers.Sequence<Range<Int>, Never>(sequence: 0..<Int.max)
//let subject = PassthroughSubject<String, Never>()
//
//let handle = subject
//    .zip(sequencePublisher)
//    //.publish
//    .flatMap(maxPublishers: .max(1), { (pair)  in
//        Just(pair)
//    })
////    .print()
//    .sink { letters, digits in
//        print(letters, digits)
//    }
//
//"Hello World!".map(String.init).forEach { (s) in
//    subject.send(s)
//}
//subject.send(completion: .finished)

