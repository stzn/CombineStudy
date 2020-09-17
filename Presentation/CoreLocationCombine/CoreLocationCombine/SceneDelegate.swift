//
//  SceneDelegate.swift
//  CoreLocationCombine
//
//

import UIKit
import MapKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private let locationMonitor = LocationMonitor(manager: CLLocationManager())

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: scene)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            identifier: String(describing: ViewController.self)) { [self] coder in
            ViewController(coder: coder, locationMonitor: locationMonitor)
        }
        let navigationController = UINavigationController(rootViewController: viewController)
        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()
    }
}

