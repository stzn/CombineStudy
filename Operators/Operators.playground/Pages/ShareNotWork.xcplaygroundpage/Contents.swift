//: [Previous](@previous)

import Combine
import Foundation
import PlaygroundSupport

// MARK: - Share

// https://qiita.com/shiz/items/f089c93bdebfaef2196fhttps://qiita.com/shiz/items/f089c93bdebfaef2196f

private var cancellables = Set<AnyCancellable>()

// タイミングを遅らせると
// PublisherはCompletionを出力しているため
// Outputを取得できない
run("Share not work") {
    let shared = URLSession.shared
        .dataTaskPublisher(for: URL(string: "https://www.google.com")!)
        .map(\.data)
        .print("shared")
        .share()
    shared
        .sink( receiveCompletion: { print("subscription1 receiveCompletion \($0)") },
               receiveValue: { print("subscription1 receiveValue: '\($0)'") })
        .store(in: &cancellables)

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        shared
            .sink(receiveCompletion: { print("subscription2 receiveCompletion \($0)")},
                  receiveValue: { print("subscription2 receiveValue: '\($0)'") })
            .store(in: &cancellables)
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true

//: [Next](@next)
