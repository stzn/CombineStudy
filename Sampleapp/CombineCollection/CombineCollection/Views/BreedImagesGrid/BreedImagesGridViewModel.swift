//
//  BreedImagesGridViewModel.swift
//  CombineCollection
//
//

import Combine
import Foundation

final class BreedImagesGridViewModel {
    @Published private(set) var dogImages: [DogImage] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: Error? = nil

    private let loader: DogImageListLoader
    init(loader: DogImageListLoader) {
        self.loader = loader
    }

    func fetch(breedType: BreedType) {
        isLoading = true
        error = nil

        loader.load(breedType)
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveOutput: { [weak self] _ in
                    self?.isLoading = false
                },
                receiveCompletion: { [weak self] finished in
                    self?.isLoading = false
                    if case .failure(let error) = finished {
                        self?.error = error
                    }
                }
            )
            .replaceError(with: [])
            .assign(to: &$dogImages)
    }
}
