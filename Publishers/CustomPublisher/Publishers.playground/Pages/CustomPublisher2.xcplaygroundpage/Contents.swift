//: [Previous](@previous)

import Combine
import Foundation
import UIKit
import PlaygroundSupport

extension UIControl {
    final class Subscription<Target: Subscriber>: Combine.Subscription
    where Target.Input == Void {
        private var subscriber: Target?

        init(subscriber: Target, event: Event) {
            self.subscriber = subscriber
        }

        // 今回は来たものを全て受け取るためDemandの調整はしない
        func request(_ demand: Subscribers.Demand) {}

        func cancel() {
            subscriber = nil
        }

        @objc func eventHandler() {
            _ = subscriber?.receive(())
        }
    }

    struct Publisher: Combine.Publisher {
        typealias Output = Void
        typealias Failure = Never

        let control: UIControl
        let event: Event

        func receive<S>(subscriber: S) where S : Subscriber,
                                             S.Failure == Failure,
                                             S.Input == Output {
            let subscription = Subscription(subscriber: subscriber,
                                            event: event)
            subscriber.receive(subscription: subscription)
            control.addTarget(subscription,
                              action: #selector(subscription.eventHandler),
                              for: event)
        }
    }

    func publisher(for event: Event) -> Publisher {
        return Publisher(control: self, event: event)
    }
}

final class ViewController: UIViewController {
    private lazy var container: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()

    private let label = UILabel()

    private lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle("increament", for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        return button
    }()

    private var cancellables = Set<AnyCancellable>()
    private var count = 0 {
        didSet {
            self.label.text = "\(self.count)"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = "\(self.count)"
        button.publisher(for: .touchUpInside)
            .sink { self.count += 1 }
            .store(in: &cancellables)

        setup()
    }

    private func setup() {
        container.addArrangedSubview(label)
        container.addArrangedSubview(button)
        view.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

let viewController = ViewController()
let nav = UINavigationController(rootViewController: viewController)

PlaygroundPage.current.liveView =  nav

//: [Next](@next)
