//
//  BreedImagesGridViewModel.swift
//  SwiftUICombineCollection
//
//

import Combine
import Foundation
import SwiftUI

final class BreedImagesGridViewModel: ObservableObject {
    @Published var dogImages: [DogImage] = []

    func fetch(breedType: BreedType, using loader: DogImageListLoader) {
        loader
            .load(breedType)
            .replaceError(with: [])
            .receiveOnMainQueue()
            .assign(to: &$dogImages)
    }
}
