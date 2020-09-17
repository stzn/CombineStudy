//
//  BreedListViewModel.swift
//  CombineCollection
//
//

import Combine
import Foundation

final class BreedListViewModel {
    @Published private(set) var breeds: [DisplayBreed] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: Error? = nil

    private let loader: BreedListLoader
    init(loader: BreedListLoader) {
        self.loader = loader
    }

    func fetchList() {
        isLoading = true
        error = nil

        loader.load()
            .map { $0.sorted(by: { $0.name < $1.name }) }
            .map(makeDisplayModels(from:))
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
            .assign(to: &$breeds)
    }

    func makeDisplayModels(from breeds: [Breed]) -> [DisplayBreed] {
        breeds.map(makeDisplayModel(from:))
    }

    private func makeDisplayModel(from breed: Breed) -> DisplayBreed {
        let children = breed.subBreeds
            .map { DisplayBreed(name: "\(breed.name)/\($0.name)", displayName: $0.name.uppercased())
        }
        let allKindsItem = DisplayBreed(name: breed.name, displayName: "\(breed.name.uppercased())の全種別")
        return DisplayBreed(name: breed.name, displayName: breed.name.uppercased(),
                            subBreeds: [allKindsItem] + children)
    }
}
