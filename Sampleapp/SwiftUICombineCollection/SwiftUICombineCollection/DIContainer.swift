//
//  DIContainer.swift
//  SwiftUICombineCollection
//
//

import Combine
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

typealias BreedListLoader = () -> AnyPublisher<[Breed], Error>
typealias DogImageListLoader = (BreedType) -> AnyPublisher<[DogImage], Error>
typealias ImageDataLoader = (URL) -> AnyPublisher<Data, Error>

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

            return .init(breedListLoader: dogWebAPI.loadBreedList,
                         dogImageListLoader: dogWebAPI.loadImageList(breedType:),
                         imageDataLoader: imageWebLoader.load
            )
        }
    }
} 

extension DIContainer.Loaders {
    static var stub: Self {
        .init(breedListLoader: { makeStub([Breed.anyBreed]) },
              dogImageListLoader: { _ in makeStub([DogImage.anyDogImage]) },
              imageDataLoader:  { _ in makeStub(UIImage(systemName: "person.fill")!.pngData()!) }
        )
    }

    private static func makeStub<Model>(_ model: Model) -> AnyPublisher<Model, Error> {
        Just(model)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
