//
//  PasswordViewController.swift
//  ComplexUserRegistration
//
//

import Combine
import UIKit

final class PasswordViewController: UIViewController {
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

    private lazy var passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "パスワードを入力してください"
        return label
    }()

    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .asciiCapable
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        return textField
    }()

    private lazy var passwordConfirmTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .asciiCapable
        textField.isSecureTextEntry = true
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
        container.addArrangedSubview(passwordLabel)
        container.addArrangedSubview(passwordTextField)
        container.addArrangedSubview(passwordConfirmTextField)
        view.addSubview(container)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            container.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            container.widthAnchor.constraint(equalTo: passwordTextField.widthAnchor),
            container.widthAnchor.constraint(equalTo: passwordConfirmTextField.widthAnchor)
        ])
    }

    private func setupBinding() {
        let passwordPublisher = passwordTextField.textDidChangePublisher
        passwordPublisher
            .compactMap { $0 }
            .sink { [self] text in
                self.state[keyPath: \AppState.password] = text
            }
            .store(in: &cancellables)

        passwordConfirmTextField.textDidChangePublisher
            .combineLatest(passwordPublisher)
            .map { confirm, password in
                guard let confirm = confirm, !confirm.isEmpty,
                      let password = password, !password.isEmpty else {
                    return false
                }
                return confirm == password
            }
            .sink { [self] enabled in
                self.navigationItem.rightBarButtonItem?.isEnabled = enabled
            }
            .store(in: &cancellables)

        state.$registrationInformation
            .map(\.password)
            .compactMap { $0 }
            .assign(to: \.text, on: passwordTextField)
            .store(in: &cancellables)
    }
}
