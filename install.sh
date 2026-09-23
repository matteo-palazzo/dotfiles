#!/usr/bin/env bash

set -euo pipefail

repository_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install_mise() {
    if command -v mise >/dev/null 2>&1; then
        return
    fi

    curl https://mise.run | sh
    export PATH="$HOME/.local/bin:$PATH"
}

backup_and_link() {
    local source_path="$1"
    local target_path="$2"

    mkdir -p "$(dirname "$target_path")"

    if [ -L "$target_path" ] && [ "$(readlink -f "$target_path")" = "$(readlink -f "$source_path")" ]; then
        return
    fi

    if [ -e "$target_path" ] || [ -L "$target_path" ]; then
        if [ ! -e "$target_path.before-dotfiles" ]; then
            mv "$target_path" "$target_path.before-dotfiles"
        else
            echo "Impossibile sostituire $target_path: il backup esiste già." >&2
            exit 1
        fi
    fi

    ln -s "$source_path" "$target_path"
}

configure_bash() {
    local activation_line='eval "$(~/.local/bin/mise activate bash)"'

    touch "$HOME/.bashrc"
    if ! grep -Fqx "$activation_line" "$HOME/.bashrc"; then
        printf '\n%s\n' "$activation_line" >> "$HOME/.bashrc"
    fi
}

install_mise
backup_and_link "$repository_dir/git/.globalignore" "$HOME/.gitignore"
backup_and_link "$repository_dir/mise/config.toml" "$HOME/.config/mise/config.toml"
backup_and_link "$repository_dir/opencode/tui.json" "${XDG_CONFIG_HOME:-$HOME/.config}/opencode/tui.json"
backup_and_link "$repository_dir/bin/git-mr" "$HOME/.local/bin/git-mr"
backup_and_link "$repository_dir/bin/git-pr" "$HOME/.local/bin/git-pr"
backup_and_link "$repository_dir/bin/git-release" "$HOME/.local/bin/git-release"
git config --global core.excludesFile '~/.gitignore'
configure_bash
mise install

echo "Installazione completata. Apri una nuova shell o esegui: source ~/.bashrc"
