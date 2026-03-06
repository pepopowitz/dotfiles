#!/bin/bash
# Claude Code notification script
# Usage: notify.sh "phrase1" "phrase2" "phrase3" ...
# Reads hook JSON from stdin, extracts session_id, maps to a persistent name.

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')

VOICES=( Daniel Fred Junior Kathy Karen Samantha Tessa Flo Reed "Good News" Grandpa Rocko Superstar)

if [ -n "$SESSION_ID" ]; then
  HASH=$(echo -n "$SESSION_ID" | md5 -q | cut -c1-4)
  INDEX=$(( 16#$HASH % ${#VOICES[@]} ))
else
  INDEX=0
fi
VOICE="${VOICES[$INDEX]}"

# Pick a random phrase from arguments
PHRASES=("$@")
PHRASE="${PHRASES[$((RANDOM % ${#PHRASES[@]}))]}"

open raycast://confetti
say "$PHRASE" -v "$VOICE"
