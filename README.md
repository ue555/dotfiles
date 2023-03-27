# Vim の設定

## Quickstart

### 0.設定ファイル

> zshにパスを設定する

```shell
vi ~/.zprofile
```

### 1.最新版の Vim をインストールする

> Mac に Vim をインストールする

```shell
brew install vim 

# 更新時はこれだけで OK
brew update vim

brew upgrade vim
```

### 2.tmux をインストールと設定をする

```shell

brew install tmux

# ホームディレクトリに設定ファイルの作成
touch ~/.tmux.conf
```

`.tmux.conf`

```shell

# プレフィックスキーをctrl+aに変更
set -g prefix C-a

# デフォルトのプレフィックスキーctrl+bを解除
unbind C-b

# プレフィックスキー+^でペインを垂直分割する
bind ^ split-window -h

# プレフィックスキー+-でペインを水平分割する
bind - split-window -v

# 256色モードを有効化
set-option -g default-terminal screen-256color
set -g terminal-overrides 'xterm:colors=256'

# ステータスラインの文字色、背景色を変更
setw -g status-style fg=colour255,bg=colour234

# マウス操作を有効化
set-option -g mouse on
set -g mouse on
# 画面サイズ変更
bind -r h resize-pane -L 5
bind -r j resize-pane -D 5
bind -r k resize-pane -U 5
bind -r l resize-pane -R 5
```

- よく使う機能・コマンド

```shell

# ペインを垂直分割
プレフィックスキー + ^

# ペインを水平分割
プレフィックスキー + -

# ペインの破棄
プレフィックスキー + x
```

