//
//  ViewHelper.swift
//  CombineCollection
//
//

import UIKit

final class LoadingView: UIView {
    private lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        addSubview(indicator)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        return indicator
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func start() {
        indicator.startAnimating()
    }

    func stop() {
        indicator.stopAnimating()
    }

    private func setup() {
        backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
    }
}
