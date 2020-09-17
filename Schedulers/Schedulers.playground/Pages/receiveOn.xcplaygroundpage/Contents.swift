//: [Previous](@previous)

import Combine
import Foundation

var cancellables = Set<AnyCancellable>()

// Threadを切り替えているため
// subscribe(on:)後の処理はMainThread以外で行われ
// さらにreceive(on:)を呼ぶことで再びMainThreadで処理が行われている
// receive(on:)以降は全てMainThreadで処理が行われている
// Thread番号はDispatchQueueは最適なThreadを自動で選択するため動的に変わります
run("receive(on:)") {
    let queue = DispatchQueue(label: "subscrbeQueue\(UUID().uuidString)")

    print("start: \(Thread.current.number)")

    [1,2,3,4].publisher
        .subscribe(on: queue)
        .handleEvents(receiveSubscription: { _ in print("before receive(on:) handleEvents receiveSubscription: \(Thread.current.number)") },
                      receiveOutput: { _ in print("before receive(on:) handleEvents receiveOutput: \(Thread.current.number)") },
                      receiveCompletion: { _ in print("before receive(on:) handleEvents receiveCompletion: \(Thread.current.number)") },
                      receiveCancel: { print("before receive(on:) handleEvents receiveCancel: \(Thread.current.number)") },
                      receiveRequest: { _ in print("before receive(on:) handleEvents receiveRequest: \(Thread.current.number)") })
        .receive(on: DispatchQueue.main)
        .handleEvents(receiveOutput: { _ in print("after receive(on:) handleEvents receiveOutput: \(Thread.current.number)") },
                      receiveCompletion: { _ in print("after receive(on:)handleEvents receiveCompletion: \(Thread.current.number)") })
        .sink { _ in print("sink receivedValue: \(Thread.current.number)") }
        .store(in: &cancellables)
}

//: [Next](@next)
