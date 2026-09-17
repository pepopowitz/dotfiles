#!/usr/bin/env bash
# PreToolUse guard: Claude never edits its own permission config or hook
# scripts on its own initiative — every write asks Steve first, mid-session.
# An unrequested attempt shows up as a prompt he wasn't expecting; a change he
# asked for is one approval away. Reads are always allowed.
# CLAUDE_CONFIG_UNLOCK=1 (the `claude-config` alias) skips the prompting for a
# session that is entirely about editing config.
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
  jq -nc '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "allow",
      permissionDecisionReason: "CLAUDE_CONFIG_UNLOCK=1 — config edits pre-approved for this session."
    },
    systemMessage: "⚠︎ config unlocked — Claude is editing its own permission settings"
  }'
  exit 0
fi

jq -nc '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "ask",
    permissionDecisionReason: "This writes to Claude Code'"'"'s own permission config or hook scripts. Approve only if you asked for this change — Claude is not supposed to adjust its own guardrails on its own initiative."
  }
}'
exit 0
