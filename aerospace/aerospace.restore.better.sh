#!/bin/bash

# AeroSpace's exec-and-forget runs a login bash shell, which never reads
# ~/.zprofile, so mise's shims (and therefore node) are not on PATH.
eval "$(/opt/homebrew/bin/mise activate bash --shims)"

exec node "$(dirname "$0")/aerospace.restore.better.js" "$@"
