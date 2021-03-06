//: [Previous](@previous)

import Combine
import Foundation

var cancellables = Set<AnyCancellable>()

// 指定した時間経過または指定した個数が出力された時点でOutputをまとめて出力する
run("collectByTimeOrCount") {
    let startDate = Date()
    let publisher = PassthroughSubject<Int, Never>()
    publisher.collect(.byTimeOrCount(DispatchQueue.main, 2.0, 2))
        .sink(receiveValue: { value in
                print("receiveTime: \(Date().timeIntervalSince(startDate))")
                print("receiveValue: \(value)")
        })
        .store(in: &cancellables)

    let start = DispatchTime.now()
    publisher.send(1)
    DispatchQueue.main.asyncAfter(deadline: start + 0.5) {
        publisher.send(2)
    }
    DispatchQueue.main.asyncAfter(deadline: start + 1.0) {
        publisher.send(3)
    }
    DispatchQueue.main.asyncAfter(deadline: start + 1.5) {
        publisher.send(4)
    }
    DispatchQueue.main.asyncAfter(deadline: start + 2.0) {
        publisher.send(5)
    }

}

//: [Next](@next)
