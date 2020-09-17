//: [Previous](@previous)

import Combine
import Foundation

var cancellables = Set<AnyCancellable>()

// 指定した数のOutputの出力をスキップする
run("dropFirst") {
    [1,2,3,4,5].publisher
        .dropFirst(2)
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

// 指定した条件に該当しないOutputが見つかるまでOutputをスキップする
run("drop(while:)") {
    [1,2,3,4,5].publisher
        .drop(while: { $0 < 3 })
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

// 指定したPublisherが出力するまでOutputをスキップする
run("drop(untilOutputForm:)") {
    let start = PassthroughSubject<Void, Never>()
    let output = PassthroughSubject<Int, Never>()
    output
        .drop(untilOutputFrom: start)
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
