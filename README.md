# javascriptをflutterに移行するんあほだるかった

ぬん

## はじめかた

- [android studio導入からvscodeでの開発まで](https://qiita.com/shimizu-m1127/items/d8dfc2179bc01baaef6b)
(10. 「VSCode」に「Flutter」をインストールまで)

### Android SDK 34 のインストール(以下chatgpt)
- Android Studio を開きます。
- メニューから File > Settings > Appearance & Behavior > System Settings > Android SDK を選択します。
- SDK Platforms タブで Android 34 をチェックしてインストールします。

### java17のダウンロード
jdk: 17.0.12([ここからwindows版ダウンロード(インストーラでもzipでも)](https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html))

> [!note]
> ダウンロードしたjavaフォルダ(jdk-17.0.12)は、C:\Program Files\Java\jdk-17.0.12となるように置こう

### いれる必要のある環境変数

|変数|値|必要性|
|---|---|---|
|ANDROID_HOME|android studio導入時のパス<br>(インストールパスとかいじってないなら)<br>C:\Users\\{ユーザー名}\AppData\Local\Android\Sdk|何回もいれるのだるいから変数化|
|PATH|%ANDROID_HOME%\platforms|android関係のコマンドに必要|
||%ANDROID_HOME%\tools|android関係のコマンドに必要|
||%ANDROID_HOME%\platform-tools|android関係のコマンドに必要|
||C:\Users\\{ユーザー名}\AppData\Local\Pub\Cache\bin|コマンドに必要|

### 導入すべきvscodeの拡張機能
- Dart
- Flutter
- Flutter  Widget Snippets

### あとはいつも通りリポジトリをクローンしてね
- [初心者向け:ブランチの使い方(下のほうのブランチの活用方法ってとこ)](https://www.kagoya.jp/howto/rentalserver/webtrend/vscode/)
- [周りの変更を確認したいとき](https://envader.plus/article/368)
- パッケージのバージョン管理は、ルートのpubspec.yamlにあるよ

## コマンド
**新しくパッケージを入れたとき**

> [!note]  
> 1行目で依存関係をリセットして、2行目で依存関係を再構築する

```
flutter clean
flutter pub get
```

**デバッグしたいとき**

> [!tip]
> pcと実機をusb接続(usbデバッグon)していると、自動的に実機でのデバッグになるよ(最初だけ5分程度かかる)

```
flutter run
```

**ログの日本語化**
```
chcp 65001
```

## 開発環境
  - node.js: 20.18.0
  - jdk: 17.0.12
  - sdk: API34(Android14:Upside Down Cake)
  - shared_preferences: ^2.1.0
  - http: ^0.13.5
  - path_provider: ^2.0.13
  - file_picker: ^5.2.0
  - open_file: ^3.2.1
  - mobile_scanner: ^5.0.0 
  - dio: ^5.0.3
  - permission_handler: ^10.4.0
  - intl: ^0.18.0
