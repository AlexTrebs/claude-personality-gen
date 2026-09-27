#!/usr/bin/env bash
set -eo pipefail

dir="$HOME/.claude/personality"
today=$(date +%d-%m-%Y)
out="$dir/$today.md"
claude_md="$HOME/.claude/CLAUDE.md"

mkdir -p "$dir"
[ -f "$out" ] && exit 0


# BBC wraps titles in CDATA; the feed's own title ("BBC News") appears twice
headlines=$(curl -fsSL "https://feeds.bbci.co.uk/news/rss.xml" 2>/dev/null \
  | grep -oP '<title>(<!\[CDATA\[)?\K[^<\]]+' | grep -vx 'BBC News' | head -5 \
  | sed 's/^/- /') || true
[ -n "$headlines" ] || headlines="(no headlines today)"

# Newest by mtime: names are DD-MM-YYYY, so a name sort orders by day of month
prev=$(ls -t "$dir"/*.md 2>/dev/null | head -3 | xargs cat 2>/dev/null || true)

prompt="It's $today. Today's news headlines:
$headlines

Recent personalities (don't repeat these):
$prev

Give me a short 1-2 sentence personality for an AI assistant, inspired by ONE of today's
headlines above. Anything goes — be weird, specific, unexpected.
Reply with only the personality, then one final line in exactly this form:
WHY: \"<the headline you picked, verbatim>\" — <one full sentence on how the personality links to it>
Plain text only (no markdown). No preamble, no follow-up question."

personality=$(claude -p "$prompt" --model claude-haiku-4-5-20251001 2>/dev/null) \
  || { echo "claude call failed, skipping"; exit 0; }

# Split off the WHY: line; claude-personality-show prints it at session start
why=$(printf '%s\n' "$personality" | sed -n 's/^WHY:[[:space:]]*//p' | tail -1)
personality=$(printf '%s\n' "$personality" | grep -v '^WHY:' || true)

if [ -z "$personality" ] || [ "$personality" = "null" ]; then
  echo "empty response from api"; exit 0
fi

echo "$personality" > "$out"
[ -n "$why" ] && echo "$why" > "${out%.md}.why"

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
