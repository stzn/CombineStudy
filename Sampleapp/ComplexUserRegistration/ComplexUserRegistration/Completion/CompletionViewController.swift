//
//  CompletionViewController.swift
//  ComplexUserRegistration
//
//

import UIKit

class CompletionViewController: UIViewController {
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

    private let candidatesCollectionViewController = AddressCandidatesViewController()

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
        label.numberOfLines = 2
        return label
    }()

    private lazy var passwordLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        return label
    }()

    private lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        return label
    }()

    var didRestartTapped: (() -> Void)?
    private lazy var restartButton: UIButton = {
        let button = UIButton(primaryAction:  UIAction { [self]_ in
            self.didRestartTapped?()
        })
        button.setTitle("最初から", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        userNameLabel.text = "ユーザー名:\n\(state.userName)"
        passwordLabel.text = "パスワード:\n\(state.password)"
        addressLabel.text = "住所:\n\(state.address.displayed)"
    }

    private func setup() {
        container.addArrangedSubview(userNameLabel)
        container.addArrangedSubview(passwordLabel)
        container.addArrangedSubview(addressLabel)
        container.addArrangedSubview(restartButton)
        view.addSubview(container)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            container.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            restartButton.widthAnchor.constraint(equalTo: container.widthAnchor),
        ])
    }
}
