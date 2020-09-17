# 問題

ImmediateScheduler によって  
テスト実行時間の問題は解決できましたが  
実装の方で Scheduler を撒き散らすことになり  
煩わしく感じます。

そこでこちらの Open Source の実装を利用したいと思います。

[https://github.com/pointfreeco/combine-schedulers/blob/main/Sources/CombineSchedulers/AnyScheduler.swift](https://github.com/pointfreeco/combine-schedulers/blob/main/Sources/CombineSchedulers/AnyScheduler.swift)

[https://github.com/pointfreeco/combine-schedulers/blob/main/Sources/CombineSchedulers/ImmediateScheduler.swift](https://github.com/pointfreeco/combine-schedulers/blob/main/Sources/CombineSchedulers/ImmediateScheduler.swift)

## AnyScheduler

ジェネリックな型を避けるための Scheduler の TypeEraser です。

init で元の Scheduler を受け取り  
schdulerScheduler プロトコルに必要な要素を保持します。

```swift
public init<S>(
    _ scheduler: S
)
where
    S: Scheduler, S.SchedulerTimeType == SchedulerTimeType, S.SchedulerOptions == SchedulerOptions
{
    self._now = { scheduler.now }
    self._minimumTolerance = { scheduler.minimumTolerance }
    self._scheduleAfterToleranceSchedulerOptionsAction = scheduler.schedule
    self._scheduleAfterIntervalToleranceSchedulerOptionsAction = scheduler.schedule
    self._scheduleSchedulerOptionsAction = scheduler.schedule
}
```

あとはプロトコルで上記のクロージャを呼び出します。

さらに簡単に型を定義できるように typealias も用意されています。

```swift
public typealias AnySchedulerOf<Scheduler> = AnyScheduler<
    Scheduler.SchedulerTimeType, Scheduler.SchedulerOptions
  > where Scheduler: Combine.Scheduler
```

さらに Publisher と同様に  
Scheduler から AnySchduler を簡単に生成するための  
メソッドもあります。

```swift
extension Scheduler {
    public func eraseToAnyScheduler() -> AnyScheduler<SchedulerTimeType, SchedulerOptions> {
        AnyScheduler(self)
    }
}
```

こうすると下記のように利用できます。

```swift
class HomeViewModel: ObservableObject {
    @Published private(set) var episodes: [Episode] = []

    private let apiClient: ApiClient
    private let scheduler: AnySchedulerOf<DispatchQueue>
    init(apiClient: ApiClient, scheduler: AnySchedulerOf<DispatchQueue>) {
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

## ImmediateSchduler

ここで問題があります。
Combine の ImmediateScheduler は具体的な型のため  
ViewModel の scheduler の型にマッチしません。

```swift
private let scheduler: AnySchedulerOf<DispatchQueue>
```

そこで DispatchQueue 用の ImmediateScheduler が用意されています。

これは Combine の ImmediateScheduler と同様に  
設定された時間を無視して即座にアクションを実行します。

Combine の ImmediateScheduler

```swift
/// A scheduler for performing synchronous actions.
///
/// You can only use this scheduler for immediate actions. If you attempt to schedule actions after a specific date, this scheduler ignores the date and performs them immediately.
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct ImmediateScheduler : Scheduler {

    /// The time type used by the immediate scheduler.
    public struct SchedulerTimeType : Strideable {

        /// Returns the distance to another immediate scheduler time; this distance is always `0` in the context of an immediate scheduler.
        ///
        /// - Parameter other: The other scheduler time.
        /// - Returns: `0`, as a `Stride`.
        public func distance(to other: ImmediateScheduler.SchedulerTimeType) -> ImmediateScheduler.SchedulerTimeType.Stride

        /// Advances the time by the specified amount; this is meaningless in the context of an immediate scheduler.
        ///
        /// - Parameter n: The amount to advance by. The `ImmediateScheduler` ignores this value.
        /// - Returns: An empty `SchedulerTimeType`.
        public func advanced(by n: ImmediateScheduler.SchedulerTimeType.Stride) -> ImmediateScheduler.SchedulerTimeType

        /// The increment by which the immediate scheduler counts time.
        public struct Stride : ExpressibleByFloatLiteral, Comparable, SignedNumeric, Codable, SchedulerTimeIntervalConvertible {

            /// The type used when evaluating floating-point literals.
            public typealias FloatLiteralType = Double

            /// The type used when evaluating integer literals.
            public typealias IntegerLiteralType = Int

            /// The type used for expressing the stride’s magnitude.
            public typealias Magnitude = Int

            /// The value of this time interval in seconds.
            public var magnitude: Int

            /// Creates an immediate scheduler time interval from the given time interval.
            public init(_ value: Int)

            /// Creates an immediate scheduler time interval from an integer seconds value.
            public init(integerLiteral value: Int)

            /// Creates an immediate scheduler time interval from a floating-point seconds value.
            public init(floatLiteral value: Double)

            /// Creates an immediate scheduler time interval from a binary integer type.
            ///
            /// If `exactly` can’t convert to an `Int`, the resulting time interval is `nil`.
            public init?<T>(exactly source: T) where T : BinaryInteger

            /// Returns a Boolean value indicating whether the value of the first
            /// argument is less than that of the second argument.
            ///
            /// This function is the only requirement of the `Comparable` protocol. The
            /// remainder of the relational operator functions are implemented by the
            /// standard library for any type that conforms to `Comparable`.
            ///
            /// - Parameters:
            ///   - lhs: A value to compare.
            ///   - rhs: Another value to compare.
            public static func < (lhs: ImmediateScheduler.SchedulerTimeType.Stride, rhs: ImmediateScheduler.SchedulerTimeType.Stride) -> Bool

            /// Multiplies two values and produces their product.
            ///
            /// The multiplication operator (`*`) calculates the product of its two
            /// arguments. For example:
            ///
            ///     2 * 3                   // 6
            ///     100 * 21                // 2100
            ///     -10 * 15                // -150
            ///     3.5 * 2.25              // 7.875
            ///
            /// You cannot use `*` with arguments of different types. To multiply values
            /// of different types, convert one of the values to the other value's type.
            ///
            ///     let x: Int8 = 21
            ///     let y: Int = 1000000
            ///     Int(x) * y              // 21000000
            ///
            /// - Parameters:
            ///   - lhs: The first value to multiply.
            ///   - rhs: The second value to multiply.
            public static func * (lhs: ImmediateScheduler.SchedulerTimeType.Stride, rhs: ImmediateScheduler.SchedulerTimeType.Stride) -> ImmediateScheduler.SchedulerTimeType.Stride

            /// Adds two values and produces their sum.
            ///
            /// The addition operator (`+`) calculates the sum of its two arguments. For
            /// example:
            ///
            ///     1 + 2                   // 3
            ///     -10 + 15                // 5
            ///     -15 + -5                // -20
            ///     21.5 + 3.25             // 24.75
            ///
            /// You cannot use `+` with arguments of different types. To add values of
            /// different types, convert one of the values to the other value's type.
            ///
            ///     let x: Int8 = 21
            ///     let y: Int = 1000000
            ///     Int(x) + y              // 1000021
            ///
            /// - Parameters:
            ///   - lhs: The first value to add.
            ///   - rhs: The second value to add.
            public static func + (lhs: ImmediateScheduler.SchedulerTimeType.Stride, rhs: ImmediateScheduler.SchedulerTimeType.Stride) -> ImmediateScheduler.SchedulerTimeType.Stride

            /// Subtracts one value from another and produces their difference.
            ///
            /// The subtraction operator (`-`) calculates the difference of its two
            /// arguments. For example:
            ///
            ///     8 - 3                   // 5
            ///     -10 - 5                 // -15
            ///     100 - -5                // 105
            ///     10.5 - 100.0            // -89.5
            ///
            /// You cannot use `-` with arguments of different types. To subtract values
            /// of different types, convert one of the values to the other value's type.
            ///
            ///     let x: UInt8 = 21
            ///     let y: UInt = 1000000
            ///     y - UInt(x)             // 999979
            ///
            /// - Parameters:
            ///   - lhs: A numeric value.
            ///   - rhs: The value to subtract from `lhs`.
            public static func - (lhs: ImmediateScheduler.SchedulerTimeType.Stride, rhs: ImmediateScheduler.SchedulerTimeType.Stride) -> ImmediateScheduler.SchedulerTimeType.Stride

            /// Subtracts the second value from the first and stores the difference in the
            /// left-hand-side variable.
            ///
            /// - Parameters:
            ///   - lhs: A numeric value.
            ///   - rhs: The value to subtract from `lhs`.
            public static func -= (lhs: inout ImmediateScheduler.SchedulerTimeType.Stride, rhs: ImmediateScheduler.SchedulerTimeType.Stride)

            /// Multiplies two values and stores the result in the left-hand-side
            /// variable.
            ///
            /// - Parameters:
            ///   - lhs: The first value to multiply.
            ///   - rhs: The second value to multiply.
            public static func *= (lhs: inout ImmediateScheduler.SchedulerTimeType.Stride, rhs: ImmediateScheduler.SchedulerTimeType.Stride)

            /// Adds two values and stores the result in the left-hand-side variable.
            ///
            /// - Parameters:
            ///   - lhs: The first value to add.
            ///   - rhs: The second value to add.
            public static func += (lhs: inout ImmediateScheduler.SchedulerTimeType.Stride, rhs: ImmediateScheduler.SchedulerTimeType.Stride)

            /// Converts the specified number of seconds into an instance of this scheduler time type.
            public static func seconds(_ s: Int) -> ImmediateScheduler.SchedulerTimeType.Stride

            /// Converts the specified number of seconds, as a floating-point value, into an instance of this scheduler time type.
            public static func seconds(_ s: Double) -> ImmediateScheduler.SchedulerTimeType.Stride

            /// Converts the specified number of milliseconds into an instance of this scheduler time type.
            public static func milliseconds(_ ms: Int) -> ImmediateScheduler.SchedulerTimeType.Stride

            /// Converts the specified number of microseconds into an instance of this scheduler time type.
            public static func microseconds(_ us: Int) -> ImmediateScheduler.SchedulerTimeType.Stride

            /// Converts the specified number of nanoseconds into an instance of this scheduler time type.
            public static func nanoseconds(_ ns: Int) -> ImmediateScheduler.SchedulerTimeType.Stride

            /// Creates a new instance by decoding from the given decoder.
            ///
            /// This initializer throws an error if reading from the decoder fails, or
            /// if the data read is corrupted or otherwise invalid.
            ///
            /// - Parameter decoder: The decoder to read data from.
            public init(from decoder: Decoder) throws

            /// Encodes this value into the given encoder.
            ///
            /// If the value fails to encode anything, `encoder` will encode an empty
            /// keyed container in its place.
            ///
            /// This function throws an error if any values are invalid for the given
            /// encoder's format.
            ///
            /// - Parameter encoder: The encoder to write data to.
            public func encode(to encoder: Encoder) throws

            /// Returns a Boolean value indicating whether two values are equal.
            ///
            /// Equality is the inverse of inequality. For any values `a` and `b`,
            /// `a == b` implies that `a != b` is `false`.
            ///
            /// - Parameters:
            ///   - lhs: A value to compare.
            ///   - rhs: Another value to compare.
            public static func == (a: ImmediateScheduler.SchedulerTimeType.Stride, b: ImmediateScheduler.SchedulerTimeType.Stride) -> Bool
        }
    }

    /// A type that defines options accepted by the immediate scheduler.
    public typealias SchedulerOptions = Never

    /// The shared instance of the immediate scheduler.
    ///
    /// You cannot create instances of the immediate scheduler yourself. Use only the shared instance.
    public static let shared: ImmediateScheduler

    /// Performs the action at the next possible opportunity.
    public func schedule(options: ImmediateScheduler.SchedulerOptions?, _ action: @escaping () -> Void)

    /// The immediate scheduler’s definition of the current moment in time.
    public var now: ImmediateScheduler.SchedulerTimeType { get }

    /// The minimum tolerance allowed by the immediate scheduler.
    public var minimumTolerance: ImmediateScheduler.SchedulerTimeType.Stride { get }

    /// Performs the action at some time after the specified date.
    ///
    /// The immediate scheduler ignores `date` and performs the action immediately.
    public func schedule(after date: ImmediateScheduler.SchedulerTimeType, tolerance: ImmediateScheduler.SchedulerTimeType.Stride, options: ImmediateScheduler.SchedulerOptions?, _ action: @escaping () -> Void)

    /// Performs the action at some time after the specified date, at the specified frequency, optionally taking into account tolerance if possible.
    ///
    /// The immediate scheduler ignores `date` and performs the action immediately.
    public func schedule(after date: ImmediateScheduler.SchedulerTimeType, interval: ImmediateScheduler.SchedulerTimeType.Stride, tolerance: ImmediateScheduler.SchedulerTimeType.Stride, options: ImmediateScheduler.SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable
}
```

```swift
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct ImmediateScheduler<SchedulerTimeType, SchedulerOptions>: Scheduler
where
    SchedulerTimeType: Strideable,
    SchedulerTimeType.Stride: SchedulerTimeIntervalConvertible
{
    public let minimumTolerance: SchedulerTimeType.Stride = .zero
    public let now: SchedulerTimeType

    public init(now: SchedulerTimeType) {
        self.now = now
    }

    public func schedule(options _: SchedulerOptions?, _ action: () -> Void) {
        action()
    }

    public func schedule(
        after _: SchedulerTimeType,
        interval _: SchedulerTimeType.Stride,
        tolerance _: SchedulerTimeType.Stride,
        options _: SchedulerOptions?,
        _ action: () -> Void
    ) -> Cancellable {
        action()
        return AnyCancellable {}
    }

    public func schedule(
        after _: SchedulerTimeType,
        tolerance _: SchedulerTimeType.Stride,
        options _: SchedulerOptions?,
        _ action: () -> Void
    ) {
        action()
    }
}
```

さらに簡単に ImmediateSchduler を作成できるように  
static プロパティも用意されています。

```swift
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Scheduler
where
    SchedulerTimeType == DispatchQueue.SchedulerTimeType,
    SchedulerOptions == DispatchQueue.SchedulerOptions
{
    public static var immediateScheduler: ImmediateSchedulerOf<Self> {
        ImmediateScheduler(now: SchedulerTimeType(DispatchTime(uptimeNanoseconds: 1)))
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Scheduler
where
    SchedulerTimeType == RunLoop.SchedulerTimeType,
    SchedulerOptions == RunLoop.SchedulerOptions
{
    public static var immediateScheduler: ImmediateSchedulerOf<Self> {
        ImmediateScheduler(now: SchedulerTimeType(Date(timeIntervalSince1970: 0)))
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Scheduler
where
    SchedulerTimeType == OperationQueue.SchedulerTimeType,
    SchedulerOptions == OperationQueue.SchedulerOptions
{
    public static var immediateScheduler: ImmediateSchedulerOf<Self> {
        ImmediateScheduler(now: SchedulerTimeType(Date(timeIntervalSince1970: 0)))
    }
}

/// A convenience type to specify an `ImmediateTestScheduler` by the scheduler it wraps rather than
/// by the time type and options type.
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public typealias ImmediateSchedulerOf<Scheduler> = ImmediateScheduler<
    Scheduler.SchedulerTimeType, Scheduler.SchedulerOptions
> where Scheduler: Combine.Scheduler
```

テストでは下記のように利用します。

```swift
class SchedulerTests_AnyScheduler: XCTestCase {
    var cancellables = Set<AnyCancellable>()

    func testViewModel() {
        let viewModel = HomeViewModel(
            apiClient: .mock,
            scheduler: DispatchQueue.immediateScheduler.eraseToAnyScheduler())

        var output: [[Episode]] = []
        viewModel.$episodes
            .sink { output.append($0) }
            .store(in: &self.cancellables)

        viewModel.reloadButtonTapped()
        XCTAssertEqual(output, [[], [Episode(id: 42)]])
    }
}
```

これで

- テストで非同期処理の完了を待たなければいけない
- テストで実行時間以上待たなければならない
- ViewModel にジェネリックを導入しなければならない

といった問題を解決することができました。
