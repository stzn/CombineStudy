//
//  Preview.swift
//  CoreLocationCombine
//
//

import SwiftUI

struct Preview<Content: View>: View {
    private let content: Content
    init(_ content: Content) {
        self.content = content
    }

    private let devices = [
        "iPhone SE",
        "iPhone 11",
        "iPad Pro (11-inch) (2nd generation)",
    ]

    var body: some View {
        ForEach(devices, id: \.self) { name in
            Group {
                self.content
                    .previewDevice(PreviewDevice(rawValue: name))
                    .previewDisplayName(name)
                    .colorScheme(.light)
                self.content
                    .previewDevice(PreviewDevice(rawValue: name))
                    .previewDisplayName(name)
                    .colorScheme(.dark)
            }
        }
    }
}
