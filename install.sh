#!/usr/bin/env bash
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. symlink script
mkdir -p ~/.local/bin
ln -sf "$SCRIPT_DIR/claude_personality_gen.sh" ~/.local/bin/claude-personality-gen
chmod +x "$SCRIPT_DIR/claude_personality_gen.sh"

# 2. systemd or cron
if systemctl --user status &>/dev/null; then
    mkdir -p ~/.config/systemd/user
    cp "$SCRIPT_DIR/claude-personality.service" ~/.config/systemd/user/
    cp "$SCRIPT_DIR/claude-personality.timer" ~/.config/systemd/user/
    systemctl --user daemon-reload
    systemctl --user enable --now claude-personality.timer
else
    (crontab -l 2>/dev/null; echo "0 8 * * * $HOME/.local/bin/claude-personality-gen") | crontab -
fi

# 3. optional hyprland
if [ -f ~/.config/hypr/hyprland.conf ]; then
    read -rp "Add exec-once to hyprland.conf? [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]] && echo "exec-once = $HOME/.local/bin/claude-personality-gen" >> ~/.config/hypr/hyprland.conf
fi

