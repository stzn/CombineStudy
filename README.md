# このリポジトリに含まれているもの

## Recommend

これまでに参考にしたサイト、動画、本などを記載しています。  
もし良い記事やサイトなどご存知でしたら、ぜひ教えてください。

## 実行環境

Xcode12
iOS14

## Presentation

iOSDC 登壇時に使用した資料です。

スライドはこちら
https://speakerdeck.com/shiz/sorosorocombine

動画はこちら
https://www.youtube.com/watch?v=0wTld_ROx2Y&list=PLod2oSGQp3W4BV6sLUdMwlZD0NHt9mHP7&index=18

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

下記の 3 つのサンプルアプリがあります。

- UserRegistration(テキスト入力、バリデーションの検証)
- CombineCollection(リスト表示、詳細画面遷移の検証)
- ComplexUserRegistration(複数画面にまたがった場合の検証)

その中に複数のパターンがあります。

- UIKit
- UIKit + Combine
- SwiftUI + Combine

※ CombineCollection の SwiftUI + Combine は  
Grid に表示する画像の数を制限しています。
制限しないとメモリの使い過ぎでクラッシュするためです。
(Lazy な View で UICollectionView を置き換えていますが、  
Reusable ではないのでそこが起因しているのかもしれません。)  
現在調査中です。 -> DispatchQueueをConcurrencyにすることで解消された...？

## Timelane

Instruments を活用したデバッグツールのインストール方法や簡単な使用方法を紹介しています。
