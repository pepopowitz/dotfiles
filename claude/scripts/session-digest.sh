#!/usr/bin/env bash
# Stop hook: prints a one-glance digest of what Claude did since the last digest.
# Reads the JSONL written by log-action.sh; tracks an offset so each turn only
# reports its own actions.
set -uo pipefail

dir="$HOME/.claude/action-log"
input=$(cat)
sid=$(printf '%s' "$input" | jq -r '.session_id // "unknown"')
log="$dir/$sid.jsonl"

[ -s "$log" ] || exit 0

offset_file="$dir/$sid.offset"
offset=$(cat "$offset_file" 2>/dev/null || echo 0)
total=$(wc -l < "$log" | tr -d ' ')
[ "$total" -gt "$offset" ] || exit 0
printf '%s' "$total" > "$offset_file"

summary=$(tail -n "+$((offset + 1))" "$log" | jq -rs '
  def verb:
    ((.cmd // "") | sub("^[[:space:]]+"; "") | split(" ") | map(select(length > 0))) as $w
    | if ($w | length) == 0 then "?"
      elif ($w[0] | test("^(git|gh|yarn|npm|npx|pnpm|st|brew|docker|make)$")) then ($w[0] + " " + ($w[1] // ""))
      else $w[0] end;

  (map(select(.cmd != null))) as $cmds
  | (map(select(.file != null) | .file | sub("^.*/"; "")) | unique) as $files
  | ($cmds | map(verb) | group_by(.) | map({k: .[0], n: length}) | sort_by(-.n, .k)) as $verbs
  | ([ "▸ \($cmds | length) cmds · \($files | length) files" ]
     + (if ($files | length) > 0 then ["  files  " + ($files | join(", "))] else [] end)
     + (if ($verbs | length) > 0 then ["  cmds   " + ($verbs | map("\(.k)×\(.n)") | join("  "))] else [] end))
  | join("\n")
')

[ -n "$summary" ] || exit 0

jq -nc --arg m "$summary" '{systemMessage: $m, suppressOutput: true}'
exit 0
