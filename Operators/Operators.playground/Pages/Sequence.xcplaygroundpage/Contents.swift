//: [Previous](@previous)

import Combine
import Foundation

var cancellables = Set<AnyCancellable>()

// これらのOperatorsは有限(Completionが出力される)Publisherのみで動きます
// Standard LibraryのCollectionと同じ名前で同じ働きをするものが多く存在します

// 最小値を取り出す
// OutputがComparableの場合はデフォルトの実装が利用できる
run("min 引数なし") {
    [1,2,-1,4].publisher
        .min()
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

// 最小値を取り出す
// OutputがComparableでない場合やカスタムの実装を使って比較をしたい場合は
// 引数で比較するための関数を渡す
run("min 引数あり") {
    ["1234","12345","123456","1234567"].publisher
        .compactMap { $0.data(using: .utf8) }
        .min(by: { $0.count < $1.count })
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

// 最大値を取り出す
// OutputがComparableの場合はデフォルトの実装が利用できる
run("max 引数なし") {
    [1,2,-1,4].publisher
        .max()
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

// 最大値を取り出す
// OutputがComparableでない場合やカスタムの実装を使って比較をしたい場合は
// 引数に比較するための関数を渡す
run("max 引数あり") {
    ["1234","12345","123456","1234567"].publisher
        .compactMap { $0.data(using: .utf8) }
        .max(by: { $0.count < $1.count })
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

// 最初のOutputを取り出す
// lazyに実行され(Outputが出力されるたびに判定され)
// 見つかったタイミングでCancelされる
run("first 引数なし") {
    [1,2,3,4].publisher
        .print()
        .first()
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

// 条件にあった最初のOutputを取り出す
// lazyに実行され(Outputが出力されるたびに判定され)
// 見つかったタイミングでCancelされる
run("first 引数あり") {
    [1,2,3,4].publisher
        .print()
        .first(where: { $0 > 2 })
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

// 最後のOutputを取り出す
// PublisherがCompletionを出力するまで判定はされない(パフォーマンスに注意が必要)
run("last 引数なし") {
    [1,2,3,4].publisher
        .print()
        .last()
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

// 条件にあった最後のOutputを取り出す
// PublisherがCompletionを出力するまで判定はされない(パフォーマンスに注意が必要)
run("last 引数あり") {
    [1,2,3,4].publisher
        .print()
        .last(where: { $0 > 2 })
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

// 最後のOutputを取り出す
// PublisherがCompletionを出力するまで判定はされない(パフォーマンスに注意が必要)
run("last 引数なし") {
    [1,2,3,4].publisher
        .print()
        .last()
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

// 指定したN番目のOutputを取り出す
// Outputを受け取ると次のOutputのみを要求しているのがわかる(request max: (1) (synchronous))
// 出力されるとPublisherにCancelを要求する
run("output(at:)") {
    [1,2,3,4].publisher
        .print()
        .output(at: 2)
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

// 指定したN〜M番目のOutputを取り出す
// Outputを受け取ると次のOutputのみを要求しているのがわかる(request max: (1) (synchronous))
// 全て出力されるとPublisherにCancelを要求する
run("output(in:)") {
    [1,2,3,4].publisher
        .print()
        .output(in: 1...2)
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

// Outputの数の合計を出力する
run("count") {
    [1,2,3,4].publisher
        .print()
        .count()
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

// Outputに条件に該当する値が含まれているかどうかを出力する
// 見つかった時点でPublisherにCancelを要求する
run("contains 引数なし") {
    [1,2,3,4].publisher
        .print()
        .contains(3)
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

// Outputに条件に該当する値が含まれているかどうかを出力する
// 見つかった時点でPublisherにCancelを要求する
run("contains 引数あり") {
    [1,2,3,4].publisher
        .print()
        .contains(where: { $0 == 4 })
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

// 全てのOutputが条件に該当するかどうかを出力する
run("allSatisfy") {
    [2,4,6].publisher
        .allSatisfy { $0.isMultiple(of: 2) }
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

// 引数に渡した初期値とOutputを引数で渡した関数で計算し
// さらにその結果と次のOutputを関数で計算する
// 最終的な結果のみを出力する(scanと異なる)
run("reduce") {
    [1,2,3,4,5].publisher
        .reduce(0, +)
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}


//: [Next](@next)

