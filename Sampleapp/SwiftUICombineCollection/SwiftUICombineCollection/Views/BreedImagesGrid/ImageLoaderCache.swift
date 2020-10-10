//
//  ImageLoader.swift
//  SwiftUICombineCollection
//
//

import SwiftUI
import UIKit
import Combine

final class ImageLoaderCache {
    @Environment(\.injected.loaders) var dataLoaders: DIContainer.Loaders
    static let shared = ImageLoaderCache()

    private var loaders: NSCache<NSString, BreedImageViewModel> = NSCache()

    func loaderFor(url: URL) -> BreedImageViewModel {
        let key = NSString(string: url.absoluteString)
        if let loader = loaders.object(forKey: key) {
            return loader
        } else {
            let loader = BreedImageViewModel(url: url,
                                             loader: dataLoaders.imageDataLoader)
            loaders.setObject(loader, forKey: key)
            return loader
        }
    }
}
