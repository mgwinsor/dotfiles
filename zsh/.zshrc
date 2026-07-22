# Initialize Antidote
zsh_plugins=${ZDOTDIR:-$HOME}/.zsh_plugins
[[ -f ${zsh_plugins}.txt ]] || touch ${zsh_plugins}.txt
fpath=($(brew --prefix)/opt/antidote/share/antidote/functions $fpath)
autoload -Uz antidote
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
	antidote bundle <${zsh_plugins}.txt >|${zsh_plugins}.zsh
fi
source ${zsh_plugins}.zsh

# Source custom files
[[ -f "${ZDOTDIR:-$HOME}/.zsh_aliases" ]] && source "${ZDOTDIR:-$HOME}/.zsh_aliases"
[[ -f "${ZDOTDIR:-$HOME}/.zsh_aichat" ]] && source "${ZDOTDIR:-$HOME}/.zsh_aichat"

# Set emacs mode
bindkey -e

# Alternate keybind to clear screen (due to tmux)
bindkey '^g' clear-screen

# Set history
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
setopt EXTENDED_HISTORY      # Save timestamp and duration for each command.
setopt INC_APPEND_HISTORY    # Append commands to the history file immediately, not just on exit.
setopt SHARE_HISTORY         # Share history between all running shells instantly.
setopt HIST_IGNORE_DUPS      # Don't save a command if it's the same as the previous one.
setopt HIST_IGNORE_ALL_DUPS  # If a command is re-run, remove the older entry.
setopt HIST_FIND_NO_DUPS     # When cycling history, don't show duplicates.
setopt HIST_REDUCE_BLANKS    # Remove superfluous blanks from history entries.

# Cache helper
_cache_source() {
	local cache="$HOME/.zsh_cache/${1}.zsh"
	mkdir -p "$HOME/.zsh_cache"
	if [[ ! -f "$cache" || -z "$cache"(#qN.mh+24) ]] || \
		{ local cmd=$(command -v $1) && [[ -n "$cmd" && "$cmd" -nt "$cache" ]]; }; then
		"$@" > "$cache" 2>/dev/null
	fi
	source "$cache"
}

# fzf
command -v fzf &> /dev/null && source <(fzf --zsh)

# Starship
command -v starship &> /dev/null && _cache_source starship init zsh

# Zoxide
command -v zoxide &> /dev/null && _cache_source zoxide init zsh

# Atuin
if command -v atuin &> /dev/null; then
  [[ -f "${ZDOTDIR:-$HOME}/.atuin/bin/env" ]] && source "${ZDOTDIR:-$HOME}/.atuin/bin/env"
  _cache_source atuin init zsh
fi

# Direnv
command -v direnv &> /dev/null && _cache_source direnv hook zsh

# SDKMAN (lazy load)
sdk() {
	unset -f sdk
	[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
	sdk "$@"
}

# nvm (lazy load)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm() {
	unset -f nvm node npm npx
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
	nvm "$@"
}
node() { nvm "$@"; }
npm() { nvm "$@"; }
npx() { nvm "$@"; }

# Load completions (should be last)
autoload -Uz compinit
if [[ -n "$HOME/.zcompdump"(#qN.mh+24) ]]; then
	compinit
else
	compinit -C
fi

# Carapace
if command -v carapace &> /dev/null; then
	export CARAPACE_BRIDGES='zsh,bash'
	zstyle ':completion:*:git:*' group-order 'main commands' 'alias commands' 'external commands'
	_cache_source carapace _carapace
fi
