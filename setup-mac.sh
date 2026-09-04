#!/bin/zsh
ROOT="${0:A:h}"

# Install configuration: selects which components and packages to install.
# A missing file or missing key means "install everything". A user may keep a
# personal install.config.local.json (untracked, gitignored) next to the
# tracked file; when present it is used instead, so personal preferences never
# touch tracked files.
INSTALL_CONFIG="$ROOT/install.config.json"
if [ -f "$ROOT/install.config.local.json" ]; then
    echo "Using local install configuration override: $ROOT/install.config.local.json"
    INSTALL_CONFIG="$ROOT/install.config.local.json"
fi

component_enabled() {
    python3 - "$INSTALL_CONFIG" "$1" <<'PYEOF'
import json, os, sys
path, name = sys.argv[1], sys.argv[2]
enabled = True
if os.path.exists(path):
    enabled = bool(json.load(open(path)).get("components", {}).get(name, True))
sys.exit(0 if enabled else 1)
PYEOF
}

if component_enabled packages; then
    # Install Homebrew if not present
    if ! command -v brew &>/dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    # Homebrew packages from packages.json, minus packages.exclude from the
    # install configuration
    python3 - "$ROOT/packages.json" "$INSTALL_CONFIG" <<'PYEOF'
import json, os, sys, subprocess
d = json.load(open(sys.argv[1]))

exclude = set()
if os.path.exists(sys.argv[2]):
    cfg = json.load(open(sys.argv[2]))
    exclude = set(cfg.get("packages", {}).get("exclude", []))

formulae, casks = [], []
for p in d["packages"]:
    if isinstance(p, str):
        continue  # scoop-only
    name = p["name"]
    if name in exclude:
        print(f"Skipping excluded package {name}")
        continue
    brew = p.get("brew")
    brew_cask = p.get("brew_cask")
    if brew_cask:
        casks.append(name if brew_cask is True else brew_cask)
    elif brew:
        formulae.append(name if brew is True else brew)

for f in d.get("mac_extras", {}).get("formulae", []):
    if f in exclude:
        print(f"Skipping excluded package {f}")
        continue
    formulae.append(f)
for c in d.get("mac_extras", {}).get("casks", []):
    if c in exclude:
        print(f"Skipping excluded package {c}")
        continue
    casks.append(c)

if formulae:
    subprocess.run(["brew", "install"] + formulae)
if casks:
    subprocess.run(["brew", "install", "--cask"] + casks)
PYEOF
fi

# Install oh-my-zsh (unattended, don't replace .zshrc)
if component_enabled shell; then
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
fi

# Install latest Go via goenv if no version is installed
if component_enabled go; then
    eval "$(goenv init -)"
    if [ -z "$(goenv versions --bare 2>/dev/null)" ]; then
        LATEST_GO=$(goenv install -l | grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+$' | tail -1 | tr -d ' ')
        goenv install "$LATEST_GO"
        goenv global "$LATEST_GO"
    fi
fi

# git configuration
if component_enabled git; then
    rm -f $HOME/.gitconfig
    ln -s "$ROOT/.gitconfig" $HOME/.gitconfig
    rm -f $HOME/.gitconfig-mac
    ln -s "$ROOT/.gitconfig-mac" $HOME/.gitconfig-mac
    git lfs install
fi

# neovim configuration
if component_enabled nvim; then
    mkdir -p $HOME/.config
    rm -rf $HOME/.config/nvim
    ln -s "$ROOT/nvim" $HOME/.config/nvim
fi

# SSH configuration
if component_enabled ssh; then
    if [ ! -d $HOME/.ssh ]; then
        mkdir $HOME/.ssh
        chmod 0700 $HOME/.ssh
    fi
    rm -f $HOME/.ssh/config
    ln -s "$ROOT/ssh_config" $HOME/.ssh/config
fi

# zsh configuration
if component_enabled shell; then
    rm -f $HOME/.zshrc
    ln -s "$ROOT/.zshrc" $HOME/.zshrc
fi

# GPG configuration
if component_enabled gpg; then
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
fi

echo "Run 'source ~/.zshrc' or restart your shell to pick up changes."
