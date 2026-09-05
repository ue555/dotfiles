#!/bin/sh

set -eu

DOTFILES_DIR=$(CDPATH= cd "$(dirname "$0")" && pwd)
VPM_REPOSITORY=${VPM_REPOSITORY:-https://github.com/ue555/vpm.git}
VPM_SOURCE_DIR=${VPM_SOURCE_DIR:-"${XDG_CACHE_HOME:-$HOME/.cache}/vpm/source"}
INSTALL_DIR=${INSTALL_DIR:-"$HOME/.local/bin"}
TIMESTAMP=$(date +%Y%m%d%H%M%S)

export PATH="$INSTALL_DIR:$PATH"

info() {
  printf '%s\n' "==> $*"
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf '%s\n' "error: required command not found: $1" >&2
    exit 1
  fi
}

link_dotfile() {
  source_path=$1
  target_path=$2

  mkdir -p "$(dirname "$target_path")"

  if [ -L "$target_path" ] && [ "$(readlink "$target_path")" = "$source_path" ]; then
    info "Already linked: $target_path"
    return
  fi

  if [ -e "$target_path" ] || [ -L "$target_path" ]; then
    backup_path="${target_path}.backup.${TIMESTAMP}"
    info "Backing up $target_path to $backup_path"
    mv "$target_path" "$backup_path"
  fi

  ln -s "$source_path" "$target_path"
  info "Linked $target_path -> $source_path"
}

install_vpm() {
  mkdir -p "$(dirname "$VPM_SOURCE_DIR")" "$INSTALL_DIR"

  if [ -d "$VPM_SOURCE_DIR/.git" ]; then
    info "Updating vpm source"
    git -C "$VPM_SOURCE_DIR" pull --ff-only
  elif [ -e "$VPM_SOURCE_DIR" ]; then
    printf '%s\n' "error: $VPM_SOURCE_DIR exists but is not a vpm Git checkout" >&2
    exit 1
  else
    info "Cloning vpm"
    git clone "$VPM_REPOSITORY" "$VPM_SOURCE_DIR"
  fi

  info "Building vpm"
  build_output=$(mktemp "${TMPDIR:-/tmp}/vpm.XXXXXX")
  trap 'rm -f "$build_output"' EXIT HUP INT TERM
  (
    cd "$VPM_SOURCE_DIR"
    go build -o "$build_output" ./cmd/vpm
  )
  install -m 0755 "$build_output" "$INSTALL_DIR/vpm"
  rm -f "$build_output"
  trap - EXIT HUP INT TERM
}

require_command git
require_command go
require_command install

install_vpm

link_dotfile "$DOTFILES_DIR/vimrc" "$HOME/.vimrc"
link_dotfile "$DOTFILES_DIR/config/vpm" "$HOME/.config/vpm"
link_dotfile "$DOTFILES_DIR/bin/vpmctl" "$INSTALL_DIR/vpmctl"
link_dotfile "$DOTFILES_DIR/vpm-lock.json" "$HOME/.vim/vpm-lock.json"

info "Installing Vim plugins"
"$INSTALL_DIR/vpm" -config "$HOME/.config/vpm/plugins.json" -cmd install

if command -v vim >/dev/null 2>&1; then
  info "Vim $(vim --version | sed -n '1s/^VIM - Vi IMproved //p') is available"
else
  printf '%s\n' "warning: Vim is not installed; install Vim 8.0 or newer before using this configuration" >&2
fi

info "Setup completed"
