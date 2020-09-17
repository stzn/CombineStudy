//: [Previous](@previous)

import Combine
import Foundation

var cancellables = Set<AnyCancellable>()

// 2つのPublisherを結合して1つのPublisherを生成し
// それぞれの最新の値をTupleにしたものをOutputとして出力する
// それぞれが値を出力して初めてOutputを始める
// それぞれのPublisherの出力数に合わせてOutput出力する(CombineLatestと異なる)
// 下記の場合(1, "one")(2, "two")(3, "three")は出力されるが(4, "three")は出力されない
run("zip") {
    let publisher1 = PassthroughSubject<Int, Never>()
    let publisher2 = PassthroughSubject<String, Never>()

    publisher1
        .zip(publisher2)
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)

    publisher1.send(1)
    publisher2.send("one")
    publisher1.send(2)
    publisher2.send("two")
    publisher2.send("three")
    publisher1.send(3)
    publisher1.send(4)
    publisher1.send(completion: .finished)
    publisher2.send(completion: .finished)
}

//: [Next](@next)
