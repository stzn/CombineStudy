//: [Previous](@previous)

import Combine
import Foundation
import PlaygroundSupport

// MARK: - Multicast

private var cancellables = Set<AnyCancellable>()

// Shareと同様に新しいPublisherを毎回生成するのではなく
// 同じPublisherからの出力を複数のSubscriberで共有できるようにする
// Subscriptionは一度しか行われない
// さらにconnectを呼ぶまで値の出力をしないので出力の開始タイミングをコントロールできる
// makeConnectableはFailureがNeverの時にのみ利用できる
run("Multicast makeConnectable") {
    let subject = PassthroughSubject<Int, Never>()
    let pub = (1...3).publisher
        .delay(for: 1, scheduler: DispatchQueue.main)
        .map( { _ in return Int.random(in: 0...100) } )
        .print()
        .share()
        .makeConnectable()

    pub.sink { print ("Stream 1 received: \($0)")  }
        .store(in: &cancellables)

    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        pub.sink { print ("Stream 2 received: \($0)") }
            .store(in: &cancellables)
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        pub.connect()
            .store(in: &cancellables)
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true

//: [Next](@next)
