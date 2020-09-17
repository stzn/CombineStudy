//
//  ErrorView.swift
//  CombineCollection
//
//

import Combine
import UIKit

final class ErrorView: UIView {
    private lazy var container: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.addArrangedSubview(errorLabel)
        stack.addArrangedSubview(retryButton)
        return stack
    }()

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.text = "処理に失敗しました。\nもう一度お試しください。"
        label.tintColor = .systemRed
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .title3)
        label.numberOfLines = 0
        return label
    }()

    private let retrySubject = PassthroughSubject<Void, Never>()
    var retryPublisher: AnyPublisher<Void, Never> {
        retrySubject.eraseToAnyPublisher()
    }

    private lazy var retryButton: UIButton = {
        let button = UIButton(primaryAction: .init(title: "リトライ") { _ in
            self.retrySubject.send()
        })
        button.tintColor = .white
        button.backgroundColor = .systemRed
        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
        button.layer.cornerRadius = 8
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: centerXAnchor),
            container.centerYAnchor.constraint(equalTo: centerYAnchor),
            errorLabel.widthAnchor.constraint(equalTo: widthAnchor,
                                              multiplier: 0.8)
        ])
    }
}

