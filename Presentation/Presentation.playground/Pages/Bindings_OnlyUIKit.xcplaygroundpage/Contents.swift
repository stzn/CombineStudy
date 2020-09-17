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

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        viewModel.idUpdated = { id in
            self.label.text = id
        }
        viewModel.setNewID()
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
    var idUpdated: ((String) -> Void)?

    private var id: String = "" {
        didSet {
            idUpdated?(id)
        }
    }

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
