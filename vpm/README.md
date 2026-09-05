# vpm dotfiles

[`ue555/vpm`](https://github.com/ue555/vpm) で管理する Vim 環境です。
設定はこのディレクトリに置き、`setup.sh` が Vim と vpm の標準パスへ
シンボリックリンクします。

## 必要なもの

- Vim 8.0 以上
- Git 2.19 以上
- Go 1.21 以上

Arch Linux では Vim を次のコマンドでインストールできます。

```sh
sudo pacman -S vim
```

macOS では事前に以下を実行してください。

```sh
brew install vim git go
xcode-select --install
```

## セットアップ

```sh
cd ~/dotfiles/vpm
./setup.sh
```

`setup.sh` は次を行います。

1. `github.com/ue555/vpm` を `~/.cache/vpm/source` に取得してビルド
2. `vpm` を `~/.local/bin/vpm` にインストール
3. `vimrc` を `~/.vimrc` へリンク
4. `config/vpm` を `~/.config/vpm` へリンク
5. `vpm-lock.json` を `~/.vim/vpm-lock.json` へリンク
6. Vim プラグインを `~/.vim/pack/vpm/start` にインストール

既存のリンク先がある場合は、同じディレクトリに
`.backup.YYYYMMDDHHMMSS` を付けて退避します。

## vpm の操作

```sh
vpmctl install
vpmctl update
vpmctl sync
vpmctl clean
vpmctl list
```

インストールや更新後は、このディレクトリの `vpm-lock.json` も Git に
コミットしてください。

## ディレクトリ構成

```text
vpm/
├── bin/vpmctl
├── config/vpm/plugins.json
├── vim/
│   ├── options.vim
│   ├── keymaps.vim
│   └── plugins.vim
├── vimrc
├── vpm-lock.json
└── setup.sh
```

プラグインを追加・削除するときは `config/vpm/plugins.json` と、必要に応じて
`vim/plugins.vim` を編集してください。

> [!NOTE]
> 現行 vpm はロックファイルを記録しますが、ロックファイルから復元する
> コマンドはまだ提供していません。
