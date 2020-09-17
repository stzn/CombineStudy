//: [Previous](@previous)

import Combine
import Foundation

var cancellables = Set<AnyCancellable>()

// 最後のOutputが出力されてから指定の時間経過後にCompletion(failure)する
run("timeout error") {
    enum TimeoutError: Error {
        case timeout
    }

    let publisher = PassthroughSubject<Void, TimeoutError>()
    publisher
        .timeout(2.0, scheduler: DispatchQueue.main, customError: { .timeout })
        .sink(receiveCompletion: { print("Completion:\($0)") },
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
