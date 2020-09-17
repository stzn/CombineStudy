//
//  ContentView.swift
//  SwiftUICombineCollection
//
//

import SwiftUI

struct ContentView: View {
    @Environment(\.injected) var container: DIContainer
    
    var body: some View {
        BreedListView()
            .environment(\.injected, container)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
