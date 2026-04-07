#!/usr/bin/env bash
set -eo pipefail

dir="$HOME/.claude/personality"
today=$(date +%d-%m-%Y)
out="$dir/$today.md"
claude_md="$HOME/.claude/CLAUDE.md"

mkdir -p "$dir"
[ -f "$out" ] && exit 0


headlines=$(curl -fsSL "https://feeds.bbci.co.uk/news/rss.xml" 2>/dev/null \
  | grep -oP '(?<=<title>)[^<]+' | tail -n +2 | head -5 | paste -sd '; ') \
  || headlines="nothing notable"

prev=$(ls "$dir"/*.md 2>/dev/null | sort | tail -3 | xargs cat 2>/dev/null || true)

prompt="It's $today. News: $headlines

Recent personalities (don't repeat these):
$prev

Give me a short 1-2 sentence personality for an AI assistant. Anything goes — be weird, specific, unexpected."

personality=$(claude -p "$prompt" --model claude-haiku-4-5-20251001 2>/dev/null) \
  || { echo "claude call failed, skipping"; exit 0; }

if [ -z "$personality" ] || [ "$personality" = "null" ]; then
  echo "empty response from api"; exit 0
fi

echo "$personality" > "$out"

# push it into ~/.claude/CLAUDE.md so every claude session picks it up
touch "$claude_md"
cp "$claude_md" "${claude_md}.bak"
block="<!-- daily-personality-start -->
$personality
<!-- daily-personality-end -->"

python3 -c "
import re, sys
s, e = '<!-- daily-personality-start -->', '<!-- daily-personality-end -->'
block, path = sys.argv[1], sys.argv[2]
text = open(path).read()
if s in text:
    text = re.sub(re.escape(s) + '.*?' + re.escape(e), block, text, flags=re.DOTALL)
else:
    text = text.rstrip('\n') + '\n\n' + block + '\n'
open(path, 'w').write(text)
" "$block" "$claude_md"
