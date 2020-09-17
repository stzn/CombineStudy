//: [Previous](@previous)

import Combine
import Foundation

var cancellables = Set<AnyCancellable>()

// collectionに指定した個数をまとめて出力する
run("collection") {
    [1,2,3,4].publisher
        .collect(2)
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

// 受け取った値を変換して出力する
run("map") {
    [1,2,3,4].publisher
        .map { "No.\($0)" }
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

// 受け取った値から新しいPublisherを生成して出力する
run("flatMap") {
    struct User {
        let name: String
        var message = PassthroughSubject<String, Never>()
        init(name: String) {
            self.name = name
        }
    }

    let user1 = User(name: "user1")
    let user2 = User(name: "user2")
    let user3 = User(name: "user3")

    let userSubject = CurrentValueSubject<User, Never>(user1)
    userSubject
        .flatMap { $0.message }
        .sink { print($0) }
        .store(in: &cancellables)

    user1.message.send("user1: Hello!")

    userSubject.value = user2
    user2.message.send("user2: Hello!")

    userSubject.value = user3
    user3.message.send("user3: Hello!")

    user1.message.send("user1: Hello!")
}

// 受け取った値をPublisherを出力する関数を適用して
// 新しいPublisherを生成する
// 複数のPublisherから値を受け取りそれを一つの新しいPublisherとして出力することができる
// Publisherが増えるだけメモリも使用するので注意が必要
// maxPublishersを指定することでアクティブなPublisherの数を制御できる(BackPressureの制御)
// 下記の場合、User1のmessageだけが出力される
run("flatMap(maxPublishers:)") {
    struct User {
        let name: String
        var message = PassthroughSubject<String, Never>()
        init(name: String) {
            self.name = name
        }
    }

    let user1 = User(name: "user1")
    let user2 = User(name: "user2")
    let user3 = User(name: "user3")

    let userSubject = CurrentValueSubject<User, Never>(user1)
    userSubject
        .flatMap(maxPublishers: .max(1)) { $0.message }
        .sink { print($0) }
        .store(in: &cancellables)

    user1.message.send("user1: Hello!")

    userSubject.value = user2
    user2.message.send("user2: Hello!")

    userSubject.value = user3
    user3.message.send("user3: Hello!")

    user1.message.send("user1: Hello!")
}

// エラーが発生した際にFailとして新しくPublisherを出力する
run("tryMap") {
    struct User: Decodable {
        let name: String
    }
    Just("invalid json".data(using: .utf8)!)
        .tryMap { data in
            try JSONDecoder().decode(User.self, from: data)
        }
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

// エラーが発生した際にFailとして新しくPublisherを出力する
run("mapError") {
    enum MyError: Error {
        case jsonDecode(Error)
    }

    func loadJSON() -> AnyPublisher<User, MyError> {
        Just("invalid json".data(using: .utf8)!)
            .tryMap { data in
                try JSONDecoder().decode(User.self, from: data)
            }
            .mapError { error in MyError.jsonDecode(error) }
            .eraseToAnyPublisher()
    }

    struct User: Decodable {
        let name: String
    }

    loadJSON()
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

// Failureの型を変換する
run("setFailureType") {
    [1,10,100,1000,10000].publisher
        // Publisher<Int, Never> -> Publisher<Int, Error>
        .setFailureType(to: Error.self)
        .sink(receiveCompletion: { finished in
            print("receiveCompletion: \(finished)")
        }, receiveValue: { value in
            print("receiveValue: \(value)")
        })
        .store(in: &cancellables)
}

//: [Next](@next)
