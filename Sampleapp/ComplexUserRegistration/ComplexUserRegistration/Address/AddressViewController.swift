//
//  AddressViewController.swift
//  ComplexUserRegistration
//
//

import Combine
import UIKit

final class AddressViewController: UIViewController, UITableViewDelegate {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var state: AppState!
    private var model: AddressCandidateModel!
    convenience init(state: AppState, model: AddressCandidateModel) {
        self.init(nibName: nil, bundle: nil)
        self.state = state
        self.model = model
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

    private lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.text = "住所を入力してください"
        return label
    }()

    private lazy var zipcodeContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 2
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var zipcodeTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "1111111"
        textField.keyboardType = .numberPad
        textField.borderStyle = .roundedRect
        return textField
    }()

    private lazy var zipcodeCaptionLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.text = "※完全一致した場合のみ検索結果が表示されます"
        return label
    }()


    private lazy var prefectureTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "東京都"
        textField.borderStyle = .roundedRect
        return textField
    }()

    private lazy var cityTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "千代田区中央"
        textField.borderStyle = .roundedRect
        return textField
    }()

    private lazy var otherTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "１−１−１"
        textField.borderStyle = .roundedRect
        return textField
    }()

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupBinding()
        candidatesCollectionViewController.didSelect = { [weak self] candidate in
            self?.state[keyPath: \AppState.address] = Address(zipcode: candidate.zipcode,
                                                              prefecture: candidate.prefecture,
                                                              city: candidate.city, other: candidate.other)
        }
    }

    private func setup() {
        setupZipContainer()
        container.addArrangedSubview(addressLabel)
        container.addArrangedSubview(zipcodeContainer)
        container.addArrangedSubview(prefectureTextField)
        container.addArrangedSubview(cityTextField)
        container.addArrangedSubview(otherTextField)
        view.addSubview(container)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            container.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            container.widthAnchor.constraint(equalTo: zipcodeContainer.widthAnchor),
            container.widthAnchor.constraint(equalTo: prefectureTextField.widthAnchor),
            container.widthAnchor.constraint(equalTo: cityTextField.widthAnchor),
            container.widthAnchor.constraint(equalTo: otherTextField.widthAnchor)
        ])
    }

    private func setupZipContainer() {
        zipcodeContainer.addArrangedSubview(zipcodeTextField)
        zipcodeContainer.addArrangedSubview(zipcodeCaptionLabel)
    }

    private func setupBinding() {
        let zipcodePublisher = zipcodeTextField.textDidChangePublisher
        zipcodePublisher
            .compactMap { $0 }
            .sink { [self] text in
                self.state[keyPath: \AppState.zipcode] = text
                if text.count == 7, let zipcode = Int(text) {
                    self.model.getAddressCandidates(zipcode: zipcode)
                }
            }
            .store(in: &cancellables)

        let prefecturePublisher = prefectureTextField.textDidChangePublisher
        prefecturePublisher
            .compactMap { $0 }
            .sink { [self] text in
                self.state[keyPath: \AppState.prefecture] = text
            }
            .store(in: &cancellables)

        let cityPublisher = cityTextField.textDidChangePublisher
        cityPublisher
            .compactMap { $0 }
            .sink { [self] text in
                self.state[keyPath: \AppState.city] = text
            }
            .store(in: &cancellables)

        let otherPublisher = otherTextField.textDidChangePublisher
        otherPublisher
            .compactMap { $0 }
            .sink { [self] text in
                self.state[keyPath: \AppState.other] = text
            }
            .store(in: &cancellables)

        Publishers
            .CombineLatest4(zipcodePublisher, prefecturePublisher,
                            cityPublisher, otherPublisher)
            .map { [self] zipcode, prefecture, city, other in
                guard let zipcode = self.zipcodeTextField.text, !zipcode.isEmpty,
                      let prefecture = self.prefectureTextField.text, !prefecture.isEmpty,
                      let city = self.cityTextField.text, !city.isEmpty,
                      let other = self.otherTextField.text, !other.isEmpty
                else {
                    return false
                }
                return true
            }
            .sink { [self] enabled in
                self.navigationItem.rightBarButtonItem?.isEnabled = enabled
            }
            .store(in: &cancellables)

        model.$addressCandidates.sink { [weak self] candidates in
            guard let self = self,
                  let candidatesView = self.candidatesCollectionViewController.view else {
                return
            }
            self.candidatesCollectionViewController.update(candidates)

            if !candidates.isEmpty {
                self.zipcodeContainer.addArrangedSubview(candidatesView)
            } else {
                self.zipcodeContainer.removeArrangedSubview(candidatesView)
            }
        }.store(in: &cancellables)

        state.$registrationInformation
            .map(\.address)
            .sink { [self] address in
                self.prefectureTextField.text = address.prefecture
                self.cityTextField.text = address.city
                self.otherTextField.text = address.other
        }.store(in: &cancellables)
    }
}

final class AddressCandidatesViewController: UIViewController {
    enum Section { case main }

    private var candidates: [AddressCandidate] = [] {
        didSet {
            updateSnapshot()
        }
    }

    private var dataSource: UICollectionViewDiffableDataSource<Section, AddressCandidate>!
    private(set) var collectionView: UICollectionView!

    var didSelect: ((AddressCandidate) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureDataSource()
        collectionView.delegate = self
    }

    func update(_ candidates: [AddressCandidate]) {
        self.candidates = candidates
    }
}

extension AddressCandidatesViewController {
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
    }

    private func createLayout() -> UICollectionViewCompositionalLayout {
        let configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        return UICollectionViewCompositionalLayout.list(using: configuration)
    }

    private func configureDataSource() {
        let registgration = UICollectionView.CellRegistration<UICollectionViewListCell, AddressCandidate> { cell, indexPath, item in
            var content = cell.defaultContentConfiguration()
            content.text = "\(item.prefecture) \(item.city) \(item.other)"
            cell.contentConfiguration = content
        }

        dataSource = UICollectionViewDiffableDataSource<Section, AddressCandidate>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: AddressCandidate) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: registgration, for: indexPath, item: identifier)
        }

        updateSnapshot()
    }

    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, AddressCandidate>()
        snapshot.appendSections([.main])
        snapshot.appendItems(candidates)
        dataSource.apply(snapshot)
    }
}

extension AddressCandidatesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        let candidate = candidates[indexPath.item]
        didSelect?(candidate)
    }
}
