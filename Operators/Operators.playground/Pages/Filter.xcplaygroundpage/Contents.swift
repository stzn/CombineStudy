//: [Previous](@previous)

import Combine
import Foundation

var cancellables = Set<AnyCancellable>()

// 条件にあったOutputのみ出力する
run("filter") {
    [1,2,3,4,5].publisher
        .filter { $0.isMultiple(of: 2) }
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

// 重複を除外する
run("removeDuplicate") {
    [1,2,2,3,4,3,5].publisher
        .removeDuplicates()
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

// nilを除外する
run("compactMap") {
    ["1","one","2","two","3","three"].publisher
        .compactMap { Int($0) }
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

// Outputを無視してCompletionのみを出力する
run("ignoreOutput") {
    [1,2,3,4,5,6].publisher
        .ignoreOutput()
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

//: [Next](@next)
