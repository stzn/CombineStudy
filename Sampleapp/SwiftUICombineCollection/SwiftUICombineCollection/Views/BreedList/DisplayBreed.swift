//
//  DisplayBreed.swift
//  SwiftUICombineCollection
//
//

import Foundation

struct DisplayBreed: Hashable {
    let name: String
    let displayName: String
    let subBreeds: [DisplayBreed]
    init(name: String, displayName: String,
         subBreeds: [DisplayBreed] = []) {
        self.name = name
        self.displayName = displayName
        self.subBreeds = subBreeds
    }
}

extension DisplayBreed: Identifiable {
    var id: Self { self }

    static var anyBreed: DisplayBreed {
        DisplayBreed(name: "child1", displayName: "child1")
    }

    #if DEBUG
    static var anyBreeds: [DisplayBreed] {
        [DisplayBreed(
            name: "parent", displayName: "parent",
            subBreeds: [
                DisplayBreed(name: "child1", displayName: "child1"),
                DisplayBreed(name: "child2", displayName: "child2"),
                DisplayBreed(name: "child3", displayName: "child3")
            ]
        )]
    }
    #endif
}
