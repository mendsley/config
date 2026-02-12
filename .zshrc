export PATH="$HOME/.local/bin:$PATH"

# GPG agent as SSH agent
export GPG_TTY=$(tty)
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpg-connect-agent /bye >/dev/null

# oh-my-zsh configuration
ZSH_DISABLE_COMPFIX=true
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="af-magic"
plugins=(git fzf)

# Add homebrew zsh-completions to fpath before oh-my-zsh loads
fpath=(/opt/homebrew/share/zsh-completions $fpath)

source "$ZSH/oh-my-zsh.sh"

# Autosuggestions and syntax highlighting (brew)
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# eza & bat aliases
alias ls='eza'
alias ll='eza -l'
alias la='eza -la'
alias tree='eza --tree'
alias cat='bat --plain'

# goenv
export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$PATH"
eval "$(goenv init -)"
export PATH="$GOROOT/bin:$PATH"
export PATH="$PATH:$GOPATH/bin"
