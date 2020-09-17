//: [Previous](@previous)

import UIKit
import Combine
import PlaygroundSupport

extension UIScrollView {
    var contentOffsetPublisher: AnyPublisher<CGPoint, Never> {
        publisher(for: \.contentOffset).eraseToAnyPublisher()
    }
}

final class ViewController: UIViewController {
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .white
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var headerContainerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var headerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        if let image = UIImage(systemName: "mic.circle.fill") {
            imageView.image = image
        }
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var label: UILabel = {
        let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.backgroundColor = .white
            let titleFont = UIFont.preferredFont(forTextStyle: .title1)
            if let boldDescriptor = titleFont.fontDescriptor.withSymbolicTraits(.traitBold) {
                label.font = UIFont(descriptor: boldDescriptor, size: 0)
            } else {
                label.font = titleFont
            }
            label.textAlignment = .center
            label.adjustsFontForContentSizeCategory = true
            label.text = ""
            return label
    }()

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        scrollView.contentOffsetPublisher
            .sink { [weak self] point in
                self?.headerHeightConstraint.constant = 210 + point.y
        }.store(in: &cancellables)
    }

    private var headerHeightConstraint: NSLayoutConstraint!

    private func setup() {
        headerContainerView.addSubview(headerImageView)
        scrollView.addSubview(headerContainerView)
        scrollView.addSubview(label)
        view.addSubview(scrollView)

        let scrollViewConstraints: [NSLayoutConstraint] = [
            scrollView.topAnchor
                .constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor
                .constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor
                .constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor
                .constraint(equalTo: view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(scrollViewConstraints)

        headerHeightConstraint = headerContainerView.heightAnchor
            .constraint(equalToConstant: 210)
        let headerContainerViewConstraints: [NSLayoutConstraint] = [
            headerContainerView.topAnchor
                .constraint(equalTo: view.topAnchor, constant: 80),
            headerContainerView.widthAnchor
                .constraint(equalTo: scrollView.widthAnchor, multiplier: 1.0),
            headerHeightConstraint
        ]
        NSLayoutConstraint.activate(headerContainerViewConstraints)

        let headerImageViewConstraints: [NSLayoutConstraint] = [
            headerImageView.topAnchor
                .constraint(equalTo: headerContainerView.topAnchor),
            headerImageView.leadingAnchor
                .constraint(equalTo: headerContainerView.leadingAnchor),
            headerImageView.trailingAnchor
                .constraint(equalTo: headerContainerView.trailingAnchor),
            headerImageView.bottomAnchor
                .constraint(equalTo: headerContainerView.bottomAnchor)
        ]
        NSLayoutConstraint.activate(headerImageViewConstraints)

        let labelConstraints: [NSLayoutConstraint] = [
            label.topAnchor
                .constraint(equalTo: headerContainerView.bottomAnchor),
            label.widthAnchor
                .constraint(equalTo: scrollView.widthAnchor, multiplier: 1.0),
            label.heightAnchor
                .constraint(equalToConstant: 800)
        ]
        NSLayoutConstraint.activate(labelConstraints)
    }
}

let viewController = ViewController()
let nav = UINavigationController(rootViewController: viewController)

PlaygroundPage.current.liveView =  nav

//: [Next](@next)
