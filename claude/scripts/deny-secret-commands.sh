#!/usr/bin/env bash
# PreToolUse/Bash guard: block shell commands that touch secret-bearing files.
# Permission deny rules only cover Read/Edit, so `cat .env` would otherwise pass.
set -uo pipefail

cmd=$(jq -r '.tool_input.command // ""')

# Example/sample env files are not secrets.
scrubbed=$(printf '%s' "$cmd" | sed -E 's/\.env\.(example|sample|template|dist|local\.example)//g')

secrets='(^|[^[:alnum:]_.~/-])\.env([^[:alnum:]_-]|$)|(^|[^[:alnum:]_-])\.env\.[[:alnum:]_-]|\.ssh/|\.aws/(credentials|config)|\.gnupg/|\.config/gh/|(^|/)\.npmrc|id_(rsa|ed25519|dsa|ecdsa)|\.(pem|p12|pfx|key)([^[:alnum:]]|$)|Library/Keychains|security +find-(generic|internet)-password'

if printf '%s' "$scrubbed" | grep -qiE "$secrets"; then
  jq -nc '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Blocked by global settings: this command references a credential file (.env, ssh/aws/gpg/gh config, or a private key). Ask Steve to read it out if you need a value."
    }
  }'
fi

exit 0
