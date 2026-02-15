#!/bin/zsh
ROOT="${0:A:h}"

# Install Homebrew if not present
if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Homebrew packages from packages.json
python3 - "$ROOT/packages.json" <<'PYEOF'
import json, sys, subprocess
d = json.load(open(sys.argv[1]))

formulae, casks = [], []
for p in d["packages"]:
    if isinstance(p, str):
        continue  # scoop-only
    brew = p.get("brew")
    brew_cask = p.get("brew_cask")
    name = p["name"]
    if brew_cask:
        casks.append(name if brew_cask is True else brew_cask)
    elif brew:
        formulae.append(name if brew is True else brew)

for f in d.get("mac_extras", {}).get("formulae", []):
    formulae.append(f)
for c in d.get("mac_extras", {}).get("casks", []):
    casks.append(c)

if formulae:
    subprocess.run(["brew", "install"] + formulae)
if casks:
    subprocess.run(["brew", "install", "--cask"] + casks)
PYEOF

# Install oh-my-zsh (unattended, don't replace .zshrc)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install latest Go via goenv if no version is installed
eval "$(goenv init -)"
if [ -z "$(goenv versions --bare 2>/dev/null)" ]; then
    LATEST_GO=$(goenv install -l | grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+$' | tail -1 | tr -d ' ')
    goenv install "$LATEST_GO"
    goenv global "$LATEST_GO"
fi

# Install beads
go install github.com/steveyegge/beads/cmd/bd@latest

# git configuration
rm -f $HOME/.gitconfig
ln -s "$ROOT/.gitconfig" $HOME/.gitconfig
rm -f $HOME/.gitconfig-mac
ln -s "$ROOT/.gitconfig-mac" $HOME/.gitconfig-mac
git lfs install

# neovim configuration
mkdir -p $HOME/.config
rm -rf $HOME/.config/nvim
ln -s "$ROOT/nvim" $HOME/.config/nvim

# SSH configuration
if [ ! -d $HOME/.ssh ]; then
    mkdir $HOME/.ssh
    chmod 0700 $HOME/.ssh
fi
rm -f $HOME/.ssh/config
ln -s "$ROOT/ssh_config" $HOME/.ssh/config

# zsh configuration
rm -f $HOME/.zshrc
ln -s "$ROOT/.zshrc" $HOME/.zshrc

# GPG configuration
mkdir -p "$HOME/.gnupg"
chmod 0700 "$HOME/.gnupg"
if ! grep -q "use-agent" "$HOME/.gnupg/gpg.conf" 2>/dev/null; then
    echo "use-agent" >> "$HOME/.gnupg/gpg.conf"
fi
if ! grep -q "use-keyboxd" "$HOME/.gnupg/common.conf" 2>/dev/null; then
    echo "use-keyboxd" >> "$HOME/.gnupg/common.conf"
fi
if ! grep -q "pinentry-program" "$HOME/.gnupg/gpg-agent.conf" 2>/dev/null; then
    echo "pinentry-program /opt/homebrew/bin/pinentry-mac" >> "$HOME/.gnupg/gpg-agent.conf"
fi
if ! grep -q "enable-ssh-support" "$HOME/.gnupg/gpg-agent.conf" 2>/dev/null; then
    echo "enable-ssh-support" >> "$HOME/.gnupg/gpg-agent.conf"
fi

echo "Run 'source ~/.zshrc' or restart your shell to pick up changes."
