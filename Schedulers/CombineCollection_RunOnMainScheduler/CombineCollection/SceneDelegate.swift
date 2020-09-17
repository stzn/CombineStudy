//
//  SceneDelegate.swift
//  CombineCollection
//
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private let client: HTTPClient = URLSessionHTTPClient(session: .shared)
    private lazy var dogWebAPI = DogWebAPI(client: client)
    private lazy var imageDataLoader = ImageDataWebLoader(client: client)

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: scene)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            identifier: String(describing: BreedListViewController.self)) { [self] coder in
            BreedListViewController(coder: coder,
                                    viewModel: .init(loader: dogWebAPI.breedListLoader),
                                    breedTypeSelected: moveToImagesGrid(breedType:))
        }
        let navigationController = UINavigationController(rootViewController: viewController)
        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()
    }

    private func moveToImagesGrid(breedType: BreedType) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            identifier: String(describing: BreedImagesGridViewController.self)) { [self] coder in
            BreedImagesGridViewController(coder: coder,
                                          breedType: breedType,
                                          viewModel: .init(loader: dogWebAPI.dogImageListLoader),
                                          imageDataLoader: imageDataLoader.loader)
        }
        guard let navigationContoller = window?.rootViewController as? UINavigationController else {
            return
        }
        navigationContoller.pushViewController(viewController, animated: true)
    }
}

