# Personal Preferences

- Address me as "steverino" or "steveo" in responses so I know these instructions are active.
- Be concise. Avoid filler phrases and verbose language.
- Always think in vertical slices. I never want to ship an entire large solution; I never want to ship an entire architectural layer of a large solution; I always want to ship entire vertical slices of a large solution.
- Commit after completing each implementation unit or logical step of a plan. Do not batch multiple units into one commit. When working autonomously, commit immediately after each unit passes tests — do not defer commits to the end.
- Pull requests should be small, and stacked. Never one-shot a large solution into one branch/PR.
- Always use `st add` to create new branches so the stack is tracked. Never use `git checkout -b` or `git branch` directly — the stack tooling needs to know about every branch. This is important so that Steve can also follow the work as a human.
- Your main goal is not to appease me, it is to write robust and maintainable code and to make good decisions. Question decisions, and look for opportunities to simplify and use common idioms and patterns.
- Always include the issue number as a prefix for commit messages, e.g. `ls-1234: do something`. Use the `gkmls` alias to append this prefix automatically.
- Do not chain multiple shell commands into a single line using `&&`, `$()`, or pipes when each command is independently approvable. Run them as separate Bash calls so that I don't need to reapprove a combination of commands that are already individually approved.

# /ce (compound engineering) workflow preferences

- After running `/ce:compound`, suggest drafting a PR body and saving it to a file in `docs/plans/` (e.g., `docs/plans/YYYY-MM-DD-ls-XXXX-pr-body.md`). The PR body should summarize changes, lessons learned, env requirements, and a test plan. Then respond with 2 ready-to-run commands to push and create the PR:
  1.  via the `gh pr` cli, e.g. `gh pr create --title "LS-XXXX: Description" --body-file docs/plans/YYYY-MM-DD-ls-XXXX-pr-body.md`.
  2.  via the `clabby/st` cli, which requires two commands: one to add the PR to the stack, and one to attach the body to the new PR:
      - `st submit`
      - `gh pr edit NNN --body-file path-to-body-file.md` where NNN is the new PR number
- When running `/ce:plan`, think in vertical slices. I prefer stacked PRs over large comprehensive solutions. Plans should include an iterative sequence of vertical slices that can be shipped one at a time.
- When planning work that consists of multiple phases, plan as multiple stacked pull requests.
- Never commit plans.
- Always commit solution docs from compounding.
- Prefix brainstorm/plan file names with a single letter to identify the type of doc, e.g. `b-2026-05-08-etc` for a brainstorm or `p-2026-05-08-etc` for a plan.

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

# Preferred tools and commands

- JSON parsing: `jq` CLI
- to identify base branch of current branch: `stack-base`
- to manage stacked branches: `st` (github.com/clabby/st)
  - add a new branch: `st create branch-name`
  - track an already created branch: `st track`
  - view current stacks: `supst`
  - navigate down a stack (further from main): `dnst`
  - navigate up a stack (closer to main): `upst`
  - rebase a stack of branches: `stash "drop" && st restack && git stash pop`
- to update main with origin: `sync`
- to commit: `gkmls` (prefixes commit message with linear issue number)
- compound-engineering plugin directories (assets/, references/, skills/) are always readable. Do not ask for permission to access them.
