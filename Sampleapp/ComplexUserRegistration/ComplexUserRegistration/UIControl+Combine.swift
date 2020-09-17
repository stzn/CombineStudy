//
//  UIControl+Combine.swift
//  UserRegistrationCombine
//
//

import Combine
import UIKit

// MARK: - ControlPropertyPublisher

extension UIControl {
    struct PropertyPublisher<Control: UIControl, Value>: Combine.Publisher {
        typealias Output = Value
        typealias Failure = Never

        let control: Control
        let event: Control.Event
        let keyPath: KeyPath<Control, Value>

        func receive<S>(subscriber: S) where S : Subscriber,
                                             S.Failure == Failure,
                                             S.Input == Output {
            let subscription = Subscription(subscriber: subscriber,
                                                    control: control,
                                                      event: event,
                                                      keyPath: keyPath)
            subscriber.receive(subscription: subscription)
            control.addTarget(subscription,
                              action: #selector(subscription.handleEvent),
                              for: event)
        }

        final class Subscription<Target: Subscriber, Control: UIControl, Value>: Combine.Subscription
        where Target.Input == Value {
            private var subscriber: Target?
            weak private var control: Control?
            let keyPath: KeyPath<Control, Value>
            private var didPublishInitialValue = false

            init(subscriber: Target, control: Control, event: Control.Event, keyPath: KeyPath<Control, Value>) {
                self.subscriber = subscriber
                self.control = control
                self.keyPath = keyPath
                control.addTarget(self, action: #selector(handleEvent), for: event)
            }

            // Subscribe時に現在の値を初期値として出力する
            // それ以降はキャンセルされるまで出力を受け取り続ける
            // Demandの調整は行わない
            func request(_ demand: Subscribers.Demand) {
                if !didPublishInitialValue,
                    demand > .none,
                    let control = control,
                    let subscriber = subscriber {
                    _ = subscriber.receive(control[keyPath: keyPath])
                    didPublishInitialValue = true
                }
            }

            func cancel() {
                subscriber = nil
            }

            @objc func handleEvent() {
                guard let control = control else { return }
                _ = subscriber?.receive(control[keyPath: keyPath])
            }
        }
    }
}

// MARK: - ControlEventPublisher

extension UIControl {
    struct EventPublisher<Control: UIControl>: Combine.Publisher {
        typealias Output = Void
        typealias Failure = Never

        let control: Control
        let event: Control.Event

        func receive<S>(subscriber: S) where S : Subscriber,
                                             S.Failure == Failure,
                                             S.Input == Output {
            let subscription = Subscription(subscriber: subscriber,
                                                    control: control,
                                                      event: event)
            subscriber.receive(subscription: subscription)
            control.addTarget(subscription,
                              action: #selector(subscription.handleEvent),
                              for: event)
        }

        final class Subscription<Target: Subscriber, Control: UIControl>: Combine.Subscription
        where Target.Input == Void {
            private var subscriber: Target?
            weak private var control: Control?

            init(subscriber: Target, control: Control, event: Control.Event) {
                self.subscriber = subscriber
                self.control = control
                control.addTarget(self, action: #selector(handleEvent), for: event)
            }

            // キャンセルされるまで出力を受け取り続ける
            // Demandの調整は行わない
            func request(_ demand: Subscribers.Demand) {
            }

            func cancel() {
                subscriber = nil
            }

            @objc func handleEvent() {
                _ = subscriber?.receive(())
            }
        }
    }
}

// MARK: - ControlTargetPublisher

extension Combine.Publishers {
    struct ControlTargetPublisher<Control: AnyObject>: Publisher {
        typealias Output = Void
        typealias Failure = Never

        private let control: Control
        private let addTargetAction: (Control, AnyObject, Selector) -> Void
        private let removeTargetAction: (Control?, AnyObject, Selector) -> Void

        init(control: Control,
             addTargetAction: @escaping (Control, AnyObject, Selector) -> Void,
             removeTargetAction: @escaping (Control?, AnyObject, Selector) -> Void) {
            self.control = control
            self.addTargetAction = addTargetAction
            self.removeTargetAction = removeTargetAction
        }

        func receive<S: Subscriber>(subscriber: S) where S.Failure == Failure, S.Input == Output {
            let subscription = Subscription(subscriber: subscriber,
                                            control: control,
                                            addTargetAction: addTargetAction,
                                            removeTargetAction: removeTargetAction)
            subscriber.receive(subscription: subscription)
        }

        private final class Subscription<S: Subscriber, Control: AnyObject>: Combine.Subscription where S.Input == Void {
            private var subscriber: S?
            weak private var control: Control?

            private let removeTargetAction: (Control?, AnyObject, Selector) -> Void
            private let action = #selector(handleAction)

            init(subscriber: S,
                 control: Control,
                 addTargetAction: @escaping (Control, AnyObject, Selector) -> Void,
                 removeTargetAction: @escaping (Control?, AnyObject, Selector) -> Void) {
                self.subscriber = subscriber
                self.control = control
                self.removeTargetAction = removeTargetAction
                addTargetAction(control, self, action)
            }

            func request(_ demand: Subscribers.Demand) {
                // We don't care about the demand at this point.
                // As far as we're concerned - The control's target events are endless until it is deallocated.
            }

            func cancel() {
                subscriber = nil
                removeTargetAction(control, self, action)
            }

            @objc private func handleAction() {
                _ = subscriber?.receive()
            }
        }
    }
}

extension UIBarButtonItem {
    var tapPublisher: Publishers.ControlTargetPublisher<UIBarButtonItem> {
        return Publishers.ControlTargetPublisher(
            control: self,
            addTargetAction: { control, target, action in
                control.target = target
                control.action = action
            },
            removeTargetAction: { control, _, _ in
                control?.target = nil
                control?.action = nil
            })
    }
}


extension UIButton {
    func publisher(for event: UIControl.Event) -> EventPublisher<UIButton> {
        return EventPublisher(control: self, event: event)
    }
}

extension UITextField {
    var textDidChangePublisher: PropertyPublisher<UITextField, String?> {
        return PropertyPublisher(control: self, event: [.allEditingEvents, .valueChanged], keyPath: \.text)
    }
}


