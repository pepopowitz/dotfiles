#!/usr/bin/env bash
# Appends one JSONL record per action to ~/.claude/action-log/<session>.jsonl.
# Wired to PreToolUse/Bash and PostToolUse/Write|Edit. Read by session-digest.sh.
set -uo pipefail

dir="$HOME/.claude/action-log"
mkdir -p "$dir"

input=$(cat)
sid=$(printf '%s' "$input" | jq -r '.session_id // "unknown"')

printf '%s' "$input" | jq -c --arg ts "$(date +%Y-%m-%dT%H:%M:%S)" --arg cwd "$PWD" '{
  ts: $ts,
  cwd: $cwd,
  tool: .tool_name,
  cmd: (.tool_input.command // null),
  file: (.tool_response.filePath // .tool_input.file_path // null)
}' >> "$dir/$sid.jsonl" 2>/dev/null

exit 0
