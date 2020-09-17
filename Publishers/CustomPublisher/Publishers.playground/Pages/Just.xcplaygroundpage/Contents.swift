//: [Previous](@previous)

import Combine
import Foundation
import PlaygroundSupport

var cancellables = Set<AnyCancellable>()

// Outputを出力して後にすぐにCompletionを出力する
run("Just") {
    let just = Just(1)
    just
        .sink(receiveCompletion: { finished in
            print("receivedCompletion: \(finished)")
        }, receiveValue: { value in
            print("receivedValue: \(value)")
        }).store(in: &cancellables)

    just
        .sink(receiveCompletion: { finished in
            print("receivedCompletion(2): \(finished)")
        }, receiveValue: { value in
            print("receivedValue(2): \(value)")
        }).store(in: &cancellables)
}

PlaygroundPage.current.needsIndefiniteExecution = true

//: [Next](@next)
