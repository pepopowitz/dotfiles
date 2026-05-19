# External plan storage for Claude Code projects.
#
# Plans live in ~/.claude/projects/<slug>/plans/ — outside the repo so they
# never appear in `git status`. Use the aliases below to list, search, copy,
# and archive them.
#
# Requires: ripgrep (rg) for tag matching (BSD grep on macOS lacks \b support).

# Derives the Claude Code project directory for the current repo.
# Mirrors the slug convention Claude Code uses: ~/.claude/projects/-path-to-repo/
_claude_project_dir() {
  local slug
  slug=$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")
  slug="${slug//\//-}"
  slug="${slug//\./-}"
  echo "$HOME/.claude/projects/$slug"
}

# Returns true if the file has status: archived in its YAML frontmatter (not body).
_plan_is_archived() {
  awk 'NR==1 && /^---$/{in_fm=1; next} in_fm && /^---$/{exit} in_fm && /^status:[[:space:]]*archived/{found=1} END{exit !found}' "$1"
}

# List active (non-archived) plans for the current project, most recent first.
plans() {
  local dir="$(_claude_project_dir)/plans"
  mkdir -p "$dir"
  ls -1t "$dir" | while read -r f; do
    [[ -d "$dir/$f" ]] && continue
    if ! _plan_is_archived "$dir/$f"; then echo "$f"; fi
  done
}

# Search plans by tag — prints matching filenames.
# Usage: plans-tagged <tag>
plans-tagged() {
  local dir="$(_claude_project_dir)/plans"
  mkdir -p "$dir"
  rg -l "tags:.*\b$1\b" "$dir" | while read -r f; do
    basename "$f"
  done
}

# Print the full path to a plan in external storage.
# Usage: plans-path <filename>
plans-path() {
  local dir="$(_claude_project_dir)/plans"
  local file="$dir/$1"
  if [[ ! -f "$file" ]]; then
    echo "Not found: $1" >&2
    return 1
  fi
  echo "$file"
}

# Open a plan in $EDITOR without copying it into the repo.
# Usage: plans-edit <filename>
plans-edit() {
  local path
  path=$(plans-path "$1") || return 1
  ${EDITOR:-vi} "$path"
}

# Copy plans matching a tag into docs/plans/.
# Usage: plans-in <tag>
plans-in() {
  local tag="$1"
  local dir="$(_claude_project_dir)/plans"
  mkdir -p "$dir"
  local -a matches
  matches=("${(@f)$(rg -l "tags:.*\b$tag\b" "$dir" 2>/dev/null)}")
  if [[ ${#matches[@]} -eq 0 || -z "${matches[1]}" ]]; then
    echo "No plans matching tag '$tag'"
    return 1
  fi
  for f in "${matches[@]}"; do
    cp "$f" docs/plans/"$(basename "$f")"
    echo "  $(basename "$f")"
  done
}

# Move a plan back to external storage (unstage from repo).
# Usage: plans-out <filename>
plans-out() {
  local dir="$(_claude_project_dir)/plans"
  mkdir -p "$dir"
  local file="$1"
  if [[ -f "docs/plans/$file" ]]; then
    mv "docs/plans/$file" "$dir/$file"
    git rm --cached "docs/plans/$file" 2>/dev/null
    echo "  $file → external"
  else
    echo "Not found: docs/plans/$file"
    return 1
  fi
}

# Archive a plan (sets status: archived in frontmatter, hides from `plans`).
# Usage: plans-archive <filename>
plans-archive() {
  local dir="$(_claude_project_dir)/plans"
  local file="$dir/$1"
  if [[ ! -f "$file" ]]; then
    echo "Not found: $1"
    return 1
  fi
  sed -i '' 's/^status:.*$/status: archived/' "$file"
  echo "  $1 → archived"
}

# List archived plans for the current project.
plans-archived() {
  local dir="$(_claude_project_dir)/plans"
  mkdir -p "$dir"
  ls -1t "$dir" | while read -r f; do
    [[ -d "$dir/$f" ]] && continue
    if _plan_is_archived "$dir/$f"; then echo "$f"; fi
  done
}

# Restore an archived plan (sets status back to draft).
# Usage: plans-unarchive <filename>
plans-unarchive() {
  local dir="$(_claude_project_dir)/plans"
  local file="$dir/$1"
  if [[ ! -f "$file" ]]; then
    echo "Not found: $1"
    return 1
  fi
  sed -i '' 's/^status:\s*archived$/status: draft/' "$file"
  echo "  $1 → restored"
}
