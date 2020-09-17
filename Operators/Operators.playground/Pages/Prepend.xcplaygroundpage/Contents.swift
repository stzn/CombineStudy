//: [Previous](@previous)

import Combine
import Foundation

var cancellables = Set<AnyCancellable>()

// 既存のPublisherがOutputを出力する前にOutputを出力する
// 繰り返すと後に追加した方から出力される
run("prepend") {
    [3,4,5].publisher
        .prepend(1,2)
        .prepend(-1,0)
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

// ArrayやSetなどのSequenceも追加できる
// Setは順不同なので結果が変わります
run("prepend(Sequence)") {
    [3,4,5].publisher
        .prepend([1,2])
        .prepend(Set(-1...0))
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

// Publisherも追加できる
run("prepend(Publisher)") {
    let publisher2 = [1, 2].publisher
    let publisher1 = [3, 4, 5].publisher
    publisher1
        .prepend(publisher2)
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

// Publisheが動的な場合
// 追加されたPublisherからCompletion(finished)が出力されるまで
// 次のPublisherからOutputは出力されない
run("prepend(Publisher)_NotEmitOutput") {
    let publisher1 = [3, 4, 5].publisher
    let publisher2 = PassthroughSubject<Int, Never>()
    publisher1
        .prepend(publisher2)
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
    publisher2.send(1)
    publisher2.send(2)
}

run("prepend(Publisher)_EmitOutput") {
    let publisher1 = [3, 4, 5].publisher
    let publisher2 = PassthroughSubject<Int, Never>()
    publisher1
        .prepend(publisher2)
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
    publisher2.send(1)
    publisher2.send(2)
    publisher2.send(completion: .finished)
}

//: [Next](@next)
