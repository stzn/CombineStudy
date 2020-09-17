//: [Previous](@previous)

import Combine
import Foundation

class ViewModel {
    @Published var isIdValid: Bool = false
    @Published var isPasswordValid: Bool = false
    @Published var isPasswordConfirmValid: Bool = false
}

let viewModel = ViewModel()

func isValid(viewModel: ViewModel)
-> AnyPublisher<Bool, Never> {
    Publishers
        .CombineLatest3(viewModel.$isIdValid,
                        viewModel.$isPasswordValid,
                        viewModel.$isPasswordConfirmValid)
        .map { $0 && $1 && $2 }
        .eraseToAnyPublisher()
}


//: [Next](@next)
