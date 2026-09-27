#!/usr/bin/env bash
# Claude Code SessionStart hook: show today's personality and why
# it was picked. Prints {"systemMessage": ...}; prints nothing if there is none yet.
dir="$HOME/.claude/personality"
today=$(date +%d-%m-%Y)
[ -s "$dir/$today.md" ] || exit 0

text=$(tr '\n' ' ' < "$dir/$today.md")
text="${text% }"

msg="🎭 Today: $text"
[ -s "$dir/$today.why" ] && msg+=$'\n   why: '"$(< "$dir/$today.why")"

jq -cn --arg m "$msg" '{systemMessage: $m}'
