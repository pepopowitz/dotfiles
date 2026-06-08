# skills to build

## finish up work

- generate body
- format pr name
- push up stack

## plan

- plan units as standalone PRs - no regressions, behind a feature flag, entirely shippable units
- identify most uncertain/riskiest details of implementation and include a unit to build a proof of concept for each
  - example: can mobile sheets handle scrolling of long documents, or do the long documents need to be in a full screen?

## draft pr body

- be succinct but complete. No walls of text.
- After running `/ce:compound`, suggest drafting a PR body and saving it to a file in `docs/plans/` (e.g., `docs/plans/pr-body-YYYY-MM-DD-ls-XXXX.md`). The PR body should summarize changes, lessons learned, env requirements, and a test plan.
- Respond with the ready-to-run command to push and create the PR, e.g. `gh pr create --title "LS-XXXX: Description" --body-file docs/plans/YYYY-MM-DD-ls-XXXX-pr-body.md`.
  - or the appropriate stack command (todo)
