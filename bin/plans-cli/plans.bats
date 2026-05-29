#!/usr/bin/env bats

PLANS_CLI="$BATS_TEST_DIRNAME/plans"

setup() {
  export PLANS_PROJECT_DIR="$(mktemp -d)"
  mkdir -p "$PLANS_PROJECT_DIR/plans" "$PLANS_PROJECT_DIR/brainstorms"

  RECENT_DATE=$(date +%Y-%m-%d)
  RECENT_PLAN="p-${RECENT_DATE}-recent-plan.md"

  # Create test plans with different dates
  cat > "$PLANS_PROJECT_DIR/plans/p-2026-01-01-old-plan.md" <<'EOF'
---
title: 'Old plan'
status: draft
tags: infra, chat
---
Body
EOF

  cat > "$PLANS_PROJECT_DIR/plans/$RECENT_PLAN" <<EOF
---
title: 'Recent plan'
status: draft
tags: infra
---
Body
EOF

  cat > "$PLANS_PROJECT_DIR/brainstorms/b-2026-01-01-old-brainstorm.md" <<'EOF'
---
title: 'Old brainstorm'
status: draft
tags: chat
---
Body
EOF

  # Set up a temp git repo and docs dirs for in/out tests
  export TEST_REPO="$(mktemp -d)"
  mkdir -p "$TEST_REPO/docs/plans" "$TEST_REPO/docs/brainstorms"
  git -C "$TEST_REPO" init -q

  cd "$TEST_REPO"
}

teardown() {
  rm -rf "$PLANS_PROJECT_DIR" "$TEST_REPO"
}

# --- list ---

@test "list shows active plans and brainstorms" {
  run "$PLANS_CLI" list
  [ "$status" -eq 0 ]
  [[ "$output" == *"$RECENT_PLAN"* ]]
  [[ "$output" == *"p-2026-01-01-old-plan.md"* ]]
  [[ "$output" == *"b-2026-01-01-old-brainstorm.md"* ]]
}

@test "list does not show archived plans" {
  sed -i '' 's/status: draft/status: archived/' "$PLANS_PROJECT_DIR/plans/p-2026-01-01-old-plan.md"
  run "$PLANS_CLI" list
  [ "$status" -eq 0 ]
  [[ "$output" != *"p-2026-01-01-old-plan.md"* ]]
  [[ "$output" == *"$RECENT_PLAN"* ]]
}

@test "list --plans only shows plans" {
  run "$PLANS_CLI" list --plans
  [ "$status" -eq 0 ]
  [[ "$output" == *"p-2026-01-01-old-plan.md"* ]]
  [[ "$output" != *"b-2026-01-01-old-brainstorm.md"* ]]
}

@test "list --brainstorms only shows brainstorms" {
  run "$PLANS_CLI" list --brainstorms
  [ "$status" -eq 0 ]
  [[ "$output" == *"b-2026-01-01-old-brainstorm.md"* ]]
  [[ "$output" != *"p-2026-01-01-old-plan.md"* ]]
}

# --- in ---

@test "in by filename copies a plan into docs/plans" {
  run "$PLANS_CLI" in p-2026-01-01-old-plan.md
  [ "$status" -eq 0 ]
  [ -f "docs/plans/p-2026-01-01-old-plan.md" ]
}

@test "in by filename copies a brainstorm into docs/brainstorms" {
  run "$PLANS_CLI" in b-2026-01-01-old-brainstorm.md
  [ "$status" -eq 0 ]
  [ -f "docs/brainstorms/b-2026-01-01-old-brainstorm.md" ]
}

@test "in by tag copies all matching files" {
  run "$PLANS_CLI" in chat
  [ "$status" -eq 0 ]
  [ -f "docs/plans/p-2026-01-01-old-plan.md" ]
  [ -f "docs/brainstorms/b-2026-01-01-old-brainstorm.md" ]
}

@test "in by tag with no matches fails" {
  run "$PLANS_CLI" in nonexistent-tag
  [ "$status" -ne 0 ]
  [[ "$output" == *"No docs matching"* ]]
}

# --- out ---

@test "out by filename moves a plan back to external" {
  cp "$PLANS_PROJECT_DIR/plans/p-2026-01-01-old-plan.md" docs/plans/
  run "$PLANS_CLI" out p-2026-01-01-old-plan.md
  [ "$status" -eq 0 ]
  [ ! -f "docs/plans/p-2026-01-01-old-plan.md" ]
  [ -f "$PLANS_PROJECT_DIR/plans/p-2026-01-01-old-plan.md" ]
}

@test "out by filename moves a brainstorm back to external" {
  cp "$PLANS_PROJECT_DIR/brainstorms/b-2026-01-01-old-brainstorm.md" docs/brainstorms/
  run "$PLANS_CLI" out b-2026-01-01-old-brainstorm.md
  [ "$status" -eq 0 ]
  [ ! -f "docs/brainstorms/b-2026-01-01-old-brainstorm.md" ]
  [ -f "$PLANS_PROJECT_DIR/brainstorms/b-2026-01-01-old-brainstorm.md" ]
}

@test "out by tag moves all matching files" {
  cp "$PLANS_PROJECT_DIR/plans/p-2026-01-01-old-plan.md" docs/plans/
  cp "$PLANS_PROJECT_DIR/brainstorms/b-2026-01-01-old-brainstorm.md" docs/brainstorms/
  run "$PLANS_CLI" out chat
  [ "$status" -eq 0 ]
  [ ! -f "docs/plans/p-2026-01-01-old-plan.md" ]
  [ ! -f "docs/brainstorms/b-2026-01-01-old-brainstorm.md" ]
}

@test "out with nonexistent file fails" {
  run "$PLANS_CLI" out nonexistent.md
  [ "$status" -ne 0 ]
  [[ "$output" == *"No docs matching"* ]]
}

# --- archive ---

@test "archive by filename sets status to archived" {
  run "$PLANS_CLI" archive p-2026-01-01-old-plan.md
  [ "$status" -eq 0 ]
  grep -q 'status: archived' "$PLANS_PROJECT_DIR/plans/p-2026-01-01-old-plan.md"
}

@test "archive --older-than archives old plans" {
  run "$PLANS_CLI" archive --older-than 30
  [ "$status" -eq 0 ]
  grep -q 'status: archived' "$PLANS_PROJECT_DIR/plans/p-2026-01-01-old-plan.md"
  grep -q 'status: archived' "$PLANS_PROJECT_DIR/brainstorms/b-2026-01-01-old-brainstorm.md"
}

@test "archive --older-than does not archive recent plans" {
  run "$PLANS_CLI" archive --older-than 30
  grep -q 'status: draft' "$PLANS_PROJECT_DIR/plans/$RECENT_PLAN"
}

@test "archive --older-than skips keep-tagged plans" {
  "$PLANS_CLI" keep p-2026-01-01-old-plan.md
  run "$PLANS_CLI" archive --older-than 1
  [ "$status" -eq 0 ]
  grep -q 'status: draft' "$PLANS_PROJECT_DIR/plans/p-2026-01-01-old-plan.md"
}

# --- delete ---

@test "delete refuses non-archived plan" {
  run "$PLANS_CLI" delete p-2026-01-01-old-plan.md
  [ "$status" -ne 0 ]
  [[ "$output" == *"not archived"* ]]
  [ -f "$PLANS_PROJECT_DIR/plans/p-2026-01-01-old-plan.md" ]
}

@test "delete removes archived plan" {
  "$PLANS_CLI" archive p-2026-01-01-old-plan.md
  run "$PLANS_CLI" delete p-2026-01-01-old-plan.md
  [ "$status" -eq 0 ]
  [ ! -f "$PLANS_PROJECT_DIR/plans/p-2026-01-01-old-plan.md" ]
}

@test "delete --older-than only deletes archived plans" {
  "$PLANS_CLI" archive p-2026-01-01-old-plan.md
  run "$PLANS_CLI" delete --older-than 30
  [ "$status" -eq 0 ]
  # Archived old plan deleted
  [ ! -f "$PLANS_PROJECT_DIR/plans/p-2026-01-01-old-plan.md" ]
  # Non-archived old brainstorm still exists
  [ -f "$PLANS_PROJECT_DIR/brainstorms/b-2026-01-01-old-brainstorm.md" ]
}

@test "delete --older-than skips keep-tagged plans" {
  "$PLANS_CLI" archive p-2026-01-01-old-plan.md
  "$PLANS_CLI" keep p-2026-01-01-old-plan.md
  run "$PLANS_CLI" delete --older-than 1
  [ "$status" -eq 0 ]
  [ -f "$PLANS_PROJECT_DIR/plans/p-2026-01-01-old-plan.md" ]
}

# --- keep/unkeep ---

@test "keep adds keep tag" {
  run "$PLANS_CLI" keep p-2026-01-01-old-plan.md
  [ "$status" -eq 0 ]
  grep -q 'tags: infra, chat, keep' "$PLANS_PROJECT_DIR/plans/p-2026-01-01-old-plan.md"
}

@test "keep is idempotent" {
  "$PLANS_CLI" keep p-2026-01-01-old-plan.md
  run "$PLANS_CLI" keep p-2026-01-01-old-plan.md
  [ "$status" -eq 0 ]
  [[ "$output" == *"already has keep"* ]]
}

@test "unkeep removes keep tag" {
  "$PLANS_CLI" keep p-2026-01-01-old-plan.md
  run "$PLANS_CLI" unkeep p-2026-01-01-old-plan.md
  [ "$status" -eq 0 ]
  grep -q 'tags: infra, chat$' "$PLANS_PROJECT_DIR/plans/p-2026-01-01-old-plan.md"
}

@test "unkeep on plan without keep is idempotent" {
  run "$PLANS_CLI" unkeep p-2026-01-01-old-plan.md
  [ "$status" -eq 0 ]
  [[ "$output" == *"does not have keep"* ]]
}
