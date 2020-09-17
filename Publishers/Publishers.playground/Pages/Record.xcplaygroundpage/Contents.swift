//: [Previous](@previous)

import Combine
import Foundation
import PlaygroundSupport

var cancellables = Set<AnyCancellable>()

// OutputとCompletionを記録しておき
// Subscribeされると全ての値を出力する
// テスト目的で利用されることが多い
run("Record") {
    let record = Record<Int, Error>(output: [1,2,3,4], completion: .finished)
    record
        .sink(receiveCompletion: { finished in
            print("receivedCompletion: \(finished)")
        }, receiveValue: { value in
            print("receivedValue: \(value)")
        })
        .store(in: &cancellables)
}

PlaygroundPage.current.needsIndefiniteExecution = true

//: [Next](@next)
