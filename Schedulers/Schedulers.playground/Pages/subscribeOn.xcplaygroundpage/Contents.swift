//: [Previous](@previous)

import Combine
import Foundation

var cancellables = Set<AnyCancellable>()

// Threadを切り替えているため
// subscribe(on:)後の処理はMainThread以外で行われている
// Thread番号はDispatchQueueは最適なThreadを自動で選択するため動的に変わります
run("subscribe(on:)") {
    let queue = DispatchQueue(label: "subscrbeQueue\(UUID().uuidString)")

    print("start: \(Thread.current.number)")

    [1,2,3,4].publisher
        .subscribe(on: queue)
        .handleEvents(receiveSubscription: { _ in print("handleEvents receiveSubscription: \(Thread.current.number)") },
                      receiveOutput: { _ in print("handleEvents receiveOutput: \(Thread.current.number)") },
                      receiveCompletion: { _ in print("handleEvents receiveCompletion: \(Thread.current.number)") },
                      receiveCancel: { print("handleEvents receiveCancel: \(Thread.current.number)") },
                      receiveRequest: { _ in print("handleEvents receiveRequest: \(Thread.current.number)") })
        .sink { _ in print("sink receivedValue: \(Thread.current.number)") }
        .store(in: &cancellables)
}

//: [Next](@next)
