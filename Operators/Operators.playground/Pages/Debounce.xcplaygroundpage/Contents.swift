//: [Previous](@previous)

import Combine
import Foundation

var cancellables = Set<AnyCancellable>()

// 最後のOutputが出力されてから指定の時間経過までに
// 新しくOutputが出力されていなければその値を出力する
// debounceの待機時間中にCompletionが出力されると最後のOutputは出力されません
run("debounce") {
    let startDate = Date()
    let publisher = PassthroughSubject<String, Never>()
    publisher
        .print()
        .debounce(for: 1.0, scheduler: DispatchQueue.main)
        .sink(receiveValue: { value in
                print("Time: \(Date().timeIntervalSince(startDate))")
                print("Value: \(value)")
        })
        .store(in: &cancellables)

    let start = DispatchTime.now()
    publisher.send("こ")
    DispatchQueue.main.asyncAfter(deadline: start + 0.5) {
        publisher.send("こん")
    }
    DispatchQueue.main.asyncAfter(deadline: start + 1.0) {
        publisher.send("こんに")
    }
    DispatchQueue.main.asyncAfter(deadline: start + 3.0) {
        publisher.send("こんにち")
    }
    DispatchQueue.main.asyncAfter(deadline: start + 3.5) {
        publisher.send("こんにちわ")
    }
}

//: [Next](@next)
