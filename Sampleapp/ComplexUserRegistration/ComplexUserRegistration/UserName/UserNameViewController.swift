//
//  UserNameViewController.swift
//  ComplexUserRegistration
//
//

import UIKit
import Combine

final class UserNameViewController: UIViewController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var state: AppState!
    convenience init(state: AppState) {
        self.init(nibName: nil, bundle: nil)
        self.state = state
    }

    private lazy var container: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "ユーザー名を入力してください"
        return label
    }()

    private lazy var userNameTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        return textField
    }()

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupBinding()
    }

    private func setup() {
        container.addArrangedSubview(userNameLabel)
        container.addArrangedSubview(userNameTextField)
        view.addSubview(container)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            container.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            container.widthAnchor.constraint(equalTo: userNameTextField.widthAnchor)
        ])
    }

    private func setupBinding() {
        userNameTextField.textDidChangePublisher
            .compactMap { $0 }
            .sink { [self] text in
                self.state[keyPath: \AppState.userName] = text
                self.navigationItem.rightBarButtonItem?.isEnabled = !text.isEmpty
            }
            .store(in: &cancellables)

        state.$registrationInformation
            .map(\.userName)
            .compactMap { $0 }
            .assign(to: \.text, on: userNameTextField)
            .store(in: &cancellables)
    }
}
