---
name: write-pr-body
description: Writes a pull request body in Steve's two-layer style — a terse, human-sounding lead that lists what was added, fixed, or removed, followed by the full detailed writeup collapsed inside a details/summary block. Use when asked to write, draft, or rewrite a PR body or description.
license: CC-BY-4.0
---

# Write PR Body

## Shape

Every PR body has exactly two layers:

```markdown
<linked issue / blocking line, if any>

<lead: 3-12 lines, terse, human>

<details>
<summary>claude's looonggg summary</summary>

<everything else>

</details>
```

Nothing lives between the lead and the `<details>` block. If it isn't in the lead, it goes inside the collapsed section.

## Step 1: gather

- `stack-base` to find the base branch, then `git log <base>..HEAD` and `git diff <base>...HEAD`.
- Look for a linked issue (branch name, commit messages, or ask).
- Read the diff well enough to explain *why*, not just *what*. The collapsed section is worthless if it only restates the diff.

## Step 2: the lead

This is the part a reviewer actually reads. Write it the way Steve would in a hurry.

- Open with the link line when there is one: `Closes #5265.` or `Blocks org/repo#3 (branch \`x\`).` Then a blank line.
- One or two sentences of framing, only if the PR needs it (what it enables, what it replaces and why).
- Then a flat bullet list of what changed, grouped by kind when there's more than one kind:

```markdown
1. Improves ClickHouse query list view:
- Adds a search box
- Adds a sort option

2. Fixes pre-existing bugs:
- Delete never worked.
- Toast feedback was never rendered.
```

Rules for the lead:

- Present tense, subject dropped: "Adds a search box", not "This PR adds a search box".
- Bullets for fixes state the broken behavior, not the patch: "Delete never worked." beats "Registers `:clickhousequery` in `nodeTypeMap`."
- No file paths, no symbol names, no code fences, no headings.
- Never more than ~12 lines total. If it's longer, it belongs in the details block.
- No marketing adjectives, no "comprehensive", no "robust", no emoji.

## Step 3: the collapsed summary

Open with `<details>` / `<summary>`. Vary the summary label the way Steve does — `claude's blog post`, `Claude's looonggggg summary` — self-deprecating about its length.

Inside, use `##` headings and write at whatever length the change deserves. Typical sections, include only the ones that apply:

- **What changed** — per-area prose with the reasoning. Explain constraints that forced the design.
- **Bugs fixed** — one bold-led bullet per bug: what was broken, the root cause, the fix.
- **Why X is the way it is** — the non-obvious design decisions, and what breaks without them.
- **Lessons learned** — durable rules, not this-PR trivia.
- **Environment requirements** — migrations, env vars, deps, restarts. Say "None." when none.
- **Release order** — only when something must ship before or after this.
- **Test plan** — how it was verified. Manual passes as prose, reviewer steps as `- [ ]` checkboxes with expected results.
- **Known gaps** — what isn't covered and why.

Inside the details block, be specific: name files, symbols, and messages. Include short code blocks where they're the clearest explanation.

## Step 4: save it

Write to `docs/plans/YYYY-MM-DD-NNNN-pr-body.md`, where `NNNN` is the issue number when there is one, otherwise the project name. Then offer the two ready-to-run commands:

- `gh pr create --title "..." --body-file docs/plans/<file>.md`
- `st submit`, then `gh pr edit NNN --body-file docs/plans/<file>.md`

## Anti-patterns

- A lead that is a prose paragraph instead of a list of changes.
- Duplicating the lead's bullets as the first section inside the details block.
- Burying a breaking change or a required restart inside the details block only.
- "This PR..." / "In this change we..." — just say what it does.
