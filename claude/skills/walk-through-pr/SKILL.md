---
name: walk-through-pr
description: Walks through a pull request with the user one file (or logical group of files) at a time, summarizing changes and helping them understand how each piece fits into the bigger picture. Use when the user asks to walk through or review a PR together.
license: CC-BY-4.0
---

# Walk Through PR

## Purpose

Help the user understand a pull request by walking through it collaboratively — one file or logical group of files at a time. The goal is comprehension, not just approval. Surface issues, explain context, and answer questions along the way.

**Focus on three key questions:**

1. Should this exist at all? Does it fit our architecture? Compare to existing patterns and boundaries in the codebase.
2. What happens when this breaks? Is the feature gated by a feature flag? Can we roll this back cleanly?
3. Does it introduce a new pattern? If so, should we encode it in CLAUDE.md or the steering docs so the AI gets it right next time?

## Setup

1. Use the `github-pr-review` MCP tool `get_pr_info` to fetch the PR node ID, title, and branch name for the current branch.
2. Use the `github-pr-review` MCP tool `get_pr_files` (inputs: `owner`, `repo`, `pr_number`) to fetch all changed files with their viewed state.
3. Get the full diff: `git diff <baseRefName>...HEAD`

## Orientation

Before diving in, give the user:

- A one-sentence summary of what the PR does
- A table grouping files by category (e.g. "New workflows", "Lambda config", "Call-site fixes")
- A proposed ordering with a brief rationale — then ask if they want to proceed or choose a different order

## Ordering strategy

Choose the order that makes the most logical sense for comprehension, not the order files appear in the diff. Good heuristics:

- **Bottom-up**: foundational/core changes first, orchestration/glue last
- **Dependency order**: files that other files depend on come first
- **Group similar mechanical changes**: if 5 files have the same 2-line change, cover them together

## Per-file walkthrough

For each file or group:

1. Read the diff: `git diff <base>...HEAD -- <file>`
2. Read the current file if line numbers are needed for context: use the Read tool
3. Summarize: what changed, why it matters, how it fits the bigger picture
4. **Always answer the three key questions** about architecture, breakage, and patterns
5. **Always include line numbers** when referencing specific code (e.g. "line 113", "lines 101–118")
6. Flag any issues you notice — don't wait to be asked
7. Pause for questions before moving on

## Marking files as viewed

- **Mark files as viewed in GitHub only when the user says to move on** — not before
- **Always mark files as viewed in GitHub when moving on**
- Use the `github-pr-review` MCP tool `mark_files_as_viewed` (inputs: `pr_node_id`, `paths` as a string array)
- Batch multiple files in a single call when moving on from a group

## Adding PR comments

When the user wants to add a review comment to the PR, use the `github-pr-review` MCP tools. **Never post a comment that isn't attached to a review. Never delete an active review.**

### Workflow

1. Call `get_pending_review` (inputs: `owner`, `repo`, `pr_number`) to check if a pending review already exists.
2. If **no pending review**: call `create_review` (inputs: `owner`, `repo`, `pr_number`) to start one. Note the `node_id` (format `PRR_...`) from the response.
3. If **pending review exists**: use its `node_id` (format `PRR_...`).
4. Call `add_review_comment` (inputs: `pull_request_review_id` as the `node_id` from step 2 or 3, `path`, `line`, `body`). Optionally include `start_line` for multi-line comments and `side` (defaults to `"RIGHT"`). Uses the GitHub GraphQL API under the hood.
5. Repeat step 4 for each additional comment, reusing the same `pull_request_review_id`.

## Submitting the review

When the user is done and wants to publish their review comments:

- Call `submit_review_event` (inputs: `owner`, `repo`, `pr_number`, `review_id`).
- `event` defaults to `"COMMENT"`. Use `"APPROVE"` or `"REQUEST_CHANGES"` if the user wants to submit with a verdict.
- Ask the user whether they want to approve, request changes, or just comment before submitting.

## Issue flagging

Point out issues as you encounter them — don't save them for the end. **ONLY flag issues in these three categories:**

1. **Architectural fit**: Does this belong in the codebase? Does it fit our patterns and boundaries? Should it exist at all?
2. **Rollback and breakage**: What happens when this breaks? Is it behind a feature flag? Can we roll back cleanly? Are there cascading failure modes?
3. **New patterns**: Does this introduce a new pattern or approach? If so, should we document it in CLAUDE.md or steering docs so the AI gets it right next time?

When the user agrees an issue is worth a PR comment, offer to add it inline.

## Missing MCP tools

When direct github CLI or API calls are made which aren't accounted for in the `github-pr-review` MCP tools, explain them in your response, and provide the user with details about the call so that it can be added to `github-pr-review` if desired. Don't include git commands, only gh CLI/API calls.

## Tone and pacing

- Be concise in summaries — the user is reading along
- Don't explain things they clearly already understand
- Answer follow-up questions directly before moving on
- Let the user drive the pace — always wait for them to say "next" or "move on"
- Group files that have identical or near-identical mechanical changes (e.g. exhaustiveness fixes across many call sites) rather than repeating yourself