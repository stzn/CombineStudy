Combine を学習するにあたり、

- 参考になるサイト
- 動画
- 書籍の情報

などを記載しています。

もしおすすめの情報などございましたら教えていただけると嬉しいです。

# サイト

Apple の公式ドキュメントです。  
クラスやメソッドのリファレンスもそうですが、複数の使い方に関する記事も参考になります。  
[Apple 公式ドキュメント](https://developer.apple.com/documentation/combine)

コミュニティが運営している Combine のグループです。  
Slack で質問ができたり Github に便利なライブラリが用意されています。  
[Combine Community](https://combine.community/)

Combine の情報が体系的にまとめられています。(下記で紹介する本と同じ内容です。)  
[Using Combine](https://heckj.github.io/swiftui-notes/)

Combine だけではなく様々な Swift や Apple フレームワークに関する情報が記載されています。下記は「Combine」が付いた記事へのリンクです。  
[SwiftBySundell](https://swiftbysundell.com/tags/combine/)

Combine でまとめられている訳ではありませんが、Combine の内容も豊富に含まれています。  
記事は 1 ポイントに絞られているため短くて読みやすく  
Youtube でライブコーディングをしながらの解説も大変わかりやすいです。  
[Hacking with Swift](https://www.hackingwithswift.com/)

元 Kickstarter の iOS エンジニア 2 人が運営するサイトです。(一部有料)  
Swift を使って関数型プログラミングの概念の解説やライブラリの作成などエピソードを通して行なっています。  
Combine に関しては The Composable Architecture というライブラリの作成の中で  
多くの要素が解説されています。  
[Pointfree](https://www.pointfree.co/)

# 記事

raywenderlich の Combine の紹介記事です。  
記事を読みながらサンプルを構築していくので実装を通して学ぶことができます。  
[Combine: Getting Started](https://www.raywenderlich.com/7864801-combine-getting-started)

raywenderlich の MVVM + Combine の紹介記事です。  
[MVVM with Combine Tutorial for iOS](https://www.raywenderlich.com/4161005-mvvm-with-combine-tutorial-for-ios)

Operator の動きの解説と実際に使用した場合の例などが記載されています。  
[Problem Solving with Combine Swift](https://medium.com/flawless-app-stories/problem-solving-with-combine-swift-4751885fda77)

これを活用した例が CombineCocoa というライブラリにたくさんあります。  
[UIControl を Publisher にする](https://www.avanderlee.com/swift/custom-combine-publisher/)

Custom Publisher の作成方法を通して、Combine の仕組みがわかります。  
[Building custom Combine publishers in Swift](https://swiftbysundell.com/articles/building-custom-combine-publishers-in-swift/)

# Video

## WWDC

[Introducing Combine and Advances in Foundation](https://developer.apple.com/wwdc19/711)

[Combine in Practice](https://developer.apple.com/videos/play/wwdc2019/721/)

[Advances in Networking](https://developer.apple.com/wwdc19/712)

## Others

Combine の基本を紹介しています。個人的にはこの紹介が非常にわかりやすいです。  
[Getting Started with Combine](https://www.youtube.com/watch?v=R7KgBgvQJ0c)

Combine + SwiftUI の基本的な理解や実際にアプリを作成する過程を見ながら学習します(ちょっと長いです)  
[Getting Started with Combine and SwiftUI in iOS](https://www.youtube.com/watch?v=fwXv7y2XkDQ)

UIKit + Combine の紹介をしています。  
ライブコーディングをしているので、英語がわからなくてもコードを追っていけます。  
[iOS 13 Swift Tutorial: Combine Framework - A Practical Introduction with UIKit](https://www.youtube.com/watch?v=RysM_XPNMTw)

これまでの Delagete パターンなどと比べて  
何がどう変わったのかをわかりやすく解説しています。  
[SwiftUI & Combine](https://www.youtube.com/watch?v=vDzIeFzGAuU)

# ライブラリ

Pointfree で作成された Combine をベースに作成されたライブラリです。  
かなりカスタマイズされていますがコードを見ると  
Combine のコンセプトや仕組み、活用方法など大変参考になります。  
[The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)

RxSwift とを UIKit でも使いやすくしています。  
[RxCombine](http://github.com/CombineCommunity/RxCombine)

Combine を UIKit でも使いやすくしています。  
[CombineCocoa](http://github.com/CombineCommunity/CombineCocoa)

macOS 10.15、iOS 13 よりも前のバージョンでも Combine を利用可能にするライブラリ  
[OpenCombine](https://github.com/broadwaylamb/OpenCombine)

Custom の Operator や Publisher、テスト用のライブラリ、RxSwift との互換ライブラリなど  
[Entwine](https://github.com/tcldr/Entwine)

Version ５から Combine を使った実装が追加されました。  
[Realm + Combine](https://levelup.gitconnected.com/using-realm-with-combine-288afa199b33)

# 本

[Combine: Asynchronous Programming with Swift](https://store.raywenderlich.com/products/combine-asynchronous-programming-with-swift)

[Using Combine](https://heckj.github.io/swiftui-notes/)

[Practical Combine](https://gumroad.com/l/practical-combine)

# Tips

[非同期処理を Serial に実行する方法](https://stackoverflow.com/questions/59743938/combine-framework-serialize-async-operations)

Apple の`dataTaskPublisher`の実装です。Custom Publisher を作成する時に何が必要なのかがわかります。  
[Custom Publisher の作成方法](https://github.com/apple/swift/blob/master/stdlib/public/Darwin/Foundation/Publishers%2BURLSession.swift)

Custom Publisher をどう作成するのかについての意見が述べられています。  
[Custom Publisher の作成方法に関する議論](https://github.com/CombineCommunity/CombineCocoa/pull/7#discussion_r313071982)
