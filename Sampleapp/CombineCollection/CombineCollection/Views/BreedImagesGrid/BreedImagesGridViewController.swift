//
//  BreedImagesGridViewController.swift
//  CombineCollection
//
//

import Combine
import UIKit

final class BreedImagesGridViewController: UIViewController {
    enum Section {
        case main
    }

    var dataSource: UICollectionViewDiffableDataSource<Section, DogImage>!
    var collectionView: UICollectionView!

    private lazy var loadingView = LoadingView()
    private lazy var errorView = ErrorView()

    private let breedType: BreedType
    private let viewModel: BreedImagesGridViewModel
    private let imageDataLoader: ImageDataLoader
    private var cancellables = Set<AnyCancellable>()

    init?(coder: NSCoder,
          breedType: BreedType,
          viewModel: BreedImagesGridViewModel,
          imageDataLoader: ImageDataLoader) {
        self.breedType = breedType
        self.viewModel = viewModel
        self.imageDataLoader = imageDataLoader
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = breedType
        configureHierarchy()
        configureDataSource()
        setupBindings()
        viewModel.fetch(breedType: breedType)
    }

    private func setupBindings() {
        viewModel.$dogImages
            .sink(receiveValue: updateSnapshot(dogImages:))
            .store(in: &cancellables)

        viewModel.$error.sink { [self] error in
            guard error != nil else {
                hideError()
                return
            }
            showError()
        }.store(in: &cancellables)

        viewModel.$isLoading.sink { [self] isLoading in
            if isLoading {
                startLoading()
            } else {
                stopLoading()
            }
        }.store(in: &cancellables)

        errorView.retryPublisher.sink { [self] in
            viewModel.fetch(breedType: breedType)
        }.store(in: &cancellables)

    }

    private func startLoading() {
        view.addSubview(loadingView)
        loadingView.frame = view.bounds
        loadingView.start()
    }

    private func stopLoading() {
        loadingView.stop()
        loadingView.removeFromSuperview()
    }

    private func showError() {
        view.addSubview(errorView)
        errorView.frame = view.bounds
    }

    private func hideError() {
        errorView.removeFromSuperview()
    }
}

extension BreedImagesGridViewController {
    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(0.2))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)

        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension BreedImagesGridViewController {
    func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
    }

    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<ImageCell, DogImage> { (cell, indexPath, dogImage) in
            cell.isLoading = true
            self.imageDataLoader.load(dogImage.imageURL)
                .map(UIImage.init)
                .replaceError(with: UIImage(systemName: "xmark.circle.fill")!.withTintColor(.red, renderingMode: .alwaysTemplate))
                .receive(on: DispatchQueue.main)
                .handleEvents(receiveOutput: { _ in cell.isLoading = false })
                .sink { cell.imageView.image = $0 }
                .store(in: &cell.cancellables)
        }

        dataSource = UICollectionViewDiffableDataSource<Section, DogImage>(collectionView: collectionView) {
            (collectionView, indexPath, identifier: DogImage) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }
        updateSnapshot(dogImages: [])
    }

    func updateSnapshot(dogImages: [DogImage]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, DogImage>()
        snapshot.appendSections([.main])
        snapshot.appendItems(dogImages)
        dataSource.apply(snapshot)
    }
}
