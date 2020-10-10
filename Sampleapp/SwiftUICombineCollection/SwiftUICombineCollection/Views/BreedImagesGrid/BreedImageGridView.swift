//
//  BreedImageGridView.swift
//  SwiftUICombineCollection
//
//

import Combine
import SwiftUI

struct BreedImageGridView: View {
    @Environment(\.injected.loaders) var loaders: DIContainer.Loaders
    @StateObject var model = BreedImagesGridViewModel()

//    private let columns = [
//        GridItem(spacing: 4), GridItem(spacing: 4), GridItem(spacing: 4)
//    ]

    let breed: DisplayBreed

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                Grid(columns: 3, list: model.dogImages, width: proxy.size.width) { dogImgage in
                    BreedImageView(viewModel: ImageLoaderCache.shared.loaderFor(url: dogImgage.imageURL))
                }
            }
            .frame(width: proxy.size.width)
            .navigationTitle(navigationTitle)
            .onAppear {
                model.fetch(breedType: breed.name,
                            using: loaders.dogImageListLoader)
            }
        }
//        ScrollView {
//            LazyVStack {
//                ForEach(model.dogImages) { dogImage in
//                    BreedImageView(viewModel: ImageLoaderCache.shared.loaderFor(url: dogImage.imageURL))
//                }
//            }
//            .padding(.horizontal, 4)
//            .navigationTitle(navigationTitle)
//            Spacer()
//        }.onAppear {
//            model.fetch(breedType: breed.name,
//                        using: loaders.dogImageListLoader)
//        }
    }

    private var navigationTitle: String {
        var title = breed.name
        if let index = breed.name.lastIndex(where: { $0 == "/" }) {
            title = String(breed.name.suffix(from: breed.name.index(after: index)))
        }
        return title.uppercased()
    }
}

struct Grid<Content: View, T: Hashable>: View {
    private let columns: Int
    private let width: CGFloat
    private var list: [[T]] = []
    private let content: (T) -> Content

    init(columns: Int, list: [T], width: CGFloat, @ViewBuilder content:@escaping (T) -> Content) {
        self.columns = columns
        self.width = width
        self.content = content
        self.list = chunked(from: list, into: columns)
    }

    var body: some View {
        VStack {
            ForEach(0 ..< self.list.count, id: \.self) { i  in
                LazyHStack {
                    ForEach(self.list[i], id: \.self) { object in
                        self.content(object)
                            .frame(width: width/CGFloat(self.columns))
                    }
                }
                .frame(height: width/CGFloat(self.columns))
            }
        }
    }

    private func chunked(from list: [T], into size: Int) -> [[T]] {
        var chunked: [[T]] = []

        for index in 0..<list.count {
            if index % size == 0 && index != 0 {
                chunked.append(Array(list[(index - size)..<index]))
            } else if (index == list.count) {
                chunked.append(Array(list[index - 1..<index]))
            }
        }
        return chunked
    }
}

extension Array where Element == DogImage {
    fileprivate func chunked(into size: Int) -> [[Element]] {
        var chunked: [[Element]] = []

        for index in 0..<self.count {
            if index % size == 0 && index != 0 {
                chunked.append(Array(self[(index - size)..<index]))
            } else if (index == self.count) {
                chunked.append(Array(self[index - 1..<index]))
            }
        }
        return chunked
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

