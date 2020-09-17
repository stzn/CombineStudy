# 問題

iOS アプリでは
UI の更新を行う際に MainThread で実行する必要があります。

そのため Combine で非同期の処理を行った後に
MainThread 戻すために  
`receive(on:)`を呼びます。

```swift
receive(on: DispatchQueue.main)
```

この際に｀ DisatchQueue.main ｀を利用すると  
実際にアプリを動かす際には問題になりませんが、  
テストを実行する際に Thread の切り替えが行われることで  
同期的にテストを書くことができなくなります。

例えば

```swift

class HomeViewModel: ObservableObject {
    @Published var episodes: [Episode] = []
    var cancellables: Set<AnyCancellable> = []

    let apiClient: ApiClient
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }

    func reloadButtonTapped() {
        Just(())
            .flatMap { self.apiClient.fetchEpisodes() }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] episodes in self?.episodes = episodes }
            .store(in: &self.cancellables)
    }
}
```

という ViewModel で ApiClient からデータを取得できるかどうかをテストする場合  
下記のように expectation を使って処理の完了を待つ必要があります。

```swift

func testViewModel() {
    let viewModel = HomeViewModel(apiClient: .mock)

    let exp = expectation(description: #function)
    exp.expectedFulfillmentCount = 2

    var output: [[Episode]] = []
    viewModel.$episodes
        .sink { value in
            output.append(value)
            exp.fulfill()
        }
        .store(in: &self.cancellables)

    viewModel.reloadButtonTapped()
    _ = XCTWaiter.wait(for: [exp], timeout: 1)
    XCTAssertEqual(output, [[], [Episode(id: 42)]])
}
```

`DispatchQueue.main`を使用するロジックのテストには  
上記のような処理が必要になります。

これを隠すために  
下記のような extension を追加することもできます。

```swift
extension Publisher {
    func assert(outputs: [Output], expectation: XCTestExpectation,
                isEqual: @escaping (Output, Output) -> Bool,
                file: StaticString = #filePath,
                line: UInt = #line) -> AnyCancellable {
        var expectedOutputs = outputs
        return self.sink { _ in
            // 何もしない
        }
        receiveValue: { output in
            guard let expectedOutput = expectedOutputs.first else {
                XCTFail("too many outputs published", file: file, line: line)
                return
            }
            guard isEqual(expectedOutput, output) else {
                XCTFail("unmatched output published", file: file, line: line)
                return
            }

            expectedOutputs = Array(expectedOutputs.dropFirst())

            if expectedOutputs.isEmpty {
                expectation.fulfill()
            }
        }
    }
}

extension Publisher where Output: Equatable {
    func assert(outputs: [Output], expectation: XCTestExpectation,
                file: StaticString = #filePath,
                line: UInt = #line) -> AnyCancellable {
        return assert(outputs: outputs, expectation: expectation, isEqual: ==)
    }
}
```

```swift

func testViewModel() {
    let viewModel = HomeViewModel(apiClient: .mock)

    let exp = expectation(description: #function)
    viewModel.$episodes
        .assert(outputs: [[], [Episode(id: 42)]], expectation: exp)
        .store(in: &self.cancellables)

    viewModel.reloadButtonTapped()

    wait(for: [exp], timeout: 1.0)
}
```

これですっきりしました。

しかし、expectation を毎回定義するのは
テストの本題とは関係ないため
ちょっと違和感があります。

# 解決案

そこでテスト時に Thread の切り替えが起きないように  
下記のような Scheduler を用意します。

```swift

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
```

ポイントは

```swift
func schedule(options: DispatchQueue.SchedulerOptions?,
              _ action: @escaping () -> Void) {
    guard isMainQueue else {
        DispatchQueue.main.schedule(options: options, action)
        return
    }
    action()
}
```

で、MainThread で動いている場合は  
同じ Thread で処理を継続するようにします。

XCTest は基本的に MainThread で動き続けているため  
Thread の切り替えが行われず、順次処理が進みます。

結果、expectation は不要になります。

```swift
func testViewModel() {
    let viewModel = HomeViewModel(apiClient: .mock)

    var output: [[Episode]] = []
    viewModel.$episodes
        .sink { value in
            output.append(value)
        }
        .store(in: &self.cancellables)

    viewModel.reloadButtonTapped()

    XCTAssertEqual(output, [[], [Episode(id: 42)], [Episode(id: 42)]])
}
```

# 残った問題

しかし、まだ問題が残ります。

例えば、  
処理の中にすごい時間がかかるものがあるとします。

```swift
func reloadButtonTapped() {
    Just(())
        // 10秒間待つ
        .delay(for: .seconds(10), scheduler: DispatchQueue.runOnMainQueueScheduler)
        .flatMap { self.apiClient.fetchEpisodes() }
        .receiveOnMainQueue()
        .assign(to: &$episodes)
}
```

こうするとこの時間待たないと  
Publisher は値を出力しません。

```swift
func testViewModel() {
    let viewModel = HomeViewModel(apiClient: .mock)

    var output: [[Episode]] = []
    viewModel.$episodes
        .sink { value in
            output.append(value)
        }
        .store(in: &self.cancellables)

    viewModel.reloadButtonTapped()

    _ = XCTWaiter().wait(for: [XCTestExpectation()], timeout: 11)

    XCTAssertEqual(output, [[], [Episode(id: 42)], [Episode(id: 42)]])
}
```

これでテストは通りますが  
テストの実行時間が長くなります。

さらにもしこの待機時間が予測できない外部要因によるものだとしたら  
場合によっては失敗することもあります。

これを解消する方法として別の方法を見ていきます。

ImmediateScheduler.md に続く
