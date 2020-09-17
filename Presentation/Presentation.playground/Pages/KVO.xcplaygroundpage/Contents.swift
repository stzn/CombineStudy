//: [Previous](@previous)

import UIKit
import Combine

extension UIScrollView {
    var contentOffsetPublisher: AnyPublisher<CGPoint, Never> {
        publisher(for: \.contentOffset).eraseToAnyPublisher()
    }
}

//: [Next](@next)
