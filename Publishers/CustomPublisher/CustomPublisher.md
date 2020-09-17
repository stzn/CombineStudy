# Custom Publisher の作成方法

主に 3 つのステップがあります。

- Subscription の作成
- Publisher の作成
- Operator の作成

## UIControl の Publisher を作成する

### Subscription の作成

Subscription プロトコルは  
`request(_ demand: Subscribers.Demand)`  
を実装する必要がありますが、  
Demand の調整が不要な場合は何もする必要がありません。

内部で Subscriber を保持し  
Publisher から値を受け取ったら Subscriber へその値を渡しています。

https://developer.apple.com/documentation/combine/subscription

```swift
extension UIControl {
    final class Subscription<Target: Subscriber>: Combine.Subscription
    where Target.Input == Void {
        private var subscriber: Target?

        init(subscriber: Target, event: UIControl.Event) {
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
}
```

### Publisher の作成

`Output` と`Failure`の型が必要です。  
`receive(subscriber:)`メソッドの実装が必要で  
この中で`Subscription`と`Subscriber`を繋げます。

今回のケースですと、初期化時に`UIControl`を受け取り、  
メソッドないで`Subscription`を Target にしています。

https://developer.apple.com/documentation/combine/publisher

```swift
extension UIControl {
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
}
```

### Operator の作成

任意ではありますが  
デフォルトで用意されている Publisher でも使われているように  
Publisher 変換しやすくなるため定義しておくのがおすすめです。

```swift
extension UIControl {
    func publisher(for event: Event) -> Publisher {
        return Publisher(control: self, event: event)
    }
}
```

## URLSession.DataTaskPublisher の実装を見てみる

もっと複雑なものの例として Apple の`URLSession.DataTaskPublisher`の実装があります。  
この Publisher の特徴は  
**一度値を出力すると COmpletion する**  
という点です。

そのため、Demand の調整をする必要があります。

### Subscription の作成

#### `request(_ demand: Subscribers.Demand)`

一度しか出力されないようにするために

- `lock` の利用
- キャンセル済みの場合は何もしない
- インスタンス生成を一度しか行わないようにする

などを行っています。
そして要求されたらすぐに処理を実行しています。

```swift

// MARK: - Upward Signals
func request(_ d: Subscribers.Demand) {
    precondition(d > 0, "Invalid request of zero demand")

    // 処理が同時に発生しないようにlockをかけている
    lock.lock()
    guard let p = parent else {
        // すでにキャンセル済みの場合は何もしない
        lock.unlock()
        return
    }

    // Avoid issues around `self` before init by setting up only once here
    // インスタンスを重複して生成しないためのチェック
    if self.task == nil {
        let task = p.session.dataTask(
            with: p.request,
            completionHandler: handleResponse(data:response:error:)
        )
        self.task = task
    }

    self.demand += d
    let task = self.task!
    lock.unlock()

    task.resume()
}
```

#### `handleResponse(Data?:URLResponse?:Error?)`

Response を受け取った後の処理です。

- `lock` の利用
- キャンセル済みの場合は何もしない
- `parent`、`downstream`、`task` を nil にして値の再出力を防ぐ
- `demand` を 0 にして複数回要求された場合(`Demand` が 1 以上だった場合)の値の再出力を防ぐ

```swift

private func handleResponse(data: Data?, response: URLResponse?, error: Error?) {
    lock.lock()
    // すでにキャンセル済みの場合は何もしない
    guard demand > 0,
            parent != nil,
            let ds = downstream
    else {
        lock.unlock()
        return
    }

    // nilにして複数の出力を防ぐ
    parent = nil
    downstream = nil

    // Demandをクリアして複数の出力を防ぐ
    demand = .max(0)
    task = nil
    lock.unlock()

    if let response = response, error == nil {
        _ = ds.receive((data ?? Data(), response))
        ds.receive(completion: .finished)
    } else {
        let urlError = error as? URLError ?? URLError(.unknown)
        ds.receive(completion: .failure(urlError))
    }
}
```

#### `cancel`

cancel された際の処理です。

- `lock` の利用
- キャンセル済みの場合は何もしない
- `parent`、`downstream`、`task` を nil にする
- `demand` を 0 にする
- `task` のキャンセル処理を呼ぶ

```swift

func cancel() {
    lock.lock()
    guard parent != nil else {
        lock.unlock()
        return
    }
    parent = nil
    downstream = nil
    demand = .max(0)
    let task = self.task
    self.task = nil
    lock.unlock()
    task?.cancel()
}
```

### Publisher の作成

`Subscritption`を生成して渡しているだけです。
