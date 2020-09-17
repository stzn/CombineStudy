//: [Previous](@previous)

import Combine
import Foundation

var cancellables = Set<AnyCancellable>()

// 最後のOutputが出力されてから指定の時間経過後に
// 待機中に出力された(※最初または最後の値)を出力する(※latestの設定によるはずですが今はどちらの値を指定しても同じ値が出力されるので調査中です)
// 最後に出力された値から新しくOutputが出力されていなければ何も出力しない
// throttleの待機時間中にCompletionが出力されると最後のOutputは出力されません
run("measureInterval") {
    let publisher = PassthroughSubject<Void, Never>()
    publisher
        .measureInterval(using: DispatchQueue.main)
        .sink(receiveValue: {
            print("Measure emitted: \(Double($0.magnitude) / 1_000_000_000.0)")
        })
        .store(in: &cancellables)

    let start = DispatchTime.now()
    DispatchQueue.main.asyncAfter(deadline: start + 0.5) {
        publisher.send()
    }
    DispatchQueue.main.asyncAfter(deadline: start + 1.0) {
        publisher.send()
    }
    DispatchQueue.main.asyncAfter(deadline: start + 3.0) {
        publisher.send()
    }
    DispatchQueue.main.asyncAfter(deadline: start + 3.5) {
        publisher.send()
    }
}

//: [Next](@next)
