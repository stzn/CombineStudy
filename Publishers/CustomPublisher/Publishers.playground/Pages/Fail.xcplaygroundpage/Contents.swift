//: [Previous](@previous)

import Combine
import Foundation
import PlaygroundSupport

var cancellables = Set<AnyCancellable>()

// Outputを出力しないですぐにComlpetion(Failure)を出力する
run("Fail") {
    struct SampleError: Error {}
    Fail<Int, Error>(error: SampleError())
        .sink(receiveCompletion: { finished in
            print("receivedCompletion: \(finished)")
        }, receiveValue: { value in
            print("receivedValue: \(value)")
        }).store(in: &cancellables)
}

PlaygroundPage.current.needsIndefiniteExecution = true

//: [Next](@next)
