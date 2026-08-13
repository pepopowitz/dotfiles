---
name: project
description: Structured workflow inspired by bouldering for planning and delivering non-trivial code changes — read the problem, research prior art, isolate the crux, prototype it, then ship the remaining slices as small stacked PRs. Use whenever the user invokes /project, wants to plan or start a new feature or piece of work, asks to break a problem down, or wants to prototype/work through the hard part of a solution first. Accepts an optional phase argument (dress, read, beta, crux, sequence, prototype, send) to re-enter the workflow mid-way, e.g. after a plan already exists.
license: CC-BY-4.0
---

# Project

Solve software problems the way a boulderer works a problem on the wall: understand it fully before pulling on, isolate the hardest move, work it cheaply in isolation, and only then climb the whole thing. In code: front-load understanding, kill the riskiest unknowns early with a prototype, and deliver everything else as small vertical slices.

## Phases

Run the phases in order. Each checkpoint marked **STOP** is a hard stop — present the output and wait for the user's feedback before continuing. Do not roll through a checkpoint because the next step seems obvious.

| Phase | Bouldering | Software |
|---|---|---|
| DRESS | Shoes on, chalk up | Branch and tooling setup |
| READ | Read the route from the ground | Understand and restate the problem |
| BETA | Learn from other climbers' attempts | Research prior art in the codebase |
| CRUX | Find the hardest move(s) | Identify the genuinely hard part(s) |
| SEQUENCE | Visualize the moves in order | Plan the vertical slices |
| PROTOTYPE | Work the crux moves in isolation | Prototype / walking skeleton for each crux |
| SEND | Climb the whole problem | Ship the remaining slices |

If invoked with a phase argument (e.g. `/project prototype`): when this session already wrote or loaded a plan, stay on that plan — never switch to a different one mid-session. In a fresh session, find the plan in `docs/plans/` (files prefixed `p-`) whose `branch` frontmatter matches the current git branch. Multiple sessions often run concurrently, each with its own plan, so "most recently modified" is not a reliable signal — if no plan matches the branch, or several do, list the candidates and ask the user to pick. Confirm the chosen plan before entering the phase.

## DRESS — gear up

Set up the branch before anything else. Determine the isolation level, inferring from the prompt when possible, asking otherwise:

**Is this an isolated line of work (based on main), or stacked on existing work?**

Isolated — ask which branch:
- *Current branch*: do nothing.
- *Main*: run `sync` (switches to main and pulls). Watch its output for yarn commands to run after the pull, and run them.
- *New branch off main*: run `sync` (watch for and run yarn commands), then `branch <branch-name>` with a name from the user.

Stacked on existing work:
- Run `branches` to list recent branch names; let the user pick the parent.
- Switch to the parent branch. Watch output for yarn commands to run after the switch, and run them.
- Ask for the new branch name, then `st create <branch-name>` so the stack is tracked.

`stack-base` identifies the base branch of the current branch when needed.

## READ — read the problem

Fully understand the problem before analyzing solutions. Read the relevant code, tickets, or docs the user points at. Then reframe: restate the problem in your own words, concisely and clearly — what's broken or missing, for whom, and what "solved" looks like. If the reframing surfaces ambiguity, ask.

**STOP**: present the problem statement and wait for the user to confirm you've read the route correctly. A wrong reading here poisons every later phase.

## BETA — gather prior art

Other climbers have tried these moves. Before inventing anything, learn what the codebase already knows. Fan out parallel read-only Explore agents (single message, multiple Agent calls) covering:

- What existing structures can we extend?
- What prior art solves a similar problem, and how?
- What surfaces need to be touched? Which surfaces should *not* need to be touched?
- What established patterns can we reuse?

Synthesize the results yourself — the agents' reports are not shown to the user. From the synthesis, name what's genuinely new: the patterns, structures, or surfaces this work must create that the codebase doesn't yet have.

## CRUX — find the hardest move

Identify the most difficult point(s) of the solution:

- What hasn't been done here before, or hasn't been done in this way?
- What new concept must be introduced?
- What needs refactoring to open a seam for the feature?

If a crux is murky, brainstorm or vet ideas with the user before locking it in.

Then recheck against the beta: is there an existing pattern or structure we overlooked that makes this easier than it looks? Cruxes have a way of dissolving on a second read.

**There can be zero cruxes.** If everything here has been done before, or all the pieces are already in place, say so and skip PROTOTYPE entirely. Never invent a crux to make the work feel harder than it is — a manufactured crux wastes a prototyping cycle.

## SEQUENCE — plan the moves

Break the delivery into small vertical slices that ship one at a time, as stacked PRs. Rules for slicing:

- Every slice must be testable by the user through the UI or an API call — not just unit tests. A slice that can only be verified by reading code isn't a slice.
- Refactors that open seams come as their own slices, *before* the slices that use them ("make the change easy, then make the easy change").
- Split along natural seams (layer, role, section, version), not arbitrary boundaries.

For more slicing strategies (walking skeletons, feature toggles, separating risky from routine work), read `references/small-slices.md`.

### Output: the plan doc

Write a plan to `docs/plans/p-<yyyy-mm-dd>-<kebab-case-description>.md` (e.g. `p-2026-05-08-optimize-versioned-docs.md`). The `p-` prefix identifies the doc type as a plan.

Plans are working notes, not prose. Use bullet points, sentence fragments, and nesting — never paragraphs that read like an article.

```markdown
---
date: <yyyy-mm-dd>
title: <short title>
description: <one-line summary of the plan>
tags: [<relevant tags>]
branch: <working branch from DRESS>
---

# <Problem title>

## Problem
- <confirmed problem statement from READ, as bullets>

## Beta (prior art)
- <what exists to extend, patterns to reuse>

## New concepts
- <what this work introduces that doesn't exist yet>

## The stack
- <top-to-bottom outline of the solution across layers>

## Cruxes
- <prioritized; each with problem + proposed approach — or "none">

## Slices
- [ ] 1. <slice> — <how the user verifies it>
- [ ] 2. ...
```

`date`, `title`, `description`, `tags`, and `branch` are mandatory frontmatter — `branch` is what lets a fresh session find this plan again. Add other fields when something is genuinely worth elevating (e.g. related PRs, parent branch).

The checkbox list doubles as state for re-entering the workflow later. Never commit plan docs.

**STOP**: present the plan and wait for the user's review before touching code.

## PROTOTYPE — work the crux

For each crux, in priority order, build a prototype or walking skeleton that solves it in the simplest possible way:

- Do not write production-ready code at this stage. No polish, minimal error handling, tests only if they help you learn faster. The goal is to kill the riskiest unknowns as early and cheaply as possible.
- Work each crux in isolation unless cruxes unavoidably interact.
- If alternatives surface while prototyping, note them — they're cheap now and expensive later.

Commit the prototype with `gkm "<message>"`.

**STOP**: present the commit (and any alternatives that surfaced) for review before the next crux or before moving to SEND.

## SEND — ship the slices

Work through the remaining slices from the plan doc, one at a time:

- Fill in the details of walking skeletons; tie crux prototypes together where appropriate. Prototype code gets promoted to production quality now.
- Complete one slice fully — including how the user will verify it — before starting the next.
- Commit each slice with `gkm "<message>"` as soon as it's done; never batch slices into one commit.
- Check off the slice in the plan doc.

**STOP** after each slice: present the commit and the verification path (what to click or call), and wait for review before the next slice.
