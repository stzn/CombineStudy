//: [Previous](@previous)

import Combine
import Foundation

var cancellables = Set<AnyCancellable>()

// 指定した時間後にOutputを出力する
run("delay") {
    let start = Date()
    let publisher = PassthroughSubject<Void, Never>()
    let delayPublisher = publisher.delay(for: 1.0, scheduler: DispatchQueue.main)

    publisher
        .sink(receiveValue: { _ in print("publisher: \(Date().timeIntervalSince(start))") })
        .store(in: &cancellables)

    delayPublisher
        .sink(receiveValue: { _ in print("delayPublisher: \(Date().timeIntervalSince(start))") })
        .store(in: &cancellables)

    publisher.send(())
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        publisher.send(())
    }
}
//: [Next](@next)
