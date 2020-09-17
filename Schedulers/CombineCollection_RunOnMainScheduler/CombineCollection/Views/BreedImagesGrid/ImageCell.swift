//
//  ImageCell.swift
//  CombineCollection
//
//

import Combine
import UIKit

final class ImageCell: UICollectionViewCell {
    @Published var isLoading: Bool = false

    let imageView = UIImageView()

    var cancellables = Set<AnyCancellable>()

    private lazy var loadingView = LoadingView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        setupBindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil

        // reuse時にリクエストをキャンセルする
        cancellables = Set<AnyCancellable>()
    }

    private func configure() {
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    private func setupBindings() {
        $isLoading.sink { [weak self] isLoading in
            if isLoading {
                self?.startLoading()
            } else {
                self?.stopLoading()
            }
        }.store(in: &cancellables)
    }

    private func startLoading() {
        contentView.addSubview(loadingView)
        loadingView.frame = contentView.bounds
        loadingView.start()
    }

    private func stopLoading() {
        loadingView.stop()
        loadingView.removeFromSuperview()
    }
}
