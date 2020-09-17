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
    private let scheduler: AnySchedulerOf<DispatchQueue>
    init(loader: DogImageListLoader,
         scheduler: AnySchedulerOf<DispatchQueue>) {
        self.loader = loader
        self.scheduler = scheduler
    }

    func fetch(breedType: BreedType) {
        isLoading = true
        error = nil

        loader.load(breedType)
            .replaceError(with: [])
            .receive(on: self.scheduler)
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
            .assign(to: &$dogImages)
    }
}
