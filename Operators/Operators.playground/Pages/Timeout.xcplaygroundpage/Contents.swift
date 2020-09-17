//: [Previous](@previous)

import Combine
import Foundation

var cancellables = Set<AnyCancellable>()

// 最後のOutputが出力されてから指定の時間経過後にCompletionする
run("timeout") {
    let publisher = PassthroughSubject<Void, Never>()
    publisher
        .timeout(2.0, scheduler: DispatchQueue.main)
        .sink(receiveCompletion: { _ in print("Completion") },
              receiveValue: { _ in print("Value") })
        .store(in: &cancellables)

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        publisher.send()
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
        publisher.send()
    }
}
//: [Next](@next)
