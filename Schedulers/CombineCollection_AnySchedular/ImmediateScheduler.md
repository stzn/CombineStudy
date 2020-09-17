# 問題

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

# 解決案

Combine には ImmediateScheduler というクラスが存在します。
[https://developer.apple.com/documentation/combine/immediatescheduler](https://developer.apple.com/documentation/combine/immediatescheduler)

これは Schduler に設定されたアクションを  
待機せずに即時で実行します。

そのため上記のような待機する処理に  
ImmediateScheduler を設定することで  
テストの待機時間をなくすことができます。

しかし  
通常のアプリでは待機する必要があるため  
Scheduler を切り替える必要があります。

そこで ViewModel に Scheduler を DI するようにします。

```swift
class HomeViewModel<S: Scheduler>: ObservableObject {
    @Published private(set) var episodes: [Episode] = []

    private let apiClient: ApiClient
    private let scheduler: S
    init(apiClient: ApiClient, scheduler: S) {
        self.apiClient = apiClient
        self.scheduler = scheduler
    }

    func reloadButtonTapped() {
        Just(())
            .delay(for: .seconds(10), scheduler: scheduler)
            .flatMap { self.apiClient.fetchEpisodes() }
            .receive(on: scheduler)
            .assign(to: &$episodes)
    }
}
```

Scheduler は associatedtype を持った Protocol のため  
直接型として使用できません。

そのため ViewModel にジェネリックな型を導入します。

こうするとテストは待機時間が不要になります。

```swift
func testViewModel() {
    let viewModel = HomeViewModel(
        apiClient: .mock,
        scheduler: ImmediateScheduler<DispatchQueue.SchedulerTimeType, Any>(now: .init(.now()))
    )

    var output: [[Episode]] = []
    viewModel.$episodes
        .sink { output.append($0) }
        .store(in: &self.cancellables)

    viewModel.reloadButtonTapped()

    XCTAssertEqual(output, [[], [Episode(id: 42)]])
}
```

DispatchQueue を使用していますが  
OperationQueue でも大丈夫です。

# 残った問題

これでテストの問題は解決しましたが  
実装の方に問題が出てきます。

ViewModel にジェネリックを導入したことで  
これを利用するクラス(例えば ViewController や View など)にも
ジェネリックな型を導入する必要が出てきます。  
これらのクラスと Scheduler は全く関係のないものであり  
ViewModel を使用するのにいちいちジェネリックを導入しなければならないのは  
非常に煩わしく感じられます。

そこで別の方法をさらに考えてみます。

AnyScheduler.md に続く
