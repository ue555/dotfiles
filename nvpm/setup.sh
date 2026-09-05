#!/bin/sh

set -eu

DOTFILES_DIR=$(CDPATH= cd "$(dirname "$0")" && pwd)
NVPM_REPOSITORY=${NVPM_REPOSITORY:-https://github.com/ue555/nvpm.git}
NVPM_SOURCE_DIR=${NVPM_SOURCE_DIR:-"${XDG_CACHE_HOME:-$HOME/.cache}/nvpm/source"}
INSTALL_DIR=${INSTALL_DIR:-"$HOME/.local/bin"}
NODE_VERSION=${NODE_VERSION:-v24.20.0}
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

install_nvpm() {
  mkdir -p "$(dirname "$NVPM_SOURCE_DIR")" "$INSTALL_DIR"

  if [ -d "$NVPM_SOURCE_DIR/.git" ]; then
    info "Updating nvpm source"
    git -C "$NVPM_SOURCE_DIR" pull --ff-only
  elif [ -e "$NVPM_SOURCE_DIR" ]; then
    printf '%s\n' "error: $NVPM_SOURCE_DIR exists but is not an nvpm Git checkout" >&2
    exit 1
  else
    info "Cloning nvpm"
    git clone "$NVPM_REPOSITORY" "$NVPM_SOURCE_DIR"
  fi

  info "Building nvpm"
  build_output=$(mktemp "${TMPDIR:-/tmp}/nvpm.XXXXXX")
  trap 'rm -f "$build_output"' EXIT HUP INT TERM
  (
    cd "$NVPM_SOURCE_DIR"
    go build -o "$build_output" ./cmd/nvpm
  )
  install -m 0755 "$build_output" "$INSTALL_DIR/nvpm"
  rm -f "$build_output"
  trap - EXIT HUP INT TERM
}

verify_sha256() {
  expected=$1
  file=$2

  if command -v sha256sum >/dev/null 2>&1; then
    printf '%s  %s\n' "$expected" "$file" | sha256sum -c -
    return
  fi

  if command -v shasum >/dev/null 2>&1; then
    actual=$(shasum -a 256 "$file" | awk '{ print $1 }')
    if [ "$actual" != "$expected" ]; then
      printf '%s\n' "error: checksum verification failed for $file" >&2
      exit 1
    fi
    printf '%s\n' "$file: OK"
    return
  fi

  printf '%s\n' "error: sha256sum or shasum is required" >&2
  exit 1
}

install_node() {
  if command -v npm >/dev/null 2>&1 && npm --version >/dev/null 2>&1; then
    info "Using npm $(npm --version) from $(command -v npm)"
    return
  fi

  case "$(uname -s)" in
    Linux)
      node_platform=linux
      ;;
    Darwin)
      node_platform=darwin
      ;;
    *)
      printf '%s\n' "error: unsupported operating system for Node.js: $(uname -s)" >&2
      exit 1
      ;;
  esac

  case "$(uname -m)" in
    x86_64)
      node_arch=x64
      ;;
    aarch64|arm64)
      node_arch=arm64
      ;;
    *)
      printf '%s\n' "error: unsupported architecture for Node.js: $(uname -m)" >&2
      exit 1
      ;;
  esac

  archive_name="node-${NODE_VERSION}-${node_platform}-${node_arch}.tar.gz"
  node_dir="$HOME/.local/opt/node-${NODE_VERSION}-${node_platform}-${node_arch}"

  if [ ! -x "$node_dir/bin/node" ] || [ ! -x "$node_dir/bin/npm" ]; then
    if [ -e "$node_dir" ]; then
      printf '%s\n' "error: incomplete Node.js installation exists: $node_dir" >&2
      exit 1
    fi

    mkdir -p "$HOME/.local/opt"
    staging=$(mktemp -d "$HOME/.local/.node-install.XXXXXX")
    archive="$staging/$archive_name"
    checksums="$staging/SHASUMS256.txt"
    trap 'rm -f "$archive" "$checksums"; rmdir "$staging" 2>/dev/null || true' EXIT HUP INT TERM

    info "Downloading Node.js $NODE_VERSION"
    curl -fL --retry 3 -o "$checksums" "https://nodejs.org/dist/${NODE_VERSION}/SHASUMS256.txt"
    curl -fL --retry 3 -o "$archive" "https://nodejs.org/dist/${NODE_VERSION}/${archive_name}"

    checksum=$(awk -v archive="$archive_name" '$2 == archive { print $1 }' "$checksums")
    if [ -z "$checksum" ]; then
      printf '%s\n' "error: checksum not found for $archive_name" >&2
      exit 1
    fi
    verify_sha256 "$checksum" "$archive"

    tar -xzf "$archive" -C "$staging"
    mv "$staging/node-${NODE_VERSION}-${node_platform}-${node_arch}" "$node_dir"
    rm -f "$archive" "$checksums"
    rmdir "$staging"
    trap - EXIT HUP INT TERM
  fi

  for executable in node npm npx corepack; do
    if [ -e "$node_dir/bin/$executable" ]; then
      ln -sfn "$node_dir/bin/$executable" "$INSTALL_DIR/$executable"
    fi
  done

  hash -r 2>/dev/null || true
  if ! "$INSTALL_DIR/npm" --version >/dev/null 2>&1; then
    printf '%s\n' "error: Linux npm installation is not usable" >&2
    exit 1
  fi
  info "Installed Node.js $("$INSTALL_DIR/node" --version) with npm $("$INSTALL_DIR/npm" --version)"
}

install_tree_sitter_cli() {
  if command -v tree-sitter >/dev/null 2>&1 && tree-sitter --version >/dev/null 2>&1; then
    info "Using $(tree-sitter --version)"
    return
  fi

  info "Installing tree-sitter CLI"
  "$INSTALL_DIR/npm" install --global tree-sitter-cli

  npm_prefix=$("$INSTALL_DIR/npm" prefix --global)
  if [ ! -x "$npm_prefix/bin/tree-sitter" ]; then
    printf '%s\n' "error: tree-sitter CLI was not installed correctly" >&2
    exit 1
  fi

  ln -sfn "$npm_prefix/bin/tree-sitter" "$INSTALL_DIR/tree-sitter"
  hash -r 2>/dev/null || true
  info "Installed $("$INSTALL_DIR/tree-sitter" --version)"
}

install_language_servers() {
  mason_packages="bash-language-server gopls lua-language-server pyright rust-analyzer typescript-language-server"
  nvim_data_dir=$("$INSTALL_DIR/nvim" --headless -u NONE \
    "+lua io.write(vim.fn.stdpath('data'))" +qa)
  mason_root="$nvim_data_dir/mason"
  missing_packages=

  for package in $mason_packages; do
    if [ ! -f "$mason_root/packages/$package/mason-receipt.json" ]; then
      missing_packages="$missing_packages $package"
    fi
  done

  if [ -z "$missing_packages" ]; then
    info "Mason language servers are already installed"
    return
  fi

  info "Installing language servers with Mason:$missing_packages"
  NVPM_SETUP=1 "$INSTALL_DIR/nvim" --headless \
    "+MasonInstall$missing_packages" \
    +qa
}

install_treesitter_parsers() {
  info "Installing Treesitter parsers"
  NVPM_SETUP=1 "$INSTALL_DIR/nvim" --headless \
    "+lua if not require('nvim-treesitter').install(require('config.treesitter_languages')):wait(300000) then error('Treesitter parser installation failed') end" \
    +qa
}

require_command git
require_command go
require_command install
require_command nvim
require_command curl
require_command tar
require_command awk

install_nvpm
install_node
install_tree_sitter_cli

link_dotfile "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"
link_dotfile "$DOTFILES_DIR/config/nvpm" "$HOME/.config/nvpm"
link_dotfile "$DOTFILES_DIR/bin/nvpmctl" "$INSTALL_DIR/nvpmctl"
link_dotfile "$DOTFILES_DIR/nvpm-lock.json" "$HOME/.local/share/nvim/nvpm-lock.json"

info "Installing Neovim plugins"
"$INSTALL_DIR/nvpm" -config "$HOME/.config/nvpm/plugins.json" -cmd install

install_treesitter_parsers
install_language_servers

info "Setup completed"
if ! command -v nvpm >/dev/null 2>&1; then
  printf '%s\n' "Add this to your shell configuration:"
  printf '%s\n' '  export PATH="$HOME/.local/bin:$PATH"'
fi
