//: [Previous](@previous)

import Combine
import Foundation
import PlaygroundSupport

var cancellables = Set<AnyCancellable>()

// 処理が完了した時にResultを引数に受け取るコールバック(promise)を呼び出す
// Outputを流したらすぐにCompletionを出力する
// FutureはSubscribeされていないくても内部の処理を実行する
run("Future with Subscribe") {
    Future<Int, Error> { promise in
        sleep(1)
        print("executed")
        promise(.success(1))
    }
    .sink(receiveCompletion: { finished in
        print("receivedCompletion: \(finished)")
    }, receiveValue: { value in
        print("receivedValue: \(value)")
    }).store(in: &cancellables)
}

// 処理が完了した時にResultを引数に受け取るコールバック(promise)を呼び出す
// FutureはSubscribeされていないくても内部の処理を実行する
run("Future without Subscribe") {
    _ = Future<Int, Error> { promise in
        sleep(1)
        print("executed")
        promise(.success(2))
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true

//: [Next](@next)
