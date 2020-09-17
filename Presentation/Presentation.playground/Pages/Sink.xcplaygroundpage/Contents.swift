//: [Previous](@previous)

import Combine
import Foundation
var cancellables = Set<AnyCancellable>()
let publisher = [1,2,3].publisher
let subscription = publisher.sink(
    receiveCompletion: { finished in
        print("receiveCompletion: \(finished)")
    },
    receiveValue: { value in
        print("receiveValue: \(value)")
    })

publisher.sink(
    receiveCompletion: { finished in
        print("receiveCompletion: \(finished)")
    },
    receiveValue: { value in
        print("receiveValue: \(value)")
    }).store(in: &cancellables)

//: [Next](@next)
