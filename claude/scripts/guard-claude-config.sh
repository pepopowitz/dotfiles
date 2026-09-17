#!/usr/bin/env bash
# PreToolUse guard: Claude's own permission config is read-only, so a session
# can't loosen its own leash. Unlock for one session with:
#   CLAUDE_CONFIG_UNLOCK=1 claude   (or the `claude-config` alias)
# Reads are always allowed — only writes are gated.
set -uo pipefail

input=$(cat)

protected='(\.dotfiles/claude/(settings\.json|scripts/)|\.claude/(settings(\.local)?\.json|scripts/))'
writes='(>>?[[:space:]]|[[:space:]]-i\b|\btee\b|\b(cp|mv|rm|ln|chmod|truncate|install|touch|dd)\b)'

file=$(printf '%s' "$input" | jq -r '[.tool_input.file_path, .tool_input.notebook_path] | map(select(. != null)) | join(" ")')
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""')

hit=false
if printf '%s' "$file" | grep -qE "$protected"; then
  hit=true
elif printf '%s' "$cmd" | grep -qE "$protected" && printf '%s' "$cmd" | grep -qE "$writes"; then
  hit=true
fi

[ "$hit" = true ] || exit 0

if [ "${CLAUDE_CONFIG_UNLOCK:-}" = "1" ]; then
  jq -nc '{systemMessage: "⚠︎ config unlocked — Claude may edit its own permission settings this session"}'
  exit 0
fi

jq -nc '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: "Claude Code'"'"'s own permission config (settings.json, hook scripts) is read-only in this session, so a session cannot loosen its own guardrails. Reading it is fine. To edit it, Steve restarts with `CLAUDE_CONFIG_UNLOCK=1 claude` — tell him that rather than looking for another way in."
  }
}'
exit 0
