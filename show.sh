#!/usr/bin/env bash
# Claude Code SessionStart hook: show a snippet of today's personality and why
# it was picked. Prints {"systemMessage": ...}; prints nothing if there is none yet.
export LC_ALL=C.UTF-8  # so ${#text} counts characters, not bytes

dir="$HOME/.claude/personality"
today=$(date +%d-%m-%Y)
[ -s "$dir/$today.md" ] || exit 0

text=$(tr '\n' ' ' < "$dir/$today.md")
text="${text% }"
(( ${#text} > 140 )) && text="${text:0:140}…"

msg="🎭 Today: $text"
[ -s "$dir/$today.why" ] && msg+=$'\n   why: '"$(< "$dir/$today.why")"

jq -cn --arg m "$msg" '{systemMessage: $m}'
