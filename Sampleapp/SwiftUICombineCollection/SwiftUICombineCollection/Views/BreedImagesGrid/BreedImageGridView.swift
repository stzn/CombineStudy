//
//  BreedImageGridView.swift
//  SwiftUICombineCollection
//
//

import Combine
import SwiftUI

private let columns = [
    GridItem(spacing: 4), GridItem(spacing: 4), GridItem(spacing: 4)
]

struct BreedImageGridView: View {
    @Environment(\.injected) var container: DIContainer
    @StateObject var model = BreedImagesGridViewModel()

    let breed: DisplayBreed

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(model.dogImages) { dogImage in
                    BreedImageView(dogImage: dogImage)
                }
            }
            .padding(.horizontal, 4)
            .navigationTitle(navigationTitle)
            Spacer()
        }.onAppear {
            model.fetch(breedType: breed.name,
                        using: container.loaders.dogImageListLoader)
        }
    }

    private var navigationTitle: String {
        var title = breed.name
        if let index = breed.name.lastIndex(where: { $0 == "/" }) {
            title = String(breed.name.suffix(from: breed.name.index(after: index)))
        }
        return title.uppercased()
    }
}

struct BreedImageGridView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BreedImageGridView(breed: DisplayBreed.anyBreed)
                .environment(\.injected, .stub)
        }
    }
}

