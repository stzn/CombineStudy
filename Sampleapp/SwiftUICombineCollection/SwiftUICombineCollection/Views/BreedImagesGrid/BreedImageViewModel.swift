//
//  BreedImageViewModel.swift
//  SwiftUICombineCollection
//
//

import Combine
import Foundation
import SwiftUI

final class BreedImageViewModel: ObservableObject {
    @Published var imageData: Data?
    @Published var error: Error?

    var cancellable: AnyCancellable?

    func fetch(from url: URL, using loader: ImageDataLoader) {
        cancellable = loader(url)
            .receiveOnMainQueue()
//            .receive(on: DispatchQueue.main)
            .sink { finished in
                if case .failure(let error) = finished {
                    self.imageData = nil
                    self.error = error
                }
            }
            receiveValue: { value in
                self.imageData = value
                self.error = nil
            }
    }

    func cancel() {
        cancellable?.cancel()
        cancellable = nil
    }
}
