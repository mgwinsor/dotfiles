#!/bin/bash

# Sets up the environment by installing dependencies.
# This script is idempotent. Currently macOS-focused.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [[ "$(uname -s)" != "Darwin" ]]; then
	echo "⚠️  This script is macOS-focused. Some steps may not work on $(uname -s)."
fi

if ! command -v brew &> /dev/null; then
	echo "📦 Installing Homebrew..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
	echo "✅ Homebrew is already installed."
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
	eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
	eval "$(/usr/local/bin/brew shellenv)"
fi

echo "📦 Installing Homebrew packages from Brewfile..."
brew bundle --file="$SCRIPT_DIR/Brewfile"

if command -v herdr &> /dev/null; then
	echo "✅ Herdr is already installed."
else
	echo "📦 Installing Herdr..."
	export HERDR_INSTALL_DIR="${HERDR_INSTALL_DIR:-$HOME/.local/bin}"
	curl -fsSL https://herdr.dev/install.sh | sh
	export PATH="$HERDR_INSTALL_DIR:$PATH"
fi

if [[ "$(herdr plugin list --json)" == *'"id":"herdr-nvim-nav"'* ]]; then
	echo "✅ Herdr Neovim navigation plugin is already installed."
else
	echo "📦 Installing Herdr Neovim navigation plugin..."
	herdr plugin install aimdevlee/herdr-nvim-nav --yes
fi

TPM_DIR="$HOME/.tmux/plugins/tpm"
CATPPUCCIN_DIR="$HOME/.config/tmux/plugins/catppuccin/tmux"

if [ ! -d "$TPM_DIR" ]; then
	echo "📦 Installing Tmux Plugin Manager (TPM)..."
	mkdir -p "$(dirname "$TPM_DIR")"
	git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
	echo "✅ Tmux Plugin Manager (TPM) is already installed."
fi

if [ ! -d "$CATPPUCCIN_DIR" ]; then
	echo "📦 Installing Tmux Catppuccin Theme..."
	mkdir -p "$HOME/.config/tmux/plugins/catppuccin"
	git clone -b v2.1.3 https://github.com/catppuccin/tmux.git "$CATPPUCCIN_DIR"
else
	echo "✅ Tmux Catppuccin Theme is already installed."
fi

echo "📦 Stowing dotfiles..."
mkdir -p "$HOME/.config/herdr"
stow -d "$SCRIPT_DIR" --target "$HOME" nvim tmux zsh starship ghostty alacritty taskwarrior opencode herdr
