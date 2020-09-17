//
//  SceneDelegate.swift
//  ComplexUserRegistration
//
//

import Combine
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private var cancellables = Set<AnyCancellable>()
    private let appState = AppState()
    private let navigationController = UINavigationController()
    private let client: ZipClient = .live

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let scene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: scene)

        let viewController = createUserNameViewControler()
        navigationController.viewControllers = [viewController]
        navigationController.navigationBar.prefersLargeTitles = true
        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()

        setupBindings()
    }

    private func setupBindings() {
        appState.$step.dropFirst().sink { [self] step in
            let viewController: UIViewController
            switch step {
            case .userName:
                viewController = self.createUserNameViewControler()
            case .address:
                viewController = self.createAddressViewControler()
            case .password:
                viewController = self.createPasswordViewControler()
            case .completion:
                viewController = self.createCompletionViewControler()
            }
            self.navigationController.pushViewController(viewController, animated: true)
        }.store(in: &cancellables)
    }

    private func createUserNameViewControler() -> UIViewController {
        let viewController = UserNameViewController(state: appState)
        viewController.view.backgroundColor = .white
        viewController.navigationItem.largeTitleDisplayMode = .always
        viewController.navigationItem.title = "Step1"

        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "次へ", primaryAction: UIAction { [self]_ in
            self.appState.step = .password
        })

        viewController.navigationItem.rightBarButtonItem?.isEnabled = false
        return viewController
    }

    private func createPasswordViewControler() -> UIViewController {
        let viewController = PasswordViewController(state: appState)
        viewController.view.backgroundColor = .white
        viewController.navigationItem.largeTitleDisplayMode = .always
        viewController.navigationItem.title = "Step2"
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "次へ", primaryAction: UIAction { [self] _ in
            self.appState.step = .address
        })

        viewController.navigationItem.rightBarButtonItem?.isEnabled = false
        return viewController
    }

    private func createAddressViewControler() -> UIViewController {
        let viewController = AddressViewController(state: appState, model: AddressCandidateModel(client: client))
        viewController.view.backgroundColor = .white
        viewController.navigationItem.largeTitleDisplayMode = .always
        viewController.navigationItem.title = "Step3"
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "次へ", primaryAction: UIAction { [self] _ in
            self.appState.step = .completion
        })

        viewController.navigationItem.rightBarButtonItem?.isEnabled = false
        return viewController
    }

    private func createCompletionViewControler() -> UIViewController {
        let viewController = CompletionViewController(state: appState)
        viewController.view.backgroundColor = .white
        viewController.navigationItem.largeTitleDisplayMode = .always
        viewController.navigationItem.title = "登録完了"
        viewController.didRestartTapped = { [self] in
            self.appState.registrationInformation = .initial
            self.navigationController.popToRootViewController(animated: false)
        }
        return viewController
    }
}

