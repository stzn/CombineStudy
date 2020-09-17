//: [Previous](@previous)

import Combine
import Foundation

var cancellables = Set<AnyCancellable>()

// 値が返ってこないなどうまく動かなくない時に
// 何が起こっているのかを教えてくれます

// PubllisherとSubscriberの動作を出力する
// 1.PublisherからSubscriptionを受け取る
// 2.SubscriberからDemandの要求を受け取る
// 3.PublisherからOutputを受け取る
// (Subscriberから再度Demandの要求があれば出力される)
// 4.PublisherからCompletionを受け取る
run("print") {
    [1,2,3,4].publisher
        .print()
        .sink(receiveCompletion: { _ in },
              receiveValue: { _ in })
        .store(in: &cancellables)
}

// 第二引数にTextOutputStreamに適合したクラスを設定することで出力情報をカスタマイズできる
// 下記では開始してからの経過時間を出力している
run("print(_:to)") {
    final class TimelapseLogger: TextOutputStream {
        private let startTime: Date = Date()
        private lazy var numberFormatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 5
            formatter.maximumFractionDigits = 5
            return formatter
        }()

        func write(_ string: String) {
            guard !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return
            }
            let time = numberFormatter.string(for: Date().timeIntervalSince(startTime))!
            print("\(time)秒経過: \(string)")
        }
    }

    [1,2,3,4].publisher
        .print("pusblisher", to: TimelapseLogger())
        .sink(receiveCompletion: { _ in },
              receiveValue: { _ in })
        .store(in: &cancellables)
}

// 個々のイベントの途中で処理を入れることができる
// 主にメインの処理の中で副作用が必要な時に使用される(取得したデータをDBに保存するなど)
run("handleEvents") {
    [1,2,3,4].publisher
        .handleEvents(receiveSubscription: { print("handleEvents receiveSubscription: \($0)") },
                      receiveOutput: { print("handleEvents receiveOutput:: \($0)") },
                      receiveCompletion: { print("handleEvents receiveCompletion: \($0)") },
                      receiveCancel: { print("handleEvents receiveCancel") },
                      receiveRequest: { print("handleEvents receiveRequest: \($0)") })
        .sink( receiveCompletion: { print("sink receiveCompletion: \($0)") },
               receiveValue: { print("sink receiveValue: '\($0)'") })
        .store(in: &cancellables)
}

// Completion(failure)が出力された時にDebuggerが処理を中断する
// Playgroundではこれ以降の処理が動かなくなるのでコメントアウトしています
//run("breakpointOnError") {
//    struct MyError: Error {}
//    let publisher = PassthroughSubject<Void, Error>()
//    publisher
//        .breakpointOnError()
//        .sink(receiveCompletion: { print("sink receiveCompletion: \($0)") },
//              receiveValue: { print("sink receiveValue: '\($0)'") })
//        .store(in: &cancellables)
//    publisher.send(completion: .failure(MyError()))
//}

// 指定の条件に該当したOutputが出力された時にDebuggerが処理を中断する
// Playgroundではこれ以降の処理が動かなくなるのでコメントアウトしています
//run("breakpoint") {
//    let publisher = PassthroughSubject<Int, Never>()
//    publisher
//        .breakpoint(receiveOutput: { value in
//            return value == 2
//        })
//        .sink(receiveCompletion: { print("sink receiveCompletion: \($0)") },
//              receiveValue: { print("sink receiveValue: '\($0)'") })
//        .store(in: &cancellables)
//
//    publisher.send(1) // 中断しない
//    publisher.send(2)
//}

//: [Next](@next)
