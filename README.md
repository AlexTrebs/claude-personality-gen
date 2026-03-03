# claude-personality-gen

Generates a fresh daily personality for your Claude AI assistant, injected automatically into `~/.claude/CLAUDE.md` so every Claude session picks it up.

Each day it pulls recent BBC news headlines, avoids repeating recent personalities, and asks Claude to come up with something short, weird, and specific.

## Prerequisites

- [`claude` CLI](https://github.com/anthropics/claude-code) — installed and authenticated
- `bash`, `curl`, `python3` — standard on most Linux systems

## Install

```bash
git clone https://github.com/alextrebs/claude-personality-gen
cd claude-personality-gen
chmod +x install.sh
./install.sh
```

The installer will:
- Symlink the script to `~/.local/bin/claude-personality-gen`
- Set up a systemd user timer (or cron fallback) to run it daily
- Optionally add an `exec-once` line to your Hyprland config

## How it works

1. Fetches today's BBC headlines via RSS
2. Reads the last 3 generated personalities to avoid repeats
3. Calls `claude -p` to generate a 1-2 sentence personality
4. Saves it to `~/.claude/personality/<date>.md`
5. Injects it into `~/.claude/CLAUDE.md` between comment markers:

```
<!-- daily-personality-start -->
...personality here...
<!-- daily-personality-end -->
```

The script is idempotent — running it multiple times in a day is safe.

## Files

```
claude_personality_gen.sh   # main script
install.sh                  # installer
claude-personality.service  # systemd user service unit
claude-personality.timer    # systemd user timer unit
```
