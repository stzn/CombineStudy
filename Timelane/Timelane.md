＃Timelane

Xcode の Instruments を活用して  
Combine のデータの流れをヴィジュアライズするツールです。  
(RxSwift など他の Rx ライブラリにも利用できます。)

https://github.com/icanzilb/Timelane

Timelane について作者の方が解説している動画です。  
[Fixing your Combine code with the Timelane Instrument](https://www.youtube.com/watch?v=QfGZUfLw5AA)

# セットアップ

※　今回は Swift Package Manager を利用しますが  
Carthage や Cocoapods でも利用可能です

## Instruments テンプレートのインストール

[インストールページ](https://github.com/icanzilb/Timelane/releases)より最新の app ファイルをダウンロードします。

ダウンロードしたファイルを開いたページの  
② に従ってテンプレートをダウンロードします。

![セットアップ1](1.png)
<br/>
<br/>
<br/>
正常にインストールされると下記のようにメニューの中に出てきます。

![セットアップ2](3.png)

<br/>
<br/>

## プロジェクトへの設定

③ で Combine を選択すると  
プロジェクトへの設定方法が出てくるので  
これに従ってプロジェクトに追加します。

![セットアップ3](2.png)

### 1. Swift Package Manager を選択

![セットアップ4](4.png)

### 2. URL を入力して Next を押す

![セットアップ5](5.png)

### 3. Next を押す(設定はそのままで良いと思います)

![セットアップ6](6.png)

### 4. 正しいライブラリが設定されいることを確認し Finish を押す

![セットアップ7](7.png)

### 5. 正しくインストールされてれば下記のようにプロジェクト内に出てきます。

![セットアップ8](8.png)

![セットアップ9](9.png)

## 使用方法

### TimelaneCombine をインポートする

![セットアップ10](10.png)

### チェックしたい Publisher から lane メソッドを呼ぶ

![セットアップ11](11.png)

### Instruments を起して（Cmd + I）を Timelane を選択する

![セットアップ12](12.png)

### 左上のスタートボタンを押す

![セットアップ13](13.png)

### アプリの操作を行うと Publisher の出力結果が表示される

下記のケースは TextField に値を入力すると  
Publisher から Output が出力されています。

![セットアップ14](14.png)
