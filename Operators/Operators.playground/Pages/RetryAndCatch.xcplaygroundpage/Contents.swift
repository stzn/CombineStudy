//: [Previous](@previous)

import Combine
import Foundation
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

var cancellables = Set<AnyCancellable>()

// 受け取ったOutputを変換して出力する
run("retry and catch") {
    let url = URL(string: "https://hogehogehoge.com")!
    var tryCount = 0
    URLSession.shared.dataTaskPublisher(for: url)
        .handleEvents(
            receiveSubscription: { _ in
                tryCount += 1
                print("Try\(tryCount)")
            },
            receiveCompletion: {
                guard case .failure(let error) = $0 else { return }
                print("Try\(tryCount) error: \(error)")
            }
        )
        .retry(3)
        .map(\.data)
        .catch { error in
            return Just(Data())
        }
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

//: [Next](@next)

