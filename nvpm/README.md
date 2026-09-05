# nvpm dotfiles

`nvpm` で管理する Neovim 環境です。設定はすべてこのディレクトリに置き、
`setup.sh` が XDG の標準パスへシンボリックリンクします。

## 必要なもの

- Neovim 0.11 以上
- Git 2.19 以上
- Go 1.21 以上
- `make` と C コンパイラ（Treesitter parser のビルド用）

Node.js/npm がない場合、または WSL から Windows 側の npm を参照している場合は、
`setup.sh` が Linux/macOS 用 Node.js LTS を `~/.local/opt` にインストールします。
Treesitter parser のビルドに必要な `tree-sitter-cli` も npm から自動導入します。

macOS では事前に Homebrew などで必要なコマンドを用意してください。

```sh
brew install neovim git go
xcode-select --install
```

## セットアップ

```sh
cd ~/dotfiles/nvpm
./setup.sh
```

`setup.sh` は次を行います。

1. `github.com/ue555/nvpm` を `~/.cache/nvpm/source` に取得してビルド
2. `nvpm` を `~/.local/bin/nvpm` にインストール
3. このディレクトリの設定を `~/.config/nvim` と `~/.config/nvpm` へリンク
4. ロックファイルを `~/.local/share/nvim/nvpm-lock.json` へリンク
5. 設定済みプラグインをインストール
6. Treesitter parser をインストール
7. Mason で設定済み LSP サーバーをインストール

既存のリンク先がある場合は、同じディレクトリに
`.backup.YYYYMMDDHHMMSS` を付けて退避します。

`~/.local/bin` が `PATH` に含まれていない場合は、利用中のシェル設定へ
次を追加してください。

```sh
export PATH="$HOME/.local/bin:$PATH"
```

## nvpm の操作

設定ファイルのパスを毎回指定せず、`nvpmctl` から操作できます。

```sh
nvpmctl install
nvpmctl update
nvpmctl sync
nvpmctl restore
nvpmctl check
nvpmctl list
nvpmctl stats
```

`install`、`update`、`sync` を実行すると、このディレクトリの
`nvpm-lock.json` が更新されます。変更後はロックファイルも Git に
コミットしてください。

## ディレクトリ構成

```text
nvpm/
├── bin/nvpmctl
├── config/
│   ├── nvpm/plugins.json
│   └── nvim/
│       ├── init.lua
│       └── lua/
│           ├── config/
│           └── plugins/
├── nvpm-lock.json
└── setup.sh
```

プラグインを追加・削除するときは `config/nvpm/plugins.json` と対応する
`config/nvim/lua/plugins/*.lua` を編集します。現行 nvpm の遅延ロード指定と
`config` 文字列は Neovim 内では実行されないため、プラグイン設定は Lua 側で
明示的に読み込んでいます。
