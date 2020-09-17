//: [Previous](@previous)

import Combine
import Foundation

var cancellables = Set<AnyCancellable>()

// 既存のPublisherがOutputを出力する前にOutputを出力する
// 繰り返すと後に追加した方から出力される
run("append") {
    [3,4,5].publisher
        .append(1,2)
        .append(-1,0)
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

// ArrayやSetなどのSequenceも追加できる
// Setは順不同なので結果が変わります
run("append(Sequence)") {
    [3,4,5].publisher
        .append([1,2])
        .append(Set(-1...0))
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

// Publisherも追加できる
run("append(Publisher)") {
    let publisher2 = [1, 2].publisher
    let publisher1 = [3, 4, 5].publisher
    publisher1
        .append(publisher2)
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

// Publisheが動的な場合
// PublisherからCompletion(finished)が出力されるまで
// 次のPublisherからOutputは出力されない
run("append(Publisher)_NotEmitOutput") {
    let publisher1 = [3, 4, 5].publisher
    let publisher2 = PassthroughSubject<Int, Never>()
    publisher2
        .append(publisher1)
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
    publisher2.send(1)
    publisher2.send(2)
}

run("append(Publisher)_EmitOutput") {
    let publisher1 = [3, 4, 5].publisher
    let publisher2 = PassthroughSubject<Int, Never>()
    publisher2
        .append(publisher1)
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
