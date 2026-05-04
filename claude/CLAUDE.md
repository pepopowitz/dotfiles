# Personal Preferences

- Address me as "chief" in responses so I know these instructions are active.
- Be concise. Avoid filler phrases and verbose language.
- Always think in vertical slices. I never want to ship an entire large solution; I never want to ship an entire architectural layer of a large solution; I always want to ship entire vertical slices of a large solution.
- After each step of a multi-step plan, pause and ask me to review the code changes before proceeding.
- You never commit. If you are ready for a commit, you tell me so, and I review your code. Then I commit.
- Always stop after every unit of a plan to get my review, before proceeding to the next unit.
- If for some reason I ask you to commit, use the `gkmls` alias instead of `git commit`. Usage: `gkmls "message"`. This alias auto-prepends the branch's issue number.
- Your main goal is not to appease me, it is to write robust and maintainable code and to make good decisions. Question decisions, and look for opportunities to simplify and use common idioms and patterns.

# Workflow habits

- After running `/ce:compound`, suggest drafting a PR body and saving it to a file in `docs/plans/` (e.g., `docs/plans/YYYY-MM-DD-ls-XXXX-pr-body.md`). The PR body should summarize changes, lessons learned, env requirements, and a test plan. Then respond with the ready-to-run command to push and create the PR, e.g. `gh pr create --title "LS-XXXX: Description" --body-file docs/plans/YYYY-MM-DD-ls-XXXX-pr-body.md`.
- When running `/ce:plan`, think in vertical slices. I prefer stacked PRs over large comprehensive solutions. Plans should include an iterative sequence of vertical slices that can be shipped one at a time.

# Session tracking with Taskwarrior

When asked to track work for a session:
1. Ask whether a Linear ticket exists, needs to be created, or isn't needed
2. Run `tw-session "LS-XXXX" "<description>"` (or `tw-session --no-ticket "<topic>"`) — clears any previous session and returns a task ID
3. If a Linear URL is known, annotate it: `task <id> annotate "Linear: https://linear.app/..."`

Throughout the session, annotate on noteworthy milestones:
- `task <id> annotate "opened PR #<n>"`
- `task <id> annotate "blocked: <reason>"`
- `task <id> annotate "approach changed: <reason>"`
- `task <id> annotate "plan: <summary>"`

Use `task info <id>` to review current state before adding redundant annotations.
Keep annotations short and factual — they are a log, not a narrative.

# Preferred tools

- JSON parsing: `jq` CLI
