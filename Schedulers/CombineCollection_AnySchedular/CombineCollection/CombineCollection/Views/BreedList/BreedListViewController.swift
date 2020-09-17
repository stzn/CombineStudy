//
//  ViewController.swift
//  CombineCollection
//
//

import Combine
import UIKit

final class BreedListViewController: UIViewController {
    typealias Section = BreedType
    typealias DataSource = UICollectionViewDiffableDataSource<Section, DisplayBreed>

    private var dataSource: DataSource!
    private var collectionView: UICollectionView!
    private let appearance = UICollectionLayoutListConfiguration.Appearance.plain

    private lazy var loadingView = LoadingView()
    private lazy var errorView = ErrorView()

    private var cancellables = Set<AnyCancellable>()
    private let viewModel: BreedListViewModel

    var breedTypeSelected: ((BreedType) -> Void)?

    init?(coder: NSCoder, viewModel: BreedListViewModel,
          breedTypeSelected: ((BreedType) -> Void)?) {
        self.viewModel = viewModel
        self.breedTypeSelected = breedTypeSelected
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "BreedList"
        configureHierarchy()
        configureDataSource()
        setupBindings()

        collectionView.delegate = self

        viewModel.fetchList()
    }

    private func setupBindings() {
        viewModel.$breeds
            .sink (receiveValue: updateSnapshot(breeds:))
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

        errorView.retryPublisher.sink {
            self.viewModel.fetchList()
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

extension BreedListViewController {
    private func createLayout() -> UICollectionViewCompositionalLayout {
        var config = UICollectionLayoutListConfiguration(appearance: appearance)
        config.headerMode = .firstItemInSection
        return UICollectionViewCompositionalLayout.list(using: config)
    }
}

extension BreedListViewController {
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
    }

    private func configureDataSource() {
        let headerRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, DisplayBreed> { (cell, indexPath, item) in
            var content = cell.defaultContentConfiguration()
            content.text = item.displayName
            cell.contentConfiguration = content

            let disclosureOptions = UICellAccessory.OutlineDisclosureOptions(style: .header)
            cell.accessories = [.outlineDisclosure(options:disclosureOptions)]
        }

        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, DisplayBreed> { (cell, indexPath, item) in
            var content = cell.defaultContentConfiguration()
            content.text = item.displayName
            cell.contentConfiguration = content
            cell.accessories = [.disclosureIndicator()]
        }

        dataSource = DataSource(collectionView: collectionView) { (collectionView, indexPath, item) in
            if indexPath.item == 0 {
                return collectionView.dequeueConfiguredReusableCell(using: headerRegistration, for: indexPath, item: item)
            } else {
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
            }
        }
    }

    private func updateSnapshot(breeds: [DisplayBreed]) {
        for breed in breeds {
            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<DisplayBreed>()
            sectionSnapshot.append([breed])
            sectionSnapshot.append(breed.subBreeds, to: breed)
            sectionSnapshot.expand([breed])
            dataSource.apply(sectionSnapshot, to: breed.name)
        }
    }
}

extension BreedListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        guard let breedType = dataSource.itemIdentifier(for: indexPath)?.name else {
            return
        }
        breedTypeSelected?(breedType)
    }
}
