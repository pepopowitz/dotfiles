#!/bin/bash

layout_file=~/.aerospace/.aerospace.windows.json

if [[ ! -f "$layout_file" ]]; then
  echo none
  exit 1
fi

# grab all open windows.
current_windows=$($(brew --prefix)/bin/aerospace list-windows --all --format "%{window-id}%{app-bundle-id}%{window-title}" --json)

# todo: matching windows for things like code should exclude the open file name.

jq -r --argjson current "$current_windows" '
  .[] as $saved_window | 
  ($current[] | select(
    .["window-id"] == $saved_window["window-id"] or
    (.["app-bundle-id"] == $saved_window["app-bundle-id"] and .["window-title"] == $saved_window["window-title"])
  )["window-id"]) as $matched_id |
  if $matched_id then
    [$matched_id, $saved_window.workspace] | @tsv
  else 
    empty 
  end
' "$layout_file" |
while IFS=$'\t' read -r window_id workspace; do
  $(brew --prefix)/bin/aerospace move-node-to-workspace --window-id $window_id \"$workspace\" --fail-if-noop
done