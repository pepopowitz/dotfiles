# External plan/brainstorm storage for Claude Code projects.
#
# Plans live in ~/.claude/projects/<slug>/plans/ and brainstorms in .../brainstorms/
# — outside the repo so they never appear in `git status`. All commands operate
# across both directories unless noted.
#
# Requires: ripgrep (rg) for tag matching (BSD grep on macOS lacks \b support).

# Derives the Claude Code project directory for the current repo.
# Mirrors the slug convention Claude Code uses: ~/.claude/projects/-path-to-repo/
_claude_project_dir() {
  local slug
  slug=$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")
  slug="${slug//\//-}"
  slug="${slug//./-}"
  echo "$HOME/.claude/projects/$slug"
}

# Returns true if the file has status: archived in its YAML frontmatter (not body).
_plan_is_archived() {
  awk 'NR==1 && /^---$/{in_fm=1; next} in_fm && /^---$/{exit} in_fm && /^status:[[:space:]]*archived/{found=1} END{exit !found}' "$1"
}

# Finds a file by name across plans/ and brainstorms/ external dirs.
# Outputs the full path on stdout; errors to stderr.
_plan_find_file() {
  local base="$(_claude_project_dir)"
  local subdir file
  for subdir in plans brainstorms; do
    file="$base/$subdir/$1"
    [[ -f "$file" ]] && echo "$file" && return 0
  done
  echo "Not found: $1" >&2
  return 1
}

# List active (non-archived) plans and brainstorms, most recent first.
plans() {
  local base="$(_claude_project_dir)"
  mkdir -p "$base/plans" "$base/brainstorms"
  local f
  for f in "$base"/{plans,brainstorms}/*(NOm); do
    [[ -f "$f" ]] || continue
    if ! _plan_is_archived "$f"; then echo "$(basename "$f")"; fi
  done
}

# Search plans and brainstorms by tag — prints matching filenames.
# Usage: plans-tagged <tag>
plans-tagged() {
  local base="$(_claude_project_dir)"
  mkdir -p "$base/plans" "$base/brainstorms"
  rg -l "tags:.*\b$1\b" "$base/plans" "$base/brainstorms" | while read -r f; do
    basename "$f"
  done
}

# Print the full path to a plan or brainstorm in external storage.
# Usage: plans-path <filename>
plans-path() {
  _plan_find_file "$1"
}

# Open a plan or brainstorm in VS Code without copying it into the repo.
# Usage: plans-edit <filename>
plans-edit() {
  local path
  path=$(_plan_find_file "$1") || return 1
  /usr/bin/open -a "Visual Studio Code" "$path"
}

# Copy plans/brainstorms matching a tag into docs/plans/ or docs/brainstorms/.
# Usage: plans-in <tag>
plans-in() {
  local tag="$1"
  local base="$(_claude_project_dir)"
  mkdir -p "$base/plans" "$base/brainstorms"
  local -a matches
  matches=("${(@f)$(rg -l "tags:.*\b$tag\b" "$base/plans" "$base/brainstorms" 2>/dev/null)}")
  if [[ ${#matches[@]} -eq 0 || -z "${matches[1]}" ]]; then
    echo "No docs matching tag '$tag'"
    return 1
  fi
  for f in "${matches[@]}"; do
    local dest
    if [[ "$f" == "$base/brainstorms/"* ]]; then
      dest=docs/brainstorms
    else
      dest=docs/plans
    fi
    mkdir -p "$dest"
    cp "$f" "$dest/$(basename "$f")"
    echo "  $(basename "$f") → $dest"
  done
}

# Move a file from docs/plans/ or docs/brainstorms/ back to external storage.
# Usage: plans-out <filename>
plans-out() {
  local base="$(_claude_project_dir)"
  local file="$1"
  local src subdir
  if [[ -f "docs/brainstorms/$file" ]]; then
    src="docs/brainstorms/$file"
    subdir=brainstorms
  elif [[ -f "docs/plans/$file" ]]; then
    src="docs/plans/$file"
    subdir=plans
  else
    echo "Not found in docs/plans/ or docs/brainstorms/: $file" >&2
    return 1
  fi
  mkdir -p "$base/$subdir"
  mv "$src" "$base/$subdir/$file"
  git rm --cached "$src" 2>/dev/null
  echo "  $file → external ($subdir)"
}

# Archive a plan or brainstorm (sets status: archived, hides from `plans`).
# Usage: plans-archive <filename>
plans-archive() {
  local file
  file=$(_plan_find_file "$1") || return 1
  sed -i '' 's/^status:.*$/status: archived/' "$file"
  echo "  $1 → archived"
}

# List archived plans and brainstorms for the current project.
plans-archived() {
  local base="$(_claude_project_dir)"
  mkdir -p "$base/plans" "$base/brainstorms"
  local f
  for f in "$base"/{plans,brainstorms}/*(NOm); do
    [[ -f "$f" ]] || continue
    if _plan_is_archived "$f"; then echo "$(basename "$f")"; fi
  done
}

# Restore an archived plan or brainstorm (sets status back to draft).
# Usage: plans-unarchive <filename>
plans-unarchive() {
  local file
  file=$(_plan_find_file "$1") || return 1
  sed -i '' 's/^status:[[:space:]]*archived$/status: draft/' "$file"
  echo "  $1 → restored"
}
