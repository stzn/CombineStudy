//: [Previous](@previous)

import Combine
import Foundation

var cancellables = Set<AnyCancellable>()

class ViewModel {
    var number: Int = 0 {
        didSet {
            print("receiveValue: \(number)")
        }
    }
}
let viewModel = ViewModel()
let publisher = [1,2,3].publisher
publisher
    .assign(to: \.number, on: viewModel)
    .store(in: &cancellables)

//: [Next](@next)
