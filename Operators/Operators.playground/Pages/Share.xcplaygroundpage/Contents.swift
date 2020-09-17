//: [Previous](@previous)

import Combine
import Foundation
import PlaygroundSupport

// MARK: - Share

private var cancellables = Set<AnyCancellable>()

// 新しいPublisherを毎回生成するのではなく
// 同じPublisherからの出力を複数のSubscriberで共有できるようにする
// Subscriptionは一度しか行われていない
// Tip: ``Publishers/Share`` is effectively a combination of the ``Publishers/Multicast`` and ``PassthroughSubject`` publishers, with an implicit ``ConnectablePublisher/autoconnect()``.
run("Share") {

    let pub = (1...3).publisher
        .delay(for: 1, scheduler: DispatchQueue.main)
        .map( { _ in return Int.random(in: 0...100) } )
        .print("Random")
        .share()

    pub
        .sink { print ("Stream 1 received: \($0)")}
        .store(in: &cancellables)
    pub
        .sink { print ("Stream 2 received: \($0)")}
        .store(in: &cancellables)
}

PlaygroundPage.current.needsIndefiniteExecution = true

//: [Next](@next)
