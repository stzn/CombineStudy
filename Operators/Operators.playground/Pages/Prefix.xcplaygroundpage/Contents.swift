//: [Previous](@previous)

import Combine
import Foundation

var cancellables = Set<AnyCancellable>()

// 指定した数のOutputを出力する
run("prefix") {
    [1,2,3,4,5].publisher
        .prefix(2)
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

// 指定した条件に該当しないOutputが出力されるまでOutputを出力する
run("prefix(while:)") {
    [1,2,3,4,5].publisher
        .prefix(while: { $0 < 2 })
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

// 指定したPublisherが出力するまでOutputを出力する
run("prefix(untilOutputForm:)") {
    let start = PassthroughSubject<Void, Never>()
    let output = PassthroughSubject<Int, Never>()
    output
        .prefix(untilOutputFrom: start)
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)

    output.send(1)
    output.send(2)
    output.send(3)

    start.send(())

    output.send(4)
}

//: [Next](@next)
