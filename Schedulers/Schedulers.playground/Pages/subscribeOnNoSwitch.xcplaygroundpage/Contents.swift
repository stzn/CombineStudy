//: [Previous](@previous)

import Combine
import Foundation

var cancellables = Set<AnyCancellable>()

// Threadの切り替えを行なっていないため
// 全ての処理はMainThreadで行われている(Playgroundでは)
run("subscribe(on:) Thread切り替えなし") {
    print("start: \(Thread.current.number)")

    [1,2,3,4].publisher
        .handleEvents(receiveSubscription: { _ in print("handleEvents receiveSubscription: \(Thread.current.number)") },
                      receiveOutput: { _ in print("handleEvents receiveOutput: \(Thread.current.number)") },
                      receiveCompletion: { _ in print("handleEvents receiveCompletion: \(Thread.current.number)") },
                      receiveCancel: { print("handleEvents receiveCancel: \(Thread.current.number)") },
                      receiveRequest: { _ in print("handleEvents receiveRequest: \(Thread.current.number)") })
        .sink { _ in print("sink receivedValue: \(Thread.current.number)") }
        .store(in: &cancellables)
}

//: [Next](@next)
