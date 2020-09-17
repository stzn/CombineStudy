//
//  BreedListView.swift
//  SwiftUICombineCollection
//
//

import Combine
import SwiftUI

struct BreedListView: View {
    @Environment(\.injected) var container: DIContainer
    @StateObject var viewModel = BreedListViewModel()

    var body: some View {
        NavigationView {
            content
                .navigationTitle("BreedList")
        }
        .onAppear {
            viewModel.fetchList(using: container.loaders.breedListLoader)
        }
    }

    @ViewBuilder
    private var content: some View {
        if !viewModel.isLoading {
            breedList(viewModel.breeds)
        } else {
            ProgressView("loading")
        }
    }

    private func breedList(_ breeds: [DisplayBreed]) -> some View {
        ScrollView {
            ForEach(breeds) { breed in
                // TODO: Lazyにすると非常に重い
                VStack(alignment: .leading, spacing: 8) {
                    DisclosureGroup(isExpanded: isExpanded(breed)) {
                        ForEach(breed.subBreeds, content: childBreed)
                    }
                    label: {
                        parent(breed.displayName)
                    }
                    Divider()
                }
            }
            .padding(.horizontal)
        }
    }

    private func isExpanded(_ breed: DisplayBreed) -> Binding<Bool> {
        Binding(get: { viewModel.expansionStates[breed, default: true] },
                set: { viewModel.expansionStates[breed] = $0 })
    }

    private func parent(_ name: String) -> some View {
        Text(name)
            .font(.title2)
            .padding(.vertical)
    }

    private func childBreedList(children: [DisplayBreed]) -> some View {
        ForEach(children, content: childBreed)
    }

    private func childBreed(_ breed: DisplayBreed) -> some View {
        NavigationLink(destination: BreedImageGridView(breed: breed)) {
            VStack {
                BreedRow(breed: breed)
                    .padding(.vertical)
            }
        }.buttonStyle(PlainButtonStyle())
    }
}

struct BreedListView_Previews: PreviewProvider {
    private static let devices = [
        "iPhone SE",
        "iPhone 11",
        "iPad Pro (11-inch) (2nd generation)",
    ]

    static var previews: some View {
        ForEach(devices, id: \.self) { name in
            Group {
                BreedListView()
                    .previewDevice(PreviewDevice(rawValue: name))
                    .previewDisplayName(name)
                    .colorScheme(.light)
            }
        }
    }
}
