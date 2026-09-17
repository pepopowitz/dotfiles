#!/bin/bash
# Re-emit the idle cmux tab title so a dropped OSC write from Claude Code
# doesn't leave the tab stuck on a spinner glyph.

[ -n "$CMUX_WORKSPACE_ID" ] || exit 0
[ -w /dev/tty ] || exit 0
command -v cmux >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0

title=$(CMUX_QUIET=1 cmux workspace list --json 2>/dev/null |
  jq -r --arg id "$CMUX_WORKSPACE_ID" '.workspaces[] | select(.id == $id) | .title' 2>/dev/null)

name=$(printf '%s' "$title" | sed -E 's/^[^[:alnum:]] //')
[ -n "$name" ] || exit 0

( printf '\033]2;✳ %s\007' "$name" > /dev/tty ) 2>/dev/null
exit 0
