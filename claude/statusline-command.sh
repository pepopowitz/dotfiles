#!/bin/bash
# Status line: starship-default look (path, git branch, git status) + Claude model name.

input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name')
ctx_left=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

RESET='\033[0m'
BOLD_CYAN='\033[1;36m'
BOLD_PURPLE='\033[1;35m'
BOLD_RED='\033[1;31m'
BOLD_YELLOW='\033[1;33m'
DIM='\033[2m'

dir="$cwd"
case "$dir" in
  "$HOME"/*) dir="~/${dir#$HOME/}" ;;
  "$HOME") dir="~" ;;
esac

IFS='/' read -ra parts <<< "$dir"
count=${#parts[@]}
if [ "$count" -gt 3 ]; then
  dir=$(printf '.../%s/%s/%s' "${parts[$((count - 3))]}" "${parts[$((count - 2))]}" "${parts[$((count - 1))]}")
fi

path_segment=$(printf "${BOLD_CYAN}%s${RESET}" "$dir")

git_segment=""
if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
  [ -z "$branch" ] && branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)

  if [ -n "$branch" ]; then
    git_segment=$(printf " ${BOLD_PURPLE} %s${RESET}" "$branch")

    flags=""
    porcelain=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)
    [ -n "$porcelain" ] && flags="${flags}*"

    ab=$(git -C "$cwd" --no-optional-locks rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null)
    if [ -n "$ab" ]; then
      behind=$(echo "$ab" | awk '{print $1}')
      ahead=$(echo "$ab" | awk '{print $2}')
      [ "${ahead:-0}" -gt 0 ] 2>/dev/null && flags="${flags}⇡"
      [ "${behind:-0}" -gt 0 ] 2>/dev/null && flags="${flags}⇣"
    fi

    [ -n "$flags" ] && git_segment="${git_segment}$(printf " ${BOLD_RED}%s${RESET}" "$flags")"
  fi
fi

model_segment=$(printf "${DIM} %s${RESET}" "$model")

# Context left is only worth screen space once it's running out.
ctx_segment=""
if [ -n "$ctx_left" ]; then
  # Compare the raw float, floor only for display, so 39.6 still counts as below 40.
  ctx_shown=$(awk -v v="$ctx_left" 'BEGIN { if (v+0 < 40) print int(v) }')
  if [ -n "$ctx_shown" ]; then
    ctx_color="$BOLD_YELLOW"
    [ "$ctx_shown" -lt 15 ] 2>/dev/null && ctx_color="$BOLD_RED"
    ctx_segment=$(printf " ${ctx_color}%s%% ctx${RESET}" "$ctx_shown")
  fi
fi

printf "%s%s%s%s\n" "$path_segment" "$git_segment" "$ctx_segment" "$model_segment"
