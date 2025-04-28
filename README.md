# HarfBuzz-Android-Build

HarfBuzzライブラリのAndroidアプリケーション用静的ライブラリビルドスクリプト。

## 概要

このリポジトリには、HarfBuzz（バージョン11.1.0）をAndroidアプリケーション用の静的ライブラリとしてビルドするためのスクリプトが含まれています。以下のABIがサポートされています：

- arm64-v8a
- armeabi-v7a

## 使用方法

詳細なセットアップと使用方法については、[セットアップガイド](docs/SETUP.md)を参照してください。

基本的な使用方法：

```bash
# リポジトリをクローン
git clone https://github.com/Saqoosha/HarfBuzz-Android-Build.git
cd HarfBuzz-Android-Build

# サブモジュールを初期化
git submodule update --init --recursive

# ビルドスクリプトを実行
./scripts/build.sh
```

ビルドが完了すると、静的ライブラリは `libs/[ABI]/` ディレクトリに生成されます。

## ライセンス

HarfBuzzは[Old MIT/X Consortium License](https://github.com/harfbuzz/harfbuzz/blob/main/COPYING)の下で配布されています。
