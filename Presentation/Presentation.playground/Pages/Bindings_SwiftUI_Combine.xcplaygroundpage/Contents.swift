//: [Previous](@previous)

import SwiftUI
import Combine
import PlaygroundSupport

struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    @State var width: CGFloat = 0
    var body: some View {
        VStack(spacing: 8) {
            Text(viewModel.id ?? "")
                .background(GeometryReader { proxy in
                    Color.clear.preference(
                        key: TextWidthPreferenceKey.self,
                        value: proxy.size.width
                )
            })
            Button {
                viewModel.setNewID()
            }
            label: {
                Text("update")
                    .foregroundColor(Color.white)
                    .frame(width: width)
                    .background(Color.blue)
            }
        }
        .onPreferenceChange(TextWidthPreferenceKey.self) {
            width = $0
        }
    }
}

final class ViewModel: ObservableObject {
    @Published var id: String? = UUID().uuidString
    func setNewID() {
        id = UUID().uuidString
    }
}


private struct TextWidthPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat,
                       nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

let nav = UINavigationController(
    rootViewController: UIHostingController(rootView: ContentView()))

PlaygroundPage.current.liveView = nav

//: [Next](@next)
