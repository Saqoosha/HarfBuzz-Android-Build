# HarfBuzz Android ビルドセットアップガイド

このガイドでは、HarfBuzzライブラリをAndroidアプリケーション用の静的ライブラリとしてビルドする方法を説明します。

## 必要条件

- Linux または macOS 環境
- インターネット接続
- 以下のツール:
  - wget
  - unzip
  - CMake (バージョン 3.10 以上)
  - Bash シェル
  - Git

## セットアップ手順

1. このリポジトリをクローンします:

```bash
git clone https://github.com/Saqoosha/HarfBuzz-Android-Build.git
cd HarfBuzz-Android-Build
```

2. HarfBuzzのサブモジュールを初期化します:

```bash
git submodule update --init --recursive
```

3. ビルドスクリプトを実行します:

```bash
./scripts/build.sh
```

このスクリプトは以下の処理を自動的に行います:

- Android NDK (r26c) のダウンロードとセットアップ
- HarfBuzz バージョン 11.1.0 のソースコードの確認
- arm64-v8a および armeabi-v7a ABI 向けの静的ライブラリのビルド
- ビルドされたライブラリの `libs/` ディレクトリへのコピー

ビルドが完了すると、以下のディレクトリ構造が作成されます:

```
HarfBuzz-Android-Build/
├── libs/
│   ├── arm64-v8a/
│   │   ├── libharfbuzz.a
│   │   └── libharfbuzz-subset.a
│   └── armeabi-v7a/
│       ├── libharfbuzz.a
│       └── libharfbuzz-subset.a
├── build/
│   ├── arm64-v8a/
│   └── armeabi-v7a/
├── src/
│   └── harfbuzz/  # HarfBuzzのサブモジュール
└── android-ndk-r26c/
```

## Androidアプリでの使用方法

### CMakeを使用する場合

1. 静的ライブラリファイル (`libharfbuzz.a`) をあなたのプロジェクトの適切な場所にコピーします。

2. CMakeLists.txt に以下を追加します:

```cmake
add_library(harfbuzz STATIC IMPORTED)
set_target_properties(harfbuzz PROPERTIES
    IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/path/to/libs/${ANDROID_ABI}/libharfbuzz.a
)

# あなたのアプリケーションとリンク
target_link_libraries(your_app harfbuzz)
```

### ヘッダーファイル

HarfBuzzのヘッダーファイルは `libs/[ABI]/include/harfbuzz/` ディレクトリにあります。これらをあなたのプロジェクトにインクルードして使用してください。

## トラブルシューティング

### ビルドエラー

ビルド中にエラーが発生した場合:

1. 必要なツールがすべてインストールされていることを確認してください。
2. インターネット接続を確認してください（Android NDKのダウンロードに必要です）。
3. 十分なディスク容量があることを確認してください。
4. サブモジュールが正しく初期化されていることを確認してください。

### 互換性の問題

特定のAndroidバージョンで互換性の問題が発生した場合は、`build.sh`スクリプト内の`ANDROID_API_LEVEL`変数を調整してください。

## カスタマイズ

ビルドプロセスをカスタマイズする必要がある場合は、`scripts/build.sh`ファイルを編集してください。主な設定変数は以下の通りです:

- `HARFBUZZ_VERSION`: ビルドするHarfBuzzのバージョン
- `NDK_VERSION`: 使用するAndroid NDKのバージョン
- `ANDROID_API_LEVEL`: ターゲットとするAndroid APIレベル
- `ABIS`: ビルドするABIのリスト
