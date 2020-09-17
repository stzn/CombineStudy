//
//  ImageDataLoader.swift
//  SwiftUICombineCollection
//
//

import Combine
import Foundation
import UIKit

struct ImageDataLoader {
    let load: (URL) -> AnyPublisher<Data, Error>
}

#if DEBUG
extension ImageDataLoader {
    static var stub = ImageDataLoader { _ in
        Just(UIImage(systemName: "xmark.circle.fill")!.pngData()!)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
#endif
