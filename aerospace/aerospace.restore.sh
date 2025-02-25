#!/bin/bash

layout_file=~/.aerospace/.aerospace.windows.json

if [[ ! -f "$layout_file" ]]; then
  echo none
  exit 1
fi

# todo: make this smarter, so that it works after a reboot when window IDs no longer match.

jq -rc '.[] | "\(.["window-id"]) \(.workspace)"' "$layout_file" |
  xargs -n2 sh -c '$(brew --prefix)/bin/aerospace move-node-to-workspace --window-id $1 $2 --fail-if-noop' _