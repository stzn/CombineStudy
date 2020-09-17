//
//  BreedRow.swift
//  SwiftUICombineCollection
//
//

import SwiftUI

struct BreedRow: View {
    @Environment(\.colorScheme) var colorScheme

    let breed: DisplayBreed
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            content
        }
    }

    @ViewBuilder
    var content: some View {
        if breed.subBreeds.isEmpty {
            HStack {
                Text(breed.displayName)
                    .font(.headline)
                    .padding([.leading], 8)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
        } else {
            HStack {
                Text(breed.displayName)
                    .font(.headline)
            }
        }
    }
}

struct BreedRow_Previews: PreviewProvider {
    static var previews: some View {
        let breed = Breed.anyBreed
        BreedRow(breed: DisplayBreed(name: breed.name, displayName: breed.name, subBreeds: []))
    }
}
