# javascriptをflutterに移行するんあほだるかった

ぬん

## はじめかた

- [android studio導入からvscodeでの開発まで](https://qiita.com/shimizu-m1127/items/d8dfc2179bc01baaef6b)
(10. 「VSCode」に「Flutter」をインストールまで)

- 導入すべきvscodeの拡張機能
  Dart
  Flutter
  Flutter  Widget Snippets

- あとはいつも通りリポジトリをクローンしてね
- [初心者向け:ブランチの使い方(下のほうのブランチの活用方法ってとこ)](https://www.kagoya.jp/howto/rentalserver/webtrend/vscode/)
- [周りの変更を確認したいとき](https://envader.plus/article/368)
- パッケージのバージョン管理は、ルートのpubspec.yamlにあるよ

**新しくパッケージを入れたとき**

> [!note]  
> 1行目で依存関係をリセットして、2行目で依存関係を再構築する

```
flutter clean
flutter pub get
```

**ログの日本語化**
```
chcp 65001
```

## 開発環境
  node.js: 20.18.0
  jdk: 11.0.24([ここからwindows版ダウンロード(インストーラでもzipでも)](https://www.oracle.com/jp/java/technologies/javase/jdk11-archive-downloads.html))
  sdk: API34(Android14:Upside Down Cake)
  shared_preferences: ^2.1.0
  http: ^0.13.5
  path_provider: ^2.0.13
  file_picker: ^5.2.0
  open_file: ^3.2.1
  mobile_scanner: ^5.0.0 
  dio: ^5.0.3
  permission_handler: ^10.4.0
  intl: ^0.18.0
