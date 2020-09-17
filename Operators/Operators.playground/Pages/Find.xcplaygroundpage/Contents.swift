//: [Previous](@previous)

import Combine
import Foundation

var cancellables = Set<AnyCancellable>()

// 条件にあった最初のOutputのみ出力する
// 該当するOutputが見つかるとcancelされる
run("first") {
    [1,2,3,4,5].publisher
        .print()
        //        .first(where: { $0.isMultiple(of: 2) })
        .first { $0.isMultiple(of: 2) }
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

// 条件にあった最後のOutputのみ出力する
// 該当するOutputが見つかってもOutputはcancelされない
run("last") {
    [1,2,3,4,5].publisher
        .print()
        //        .last(where: { $0.isMultiple(of: 2) })
        .last { $0.isMultiple(of: 2) }
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

//: [Next](@next)
