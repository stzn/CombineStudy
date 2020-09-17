//
//  DogImage.swift
//  SwiftUICombineCollection
//
//

import Combine
import SwiftUI

struct BreedImageView: View {
    @Environment(\.injected) var container: DIContainer
    @StateObject var viewModel = BreedImageViewModel()

    private let dogImage: DogImage
    init(dogImage: DogImage) {
        self.dogImage = dogImage
    }

    var body: some View {
        content
            .onAppear {
                viewModel.fetch(from: dogImage.imageURL,
                            using: container.loaders.imageDataLoader)
            }
            .onDisappear {
                viewModel.cancel()
            }
    }

    @ViewBuilder
    private var content: some View {
        switch (viewModel.imageData, viewModel.error) {
        case (.none, .none):
            ProgressView("loading.....")
        case (let .some(data), .none):
            Image(uiImage: UIImage(data: data)!)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .clipped()
        default:
            Image(systemName: "xmark.octagon.fill")
        }
    }
}

struct DogImageView_Previews: PreviewProvider {
    static var previews: some View {
        BreedImageView(dogImage: .anyDogImage)
    }
}

