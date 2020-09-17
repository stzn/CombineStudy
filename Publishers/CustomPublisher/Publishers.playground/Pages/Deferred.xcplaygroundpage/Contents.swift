//: [Previous](@previous)

import Combine
import Foundation
import PlaygroundSupport

var cancellables = Set<AnyCancellable>()

// 処理が完了した時にResultを引数に受け取るコールバック(promise)を呼び出す
// DeferredはSubscribeされていないと内部の処理を実行しない
run("Deferred without Subscribe") {
    _ = Deferred {
        Future<Int, Error> { promise in
            sleep(1)
            print("executed")
            promise(.success(1))
        }
    }
}

// 処理が完了した時にResultを引数に受け取るコールバック(promise)を呼び出す
// DeferredはSubscribeされていないと内部の処理を実行しない
run("Deferred with Subscribe") {
    Deferred {
        Future<Int, Error> { promise in
            sleep(1)
            print("executed")
            promise(.success(2))
        }
    }
    .sink(receiveCompletion: { finished in
        print("receivedCompletion: \(finished)")
    }, receiveValue: { value in
        print("receivedValue: \(value)")
    }).store(in: &cancellables)
}

PlaygroundPage.current.needsIndefiniteExecution = true

//: [Next](@next)
