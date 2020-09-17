//: [Previous](@previous)

import Combine
import Foundation
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

var cancellables = Set<AnyCancellable>()

// 新しいPublisherを受け取ると
// 前のPublisherはキャンセルして
// 最新のPublisherのOutputを出力する
// キャッシュのせいかもしれませんが繰り返すと下記はキャンセルされなくなります
run("switchToLatest") {
    final class API {
        func load() -> AnyPublisher<Data, URLError> {
            return URLSession.shared
                .dataTaskPublisher(for: URL(string: "https://dog.ceo/api/breeds/list/all")!)
                .map(\.data)
                .print("API call")
                .eraseToAnyPublisher()
        }
    }

    let api = API()
    let taps = PassthroughSubject<Void, Never>()

    taps
        .map { api.load() }
        .switchToLatest()
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)

    taps.send()

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        taps.send()
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        taps.send()
    }
}

//: [Next](@next)
