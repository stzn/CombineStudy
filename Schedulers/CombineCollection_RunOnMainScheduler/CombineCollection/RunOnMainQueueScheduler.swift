//
//  CombineSchedulerHelper.swift
//  CombineCollection
//
//

import Combine
import Foundation

extension Publisher {
    func receiveOnMainQueue() -> AnyPublisher<Output, Failure> {
        receive(on: DispatchQueue.runOnMainQueueScheduler)
            .eraseToAnyPublisher()
    }
}

extension DispatchQueue {
    static var runOnMainQueueScheduler: RunOnMainQueueScheduler {
        RunOnMainQueueScheduler.shared
    }

    struct RunOnMainQueueScheduler: Scheduler {
        typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
        typealias SchedulerOptions = DispatchQueue.SchedulerOptions

        var now: DispatchQueue.SchedulerTimeType {
            DispatchQueue.main.now
        }

        var minimumTolerance: DispatchQueue.SchedulerTimeType.Stride {
            DispatchQueue.main.minimumTolerance
        }

        static let shared = Self()

        private static let key = DispatchSpecificKey<UInt8>()
        private static let value = UInt8.max

        private init() {
            DispatchQueue.main.setSpecific(key: Self.key, value: Self.value)
        }

        // MainThreadで実行されていることはMainQueueで実行されることを保証しないため
        // Thread.isMainThreadでは不十分なケースがある
        // https://github.com/ReactiveCocoa/ReactiveCocoa/pull/2912
        private var isMainQueue: Bool {
            DispatchQueue.getSpecific(key: Self.key) == Self.value
        }

        func schedule(options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) {
            guard isMainQueue else {
                DispatchQueue.main.schedule(options: options, action)
                return
            }
            action()
        }

        func schedule(after date: DispatchQueue.SchedulerTimeType,
                      tolerance: DispatchQueue.SchedulerTimeType.Stride,
                      options: DispatchQueue.SchedulerOptions?,
                      _ action: @escaping () -> Void) {
            DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
        }

        func schedule(after date: DispatchQueue.SchedulerTimeType,
                      interval: DispatchQueue.SchedulerTimeType.Stride,
                      tolerance: DispatchQueue.SchedulerTimeType.Stride,
                      options: DispatchQueue.SchedulerOptions?,
                      _ action: @escaping () -> Void) -> Cancellable {
            DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
        }
    }
}
