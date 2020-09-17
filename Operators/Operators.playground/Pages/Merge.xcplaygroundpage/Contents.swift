//: [Previous](@previous)

import Combine
import Foundation

var cancellables = Set<AnyCancellable>()

// 2つのPublisherを結合して1つのPublisherとして出力する
// 2つのPublisherの型は一致していなければならない
run("merge") {
    let publisher1 = PassthroughSubject<Int, Never>()
    let publisher2 = PassthroughSubject<Int, Never>()

    publisher1
        .merge(with: publisher2)
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)

    publisher1.send(1)
    publisher2.send(2)
    publisher1.send(3)
    publisher2.send(4)
    publisher1.send(completion: .finished)
    publisher2.send(completion: .finished)
}

//: [Next](@next)
