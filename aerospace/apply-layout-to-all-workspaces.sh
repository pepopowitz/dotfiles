#!/bin/bash

# Default to 'tiles' if no argument is provided
LAYOUT_TYPE=${1:-tiles}

# Flatten all workspaces first
aerospace list-workspaces --all | xargs -I {} aerospace flatten-workspace-tree --workspace {}

# Get one window per workspace and apply the specified layout
aerospace list-windows --all --format '%{workspace} | %{window-id}' | 
  sort -t'|' -k1 | 
  awk -F' \\| ' '!seen[$1]++ {print $2}' | 
  xargs -I {} aerospace layout "$LAYOUT_TYPE" horizontal --window-id {}