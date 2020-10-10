//
//  DogImage.swift
//  SwiftUICombineCollection
//
//

import Combine
import SwiftUI

struct BreedImageView: View {
    @ObservedObject var viewModel: BreedImageViewModel

    init(viewModel: BreedImageViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        content
            .onAppear {
                viewModel.fetch()
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
        BreedImageView(viewModel: .init(url: URL(string: "https://any-url.com")!, loader: {
            _ in Just(UIImage(systemName: "xmark.octagon.fill")!.pngData()!)
                .setFailureType(to: Error.self).eraseToAnyPublisher()
        }))
    }
}


