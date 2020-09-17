//: [Previous](@previous)

import Foundation
import Combine

private var cancellables = Set<AnyCancellable>()

// nilの値を変換する
run("replaceNil") {
    [1,nil,nil,4].publisher
        .replaceNil(with: 999)
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value ?? 0)")
        })
        .store(in: &cancellables)
}

// EmptyなPublisherを変換する
run("replaceEmpty") {
    let empty = Empty<String, Never>()
    empty
        .replaceEmpty(with: "Empty")
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

//　現在の値と出力された値を使って新しい値を生成する
//　毎回の結果を出力する
run("scan") {
    (1...10).publisher
    .scan(0, +)
    .sink(receiveValue: { print("receiveValue: \($0)") })
    .store(in: &cancellables)
}

//　現在の値と出力された値を使って新しい値を生成する
//　最終結果を出力する
run("reduce") {
    (1...10).publisher
    .reduce(0, +)
    .sink(receiveValue: { print("receiveValue: \($0)") })
    .store(in: &cancellables)
}

run("multiple") {
    let publisher = ["1", "1", "one", "2", "2", "two", "3", "three"].publisher
    publisher
        .compactMap { Int($0) }
        .removeDuplicates()
        .filter { $0 > 1 }
        .map { $0 * 2 }
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}
//: [Next](@next)
