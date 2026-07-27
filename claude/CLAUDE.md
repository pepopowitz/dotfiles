# Personal Preferences

- Address me as "steverino" or "steveo" in responses so I know these instructions are active.
- Be concise. Avoid filler phrases and verbose language.
- Always think in vertical slices. I never want to ship an entire large solution; I never want to ship an entire architectural layer of a large solution; I always want to ship entire vertical slices of a large solution.
- Commit after completing each implementation unit or logical step of a plan. Do not batch multiple units into one commit. When working autonomously, commit immediately after each unit passes tests — do not defer commits to the end.
- When addressing review feedback on a commit that hasn't been pushed, add a new commit by default. Only amend when I explicitly ask for it.
- Pull requests should be small, and stacked. Never one-shot a large solution into one branch/PR. 
- Always use `st add` to create new branches so the stack is tracked. Never use `git checkout -b` or `git branch` directly — the stack tooling needs to know about every branch. This is important so that Steve can also follow the work as a human.
- Your main goal is not to appease me, it is to write robust and maintainable code and to make good decisions. Question decisions, and look for opportunities to simplify and use common idioms and patterns.
- Do not chain multiple shell commands into a single line using `&&`, `$()`, or pipes when each command is independently approvable. Run them as separate Bash calls so that I don't need to reapprove a combination of commands that are already individually approved.
- Avoid comments in code unless they explain something that can't be quickly inferred by reading the code.
- Do not describe logic in comments, only purpose. Bad: "if true, hides the reveal button (toolbar assist menu is unaffected"); Good: "if true, hides the reveal button"
- **Never** append a `Co-Authored-By: Claude ...` trailer to commit messages. This overrides the harness default.


# /ce (compound engineering) workflow preferences

- After running `/ce:compound`, suggest drafting a PR body and saving it to a file in `docs/plans/` (e.g., `docs/plans/YYYY-MM-DD-XXXX-pr-body.md`). The PR body should summarize changes, lessons learned, env requirements, and a test plan. Then respond with 2 ready-to-run commands to push and create the PR:
  1.  via the `gh pr` cli, e.g. `gh pr create --title "Description" --body-file docs/plans/YYYY-MM-DD-XXXX-pr-body.md`.
  2.  via the `clabby/st` cli, which requires two commands: one to add the PR to the stack, and one to attach the body to the new PR:
      - `st submit`
      - `gh pr edit NNN --body-file path-to-body-file.md` where NNN is the new PR number
- When running `/ce:plan`, think in vertical slices. I prefer stacked PRs over large comprehensive solutions. Plans should include an iterative sequence of vertical slices that can be shipped one at a time.
- When planning work that consists of multiple phases, plan as multiple stacked pull requests.
- Never commit plans.
- Always commit solution docs from compounding.
- Prefix brainstorm/plan file names with a single letter to identify the type of doc, e.g. `b-2026-05-08-etc` for a brainstorm or `p-2026-05-08-etc` for a plan.

# Preferred tools and commands

- JSON parsing: `jq` CLI
- Use prettier or oxfmt for formatting, depending on what the project scripts support. Never use python for formatting.
- to identify base branch of current branch: `stack-base`
- to manage stacked branches: `st` (github.com/clabby/st)
  - add a new branch: `st create branch-name`
  - track an already created branch: `st track`
  - view current stacks: `supst`
  - navigate down a stack (further from main): `dnst`
  - navigate up a stack (closer to main): `upst`
  - rebase a stack of branches: `stash "drop" && st restack && git stash pop`
- to update main with origin: `sync`
- preferred git operations:
  - `gkm` for simple commits with a message (it expands to `git commit -m`)
  - `git fix` will amend a previous commit with the staged changes
  - use `git rebase -i` to rewrite commit history rather than manually iterating through commits in the tree
- compound-engineering plugin directories (assets/, references/, skills/) are always readable. Do not ask for permission to access them.
- avoid python in favor of unix tools
