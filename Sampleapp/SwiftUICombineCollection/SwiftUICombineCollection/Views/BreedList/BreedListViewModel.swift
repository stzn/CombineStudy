//
//  BreedListViewModel.swift
//  SwiftUICombineCollection
//
//

import Combine
import Foundation
import SwiftUI

final class BreedListViewModel: ObservableObject {
    @Published var breeds: [DisplayBreed] = []
    @Published var isLoading: Bool = false
    @Published var expansionStates: [DisplayBreed: Bool] = [:]

    func fetchList(using loader: BreedListLoader) {
        isLoading = true
        loader()
            .map { $0.sorted(by: { $0.name < $1.name }) }
            .map(makeDisplayModels(from:))
            .receiveOnMainQueue()
//            .receive(on: DispatchQueue.main)
            .replaceError(with: [])
            .handleEvents(receiveOutput: { _ in self.isLoading = false })
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

