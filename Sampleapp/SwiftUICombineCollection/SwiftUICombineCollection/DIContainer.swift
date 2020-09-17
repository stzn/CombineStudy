//
//  DIContainer.swift
//  SwiftUICombineCollection
//
//

import SwiftUI

struct DIContainer: EnvironmentKey {
    let loaders: Loaders

    static var defaultValue: Self { Self.default }
    private static let `default` = Self(loaders: .live)
    static var stub = Self(loaders: .stub)
}

extension EnvironmentValues {
    var injected: DIContainer {
        get { self[DIContainer.self] }
        set { self[DIContainer.self] = newValue }
    }
}

extension DIContainer {
    struct Loaders {
        let breedListLoader: BreedListLoader
        let dogImageListLoader: DogImageListLoader
        let imageDataLoader: ImageDataLoader

        static var live: Self {
            let loaders = configureLoaders()
            return Loaders(
                breedListLoader: loaders.breedListLoader,
                dogImageListLoader: loaders.dogImageListLoader,
                imageDataLoader: loaders.imageDataLoader)
        }

        private static func configuredURLSession() -> URLSession {
            let configuration = URLSessionConfiguration.default
            return URLSession(configuration: configuration)
        }

        private static func configureLoaders() -> Self {
            let session = configuredURLSession()
            let client = URLSessionHTTPClient(session: session)

            let dogWebAPI = DogWebAPI(client: client)
            let imageWebLoader = ImageDataWebLoader(client: client)

            return .init(breedListLoader: dogWebAPI.breedListLoader,
                         dogImageListLoader: dogWebAPI.dogImageListLoader,
                         imageDataLoader: imageWebLoader.loader
            )
        }
    }
}

#if DEBUG
extension DIContainer.Loaders {
    static var stub: Self {
        .init(breedListLoader: .stub,
              dogImageListLoader: .stub,
              imageDataLoader: .stub)
    }
}
#endif
