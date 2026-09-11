#!/bin/bash
# Stop hook: log replies that contain banned vocabulary or em dashes. Log-only, never blocks.
log="$HOME/.cache/claude/lint-reply.log"
mkdir -p "$(dirname "$log")"
input=$(cat)

sid=$(printf '%s' "$input" | jq -r '.session_id // "unknown"')

transcript=$(printf '%s' "$input" | jq -r '.transcript_path // empty')
if [ ! -f "$transcript" ]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') sid=$sid, no transcript: '$transcript'" >> "$log"
  exit 0
fi

# ACP clients flush the reply to the transcript after Stop fires — poll for a fresh entry
cutoff=$(date -u -v-15S '+%Y-%m-%dT%H:%M:%S')
ts=""
for _ in $(seq 1 15); do
  ts=$(jq -rs '[.[] | select(.type=="assistant") | select(any(.message.content[]?; .type=="text")) | .timestamp] | last // empty' "$transcript" 2>/dev/null)
  if [ -n "$ts" ] && [[ "$ts" > "$cutoff" ]]; then
    break
  fi
  ts=""
  sleep 0.2
done
if [ -z "$ts" ]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') sid=$sid, no fresh reply after 3s, lint skipped" >> "$log"
  exit 0
fi

last=$(jq -rs --arg ts "$ts" '[.[] | select(.type=="assistant" and .timestamp==$ts) | .message.content[]? | select(.type=="text") | .text] | join("\n")' "$transcript" 2>/dev/null)

# strip fenced code blocks and inline code — bans apply to prose only
prose=$(printf '%s\n' "$last" | awk '/^[[:space:]]*```/{fence=!fence; next} !fence' | sed 's/`[^`]*`//g')

words='crucial|pivotal|robust|seamless|leverage|utilize|delve|showcase|landscape|tapestry|testament|foster|enhance|comprehensive|additionally|moreover|furthermore|rung|load-bearing'
violations=$(printf '%s\n' "$prose" | grep -oiE -e '—' -e "\\b($words)\\b" | sort -u | tr '\n' ' ')

echo "$(date '+%Y-%m-%d %H:%M:%S') sid=$sid, linted ts=$ts, violations: '${violations:-none}'" >> "$log"
# log-only: record violations, never block, so no duplicate rewrite messages
exit 0
