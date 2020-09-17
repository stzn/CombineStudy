//: [Previous](@previous)

import Combine
import UIKit
import PlaygroundSupport

final class ViewController: UIViewController {
    private lazy var container: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()

    private let label = UILabel()

    private lazy var button: UIButton = {
        let button = UIButton(
            primaryAction: UIAction(title: "update") { button in
                self.viewModel.setNewID()
        })
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        return button
    }()

    var viewModel: ViewModel!
    var cancelables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        viewModel.$id
            .assign(to: \.text, on: label)
            .store(in: &cancelables)
    }

    private func setup() {
        container.addArrangedSubview(label)
        container.addArrangedSubview(button)
        view.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

final class ViewModel {
    @Published var id: String? = UUID().uuidString
    func setNewID() {
        id = UUID().uuidString
    }
}

let viewController = ViewController()
let viewModel = ViewModel()
viewController.viewModel = viewModel

let nav = UINavigationController(rootViewController: viewController)

PlaygroundPage.current.liveView =  nav
//: [Next](@next)
