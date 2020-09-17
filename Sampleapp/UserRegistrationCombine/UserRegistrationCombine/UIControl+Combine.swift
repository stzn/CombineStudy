//
//  UIControl+Combine.swift
//  UserRegistrationCombine
//
//

import Combine
import UIKit

extension UIControl {
    final class Subscription<Target: Subscriber>: Combine.Subscription
    where Target.Input == Void {
        private var subscriber: Target?

        init(subscriber: Target, event: UIControl.Event) {
            self.subscriber = subscriber
        }

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
            let subscription = UIControl.Subscription(subscriber: subscriber,
                                                      event: event)
            subscriber.receive(subscription: subscription)
            control.addTarget(subscription,
                              action: #selector(subscription.eventHandler),
                              for: event)
        }
    }
}

extension UIControl {
    func publisher(for event: Event) -> UIControl.Publisher {
        return UIControl.Publisher(control: self, event: event)
    }
}
