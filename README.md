# このリポジトリに含まれているもの

## Recommend

これまでに参考にしたサイト、動画、本などを記載しています。  
もし良い記事やサイトなどご存知でしたら、ぜひ教えてください。

## 実行環境

Xcode12

## Presentation

iOSDC 登壇時に使用した資料です。

## Operators

Operator の動作を確認するための Playground 集です。  
ソースコメントにそれぞれの特徴などを記載しています。

## Publishers

Publisher の動作を確認するための Playground 集です。  
ソースコメントにそれぞれの特徴などを記載しています。

## Schedulers

Scheduler の動作を確認するための Playground 集です。  
ソースコメントそれぞれの特徴などを記載しています。

また、テスト時に Scheduler を Control する方法として  
Custom Scheduler を使用した例も含んでいます。

## SampleApp

下記の 2 つのサンプルアプリがあります。

- UserRegistration(テキスト入力、バリデーション)
- CombineCollection(リスト表示、詳細画面遷移)

その中に複数のパターンがあります。

- UIKit
- UIKit + Combine
- SwiftUI + Combine

※ CombineCollection の SwiftUI + Combine は  
実装の方法がよくないせいか、パフォーマンスがよくありません。  
(Lazy な View で UICollectionView を置き換えていますが、  
Reusable ではないのでそこが起因しているのかもしれません。)  
現在調査中です。

## Timelane

Instruments を活用したデバッグツールのインストール方法や簡単な使用方法を紹介しています。
