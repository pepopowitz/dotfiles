#!/bin/bash

layout_file=~/.aerospace/.aerospace.windows.json

if [[ ! -f "$layout_file" ]]; then
  echo none
  exit 1
fi

# grab all open windows.
current_windows=$($(brew --prefix)/bin/aerospace list-windows --all --format "%{window-id}%{app-bundle-id}%{window-title}" --json)

# todo: matching windows for things like code should exclude the open file name.

jq -rc '.[] | "\(.["window-id"]) \(.workspace)"' "$layout_file" |
  xargs -n2 sh -c '$(brew --prefix)/bin/aerospace move-node-to-workspace --window-id $1 $2 --fail-if-noop' _