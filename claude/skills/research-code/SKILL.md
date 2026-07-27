---
name: research-code
description: >-
  Researches a named concept or system in the current codebase and generates a
  self-contained HTML report that introduces it to someone new to the
  codebase, using a layered explanation that moves from most abstract to most
  concrete (big picture, how it connects, real end-to-end scenarios, UI
  surfaces, building blocks, entry points for common tasks, then recurring
  patterns), then files it into the docs index and glossary. Opens in the
  browser. Use when the user wants to understand a system they didn't build,
  onboard onto an unfamiliar area, or get a shareable primer on how something
  works.
---

# Research Code

Generate a self-contained HTML primer on a named concept or system in the
current codebase, then open it in the browser. The audience is a competent
engineer who is new to *this* codebase — not a beginner, but someone with zero
context on this system's specific concepts, names, and file layout.

All code documentation should be generated in the ~/sjh/dev/puzzmo/docs project/folder.

## Step 1: Identify the subject

Determine the concept/system name from the invocation (e.g. `/research-code
submissions system`, or "explain how the flags system works").

If no subject was given, ask the user what to research. If the subject is
ambiguous (e.g. it could mean two different things in the codebase), do a
quick exploratory search first and confirm with the user which one they mean
before doing the full research pass.

Derive:
- `TITLE` — humanized, e.g. "Submissions System"
- `SLUG` — kebab-case, e.g. `submissions`. If the subject doesn't already
  imply "system", the output filename still ends in `-system.html` for
  consistency with existing reports in `/Users/Steven.Hicks/sjh/dev/puzzmo/docs`.

## Step 2: Research the codebase

This is the bulk of the work. The goal is to understand the system well
enough to explain it in layers — don't stop at the first file you find.

1. **Survey existing reports first.** List `~/sjh/dev/puzzmo/docs/*.html` in the
   project. These are prior `research-code` outputs and count as *already
   understood* — the reader (or a future reader) shouldn't be re-taught a
   system that already has its own primer. Read
   `~/sjh/dev/puzzmo/docs/glossary.html` before anything else: it's a fast map
   of the vocabulary the existing reports have already established, and its
   "Easily confused" section tells you which words are already overloaded —
   both of which you need to know before writing a line. For each existing
   report:
   - If it covers this exact subject, read it fully and treat it as a draft
     to refresh rather than a blank slate — but still re-verify claims
     against current code (it may be stale).
   - If it covers a *different* system that turns out to be adjacent to this
     one, note its filename and skim its "Why This Exists"/"Core Concepts"
     sections just enough to avoid duplicating them. You'll cross-reference
     it instead of re-explaining it (see Step 3).
2. **Locate the surface area.** Search broadly for the concept name across
   the repo: GraphQL SDL (`*.sdl.ts`), service files, Prisma schema models,
   frontend screens/components, scripts, and any per-workspace `CLAUDE.md`
   that might describe conventions for the relevant app.
3. **Use Explore agents for breadth.** This is a large Turbo monorepo — don't
   try to grep your way through it serially. Launch one or more `Explore`
   agents in parallel to cover distinct angles, e.g.:
   - Backend: GraphQL schema, services, Prisma models, scripts
   - Frontend: screens, components, hooks tied to this concept
   - Cross-cutting: related systems, shared packages, existing docs/comments
   Ask each agent to report back concrete file paths and line numbers, not
   just prose summaries — you'll need exact `path:line` references for the
   report.
   Explicitly ask the frontend-angle agent for a **screen/route inventory**:
   every distinct screen, route, embed variant, or admin page that surfaces
   this system to a user, with its route path (if any), which app it lives in
   (puzzmo.com, dev.puzzmo.com, workshop, studio, user-admin, native-app),
   and the top-level component file. This becomes the Screens & UI Surfaces
   section and feeds the Scenarios — routes discovered here are what the
   Scenarios section names when a walkthrough visits a screen, so don't
   shortchange it.
4. **Read the key files yourself.** Once the Explore agents narrow down the
   important files, read the actual source for the ones that matter most: the
   orchestrating function/resolver, the core type definitions, the main
   frontend entry point. You need enough firsthand understanding to explain
   *why*, not just *what* — don't rely solely on agent summaries for the
   parts you'll be writing the most about.
5. **Identify branches.** Note whether the system has significant branches —
   distinct types, modes, or code paths that meaningfully change what happens
   (e.g. a config `type` enum with different runtime behavior per value, an
   admin vs. self-service flow, a sync vs. async path). This drives how many
   scenarios you'll need in Step 3 — one branch, one scenario. A system with
   no real branching just needs one scenario covering its single path.
6. **Identify adjacent systems.** Note any system that's easily confused with
   this one, or that this one depends on / is depended on by. If there's a
   genuinely useful contrast worth explaining, it becomes the Related Systems
   section — but check the survey from step 1 first: if that adjacent system
   already has its own `~/sjh/dev/puzzmo/docs/*.html` report, the Related Systems section
   should link to it and state the boundary in a sentence or two, not
   re-explain the adjacent system from scratch. Only build a full comparison
   table for adjacent systems that have no existing report.
7. **Identify maintenance surface.** Figure out concretely: where would
   someone add a new feature to this system, where would they debug a common
   failure, what are the 2-4 places you'd touch to make a typical change.

## Step 3: Synthesize content into the template

Read the template at `.claude/skills/research-code/template.html`. For each
`<!-- SLOT:name -->` placeholder, generate HTML content that replaces it. Do
NOT modify the template structure, CSS, or JS — only replace slot comments.

This report is ordered **most-abstract-first**: each section should assume
only what the sections above it established, and get progressively more
concrete — narrative, then architecture, then concrete walkthroughs, then UI
surfaces, then code-level nouns, then exact instructions for changing it,
then code-level idioms. Related Systems always runs last, as a
footnote — it's a pointer outward, not a building block for anything below
it. Don't front-load implementation details into Why This Exists, and don't
repeat Why This Exists's framing later — each section should earn its place
by adding information the sections above it didn't have. Do not render "Pass
N" labels or similar meta-commentary about this structure anywhere in the
output — the section order should speak for itself.

### SLOT:title
`TITLE` from Step 1.

### SLOT:header_pills
One `<span class="pill">` per relevant tag: workspace(s) involved (e.g.
`api.puzzmo.com`), key tech (e.g. `GraphQL + Relay`, `Prisma`), and the
system's rough category (e.g. `Scheduling`, `Personalization`, `Partner
Embeds`).

### SLOT:why_this_exists (the big picture)
2-3 `<p>` tags, each 2-3 sentences — this section is read in full every time,
so it must earn every sentence. Answer: what problem does this system solve,
and why does it exist as a distinct thing rather than being folded into
something else? Written for someone who has never heard of this system's
internal terminology — don't use a term from Core Concepts before it's been
introduced here in plain language. If there's a natural contrast with an
adjacent system, one clause framing that distinction belongs here (the detail
goes in Related Systems later). If that adjacent system already has its own
report, treat it as known — name it and move on, don't summarize what it
does. If you find yourself writing a 4th paragraph, something belongs in a
later section instead — cut it.

### SLOT:how_it_works (the architecture, top to bottom)
**Lead with a Mermaid architecture diagram** (required — see "Diagrams" below).
A `flowchart` is the default: one node per system-level participant (repo,
service, store, queue, runtime) and a labeled edge for what crosses each
boundary (a sync, a write, a published artifact, a request). The diagram is
the primary representation of the architecture — prefer it over describing the
wiring in prose. Follow it with a short ordered list (`<ol>`) of the 3-6 major
stages the system moves through end to end — e.g. "Sync → Attach → Publish →
Run" — each a `<li>` with a bolded stage name and 1-2 plain-English sentences
that annotate the diagram rather than re-listing every edge in it.

This is architecture, not a shortened scenario: the diagram and list name the
*system-level participants* involved and what crosses the boundary between
them. They answer "what are the moving parts and how do they connect," at the
level you'd draw on a whiteboard before writing any code. They do NOT answer
"what does a specific person click and see" — that's what Scenarios is for, and
the two should feel different to read, not like one is a trimmed copy of the
other. Concretely: no file paths, line numbers, `<pre class="code-block">`
snippets, or named people/personas here — the diagram's nodes are systems, not
functions or files. This section should read the same whether or not the reader
ever opens the code, and whether or not the system has multiple branches — the
architecture is the same shape regardless of which branch a given run takes
(branch-specific behavior is what Scenarios is for). If you catch yourself
naming a function, file, or "the admin does X," that belongs in Scenarios, Core
Concepts, or Entry Points instead — move it there.

### SLOT:scenarios (concrete walkthroughs — always required)
One `<div class="learning-insight">` per scenario:
```html
<div class="learning-insight">
  <h3>Scenario name, framed around who wants what</h3>
  <p><em>One-line persona and goal, e.g. "A partner wants X, so that Y."</em></p>
  <ol>
    <li>Numbered, chronological step naming real identifiers, routes, and
    functions as they'd actually be encountered — what a person does, then
    what the system does in response.</li>
    <li>… continue through to the observable outcome.</li>
  </ol>
</div>
```
Every report needs **at least one** end-to-end scenario — this section is not
optional the way Related Systems is. If Step 2 identified significant
branches (distinct types/modes/paths), write **one scenario per branch**,
each with a different persona/goal, so every branch gets exercised by a real
walkthrough rather than described only in the abstract. A system with a
single path just needs the one scenario.

When a scenario crosses several participants (a person, a frontend, a
resolver, a job, a store), **add a Mermaid `sequenceDiagram`** above or below
the `<ol>` to show the call/response order visually — favor the diagram over
spelling the hop sequence out in prose. Put it in a `<div class="diagram">`
(see "Diagrams" below). Actors should be the same participants named in How It
Works; the numbered steps then annotate the diagram with the concrete
identifiers, routes, and gotchas. A short linear scenario that touches one or
two participants doesn't need a diagram — use one only when it earns its space.

Ground every step in what actually happened when you traced the code —
including non-obvious branches or gotchas the trace revealed (a silent
fallback, a step that's skipped for one branch, a check that fails closed).
Call these out inline with a bolded `<strong>Gotcha worth knowing:</strong>`
lead-in; they're often the most valuable sentence in the whole report.

When a step describes a person navigating to or acting within a UI screen,
name that screen by its **URL/route** (from the Screens section below), not
by a link to its source file — see "Screens vs. file paths" under File path
references. Reserve file-path references within a scenario for naming
specific functions, components, or code entities the trace passed through.

### SLOT:screens (reference — every UI surface, cataloged)
One `<div class="screen-card">` per distinct screen, route, embed variant, or
admin surface tied to this system. The Scenarios above already walked through
specific screens in context; this section is the canonical index of all of
them, for a reader who wants to jump straight to one:
```html
<div class="screen-card">
  <div class="screen-card-header">
    <h3>Screen name</h3>
    <span class="route">/route/path/</span>
  </div>
  <div class="platform-tags">
    <span class="platform-tag">puzzmo.com</span>
  </div>
  <p>What a user actually sees and does here, in plain language — not what the code does.</p>
  <div class="screen-files">
    <span class="file-path" data-path="relative/path.tsx:LINE"><span class="copy-label">path.tsx:LINE</span> <svg class="copy-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1"/></svg><svg class="check-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg></span>
  </div>
</div>
```
- `route` is the URL path if the screen is web-routable; omit the `<span
  class="route">` entirely for things without a route (e.g. a native-app
  screen, or an admin panel section reached via UI navigation rather than a
  direct URL).
- `platform-tags` names the app(s)/surface(s) it lives in — e.g.
  `puzzmo.com`, `Partner Embed`, `dev.puzzmo.com`, `studio`, `iOS`. Include
  more than one tag if the same screen serves multiple contexts (e.g. a
  screen rendered both standalone and inside an embed).
- Order cards by how a user would encounter them: primary/main screen first,
  then variants (embed, admin, alternate platform) after.
- If the system has no direct UI surface at all (e.g. it's a pure backend
  scheduling or data pipeline), replace the slot with
  `<p class="empty">This system has no direct UI surface — it's backend-only.</p>`
  rather than forcing screen cards that don't exist.

### SLOT:core_concepts (the building blocks)
One `<div class="glossary-term">` per concept, in the order a newcomer should
learn them (foundational types/functions first, derived/peripheral ones
last):
```html
<div class="glossary-term">
  <div class="term">ConceptName</div>
  <div class="alias"><span class="file-path" data-path="optional/file/path.ts:LINE"><span class="copy-label">path.ts:LINE</span> <svg class="copy-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1"/></svg><svg class="check-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg></span></div>
  <div class="def">What it is and why it matters. Use <code>inline code</code> for identifiers.</div>
</div>
```
The `alias` line is optional (omit the whole `<div class="alias">` for a
concept that isn't tied to one specific file, e.g. a GraphQL type defined
across SDL and resolver) — but when it is included, it MUST use the
`file-path` widget like every other file reference in the report, not a bare
path string.

Cover the 5-10 nouns/functions someone must know to read the code — GraphQL
types, key orchestrator functions, important config objects, notable
enums/flags. Skip anything so generic it needs no explanation (don't define
"a React component"). Also skip — or reduce to a one-line mention with a
link — any concept that properly belongs to an adjacent system that already
has its own `~/sjh/dev/puzzmo/docs/*.html` report; define it there once, not twice.

### SLOT:entry_points (how to touch it)
Open with one lead-in line: `<p style="font-size:0.9rem;margin-bottom:16px;">"I want to do X. Where do I start?"</p>`.
Then one `<div class="entry-point">` per common task:
```html
<div class="entry-point">
  <h4>Task framed as an action, e.g. "Add a new status to the pipeline"</h4>
  <p>Concrete guidance naming the actual functions/files involved and the order to read/touch them in, down to an exact CLI command if one is needed (e.g. <code>yarn workspace api regenerate</code>). Every file named gets a file-path reference. If the task starts by navigating to a UI screen, name that screen by its URL/route (see "Screens vs. file paths" below), then drill into files from there.</p>
</div>
```
Aim for 5-8 entries — more than a token gesture. Cover the full range of
things someone new would plausibly want to do: understand a specific flow
end to end, trace what happens on a specific state transition, add a new
variant/type/status to an existing enum-like construct, add a new
plugin/handler/extension point, wire up a new endpoint, and debug a common
failure. Each entry should read like a specific, followable trail through
real identifiers — not generic advice like "check the relevant service file."
This is the section where the reader graduates from "I understand this" to
"I could safely change this."

### SLOT:patterns_and_conventions (recurring idioms)
One `<div class="learning-insight">` per pattern:
```html
<div class="learning-insight">
  <h3>Pattern name, e.g. "Soft delete everywhere"</h3>
  <p>The convention, stated precisely with real field/function names, and why the codebase does it this way. Not a one-off fact about a single call site — a recurring idiom that shows up across multiple places in this system.</p>
</div>
```
This section captures the *implementation idioms* someone should follow when
writing new code in this system — the unwritten rules a reviewer would flag
if you didn't follow them. Look for things like: a versioning/history model,
a dispatch-by-flag or dispatch-by-type mechanism, a soft-delete-vs-hard-delete
convention, a precedence/fallback chain between two related fields, a
snapshot-at-creation-time pattern, a scoping/uniqueness convention (e.g.
per-team slugs). These come from noticing the *same shape* repeated at
multiple call sites during research, not from a single interesting line.

This is distinct from Core Concepts (which names the nouns) and Entry Points
(which is task-oriented) — this section is about the recurring *shapes* the
code takes. It runs after Entry Points because it's the most implementation-
dense section — spotting a cross-cutting idiom usually depends on having
already seen a few concrete tasks/files, which Entry Points just supplied. If
research didn't surface any real recurring patterns — only one-off facts —
don't pad this section with those; use
`<p class="empty">No strong recurring patterns surfaced during research.</p>`
instead.

### SLOT:related_systems (optional, always the last section)
Only include if Step 2 surfaced a genuinely adjacent system worth
contrasting. This section is a footnote pointing outward, not a building
block anything else in the report depends on — that's why it always runs
last, after Patterns & Conventions.

**If the adjacent system already has its own `~/sjh/dev/puzzmo/docs/*.html` report**,
don't re-explain it — link to it instead:
```html
<div class="learning-insight">
  <h3>vs. Other System</h3>
  <p>One or two sentences on the boundary between the two systems — who owns what, who calls whom.</p>
  <p><a href="other-system.html">See the full primer on Other System →</a></p>
</div>
```

**If it has no existing report**, build a full
`<table class="comparison-table">` with a `Dimension` column plus one column
per system, 5-10 rows covering purpose, when it runs, data ownership, and any
other axis that clarifies the boundary. Follow with a short
`<div class="learning-insight">` explaining how the two connect (shared
boundary function, shared table, etc.).

If nothing is meaningfully adjacent, replace the slot with
`<p class="empty">No closely related systems worth contrasting.</p>` — do not
force a comparison.

### Diagrams (used in How It Works and Scenarios)
The template already loads and configures Mermaid (theme-matched to the page)
and styles the `.diagram` wrapper — do NOT add a `<script>`, re-initialize
Mermaid, or restyle it. Just emit a `.diagram` block; it renders on load:
```html
<div class="diagram">
  <pre class="mermaid">
flowchart LR
  Player([Player]) -->|submits guess| API[api.puzzmo.com]
  API -->|writes| DB[(Prisma / Postgres)]
  API -->|enqueues| Job[Scoring job]
  Job -->|publishes| DB
  </pre>
  <div class="diagram-caption">How a submission moves through the system.</div>
</div>
```
- Use a `flowchart`/`graph` for architecture (How It Works) and a
  `sequenceDiagram` for ordered walkthroughs (Scenarios). Both are configured
  and styled already.
- The `<div class="diagram-caption">` is optional — a one-line label for what
  the diagram shows.
- Keep node labels to real participant/system names, short. Do NOT put file
  paths, line numbers, or the `file-path` widget inside a diagram — those live
  in prose and cards.
- **HTML-escape** any `<`, `>`, or `&` inside diagram text (e.g. write
  `--&gt;` only in prose, not in Mermaid syntax where `-->` is literal; but
  escape stray `<`/`&` in node labels). Prefer plain labels that avoid these.
- Mermaid syntax is whitespace/indentation sensitive — keep the diagram source
  left-aligned inside the `<pre>` as shown, not indented to match surrounding
  HTML.

### File path references (used throughout)
Every code reference uses this pattern, with the line number looked up on the
current HEAD of the file (not a diff line). `data-path` carries the full
relative path (used for copy-to-clipboard) but the visible `copy-label` text
is just the filename — the full path takes up too much horizontal space in
running prose and cards:
```html
<span class="file-path" data-path="relative/path.tsx:LINE"><span class="copy-label">path.tsx:LINE</span> <svg class="copy-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1"/></svg><svg class="check-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg></span>
```

**Screens vs. file paths.** When prose describes a person navigating to or
acting within a UI screen — in Scenarios, Entry Points, or anywhere else —
name that screen by its **URL/route** (plain `<code>` text, e.g.
`/admin/things/{id}/edit`), never by a `file-path` link to the screen
component's source. A route is what the person actually sees and types/clicks;
a source file is where a developer would go to change it. The `file-path`
widget stays reserved for source code: functions, components, models,
resolvers, non-screen files. The Screens & UI Surfaces cards are the one
place both appear together by design (route in the header, source in
`screen-files`) — that's a reference index, not a navigation instruction.

## Step 4: Write and open

Write the filled template to `~/sjh/dev/puzzmo/docs/${SLUG}.html` in the current
project's working directory (create `~/sjh/dev/puzzmo/docs/` if it doesn't exist). If a file
of that name already exists, overwrite it — this is a fresh regeneration, not
a diff.

```bash
open ~/sjh/dev/puzzmo/docs/${SLUG}.html
```

## Step 5: Update the index and glossary

The docs folder has two hand-maintained pages that index every report:
`~/sjh/dev/puzzmo/docs/index.html` and `~/sjh/dev/puzzmo/docs/glossary.html`. A
new report is not done until both know about it. These are **not** templates —
there are no slots. Read each one and edit it in place; never regenerate them
from scratch, or you'll drop the hand-written cross-references already there.

### index.html

1. Add one `<a class="doc-card">` for the new report, following the existing
   card structure exactly (`<h3>` = `TITLE`, `<p>` = 2-3 sentences, `<div
   class="tags">` of `<span class="tag">`).
2. Put it in the section that fits (e.g. "Puzzle Content & Scheduling",
   "Player Experience"). If none fits, add a new `<section>` with a short
   `<h2>` — don't force a bad fit.
3. The card's `<p>` should be derived from the report's Why This Exists, not
   copied from it: say what the system is and the one thing that's surprising
   about it. The `tags` mirror `SLOT:header_pills`.
4. Bump the `<span class="pill">N system primers</span>` count in the header.

### glossary.html

The glossary has two parts, and a new report usually feeds both.

1. **Terms.** For each new piece of domain vocabulary the report introduces,
   add a `<div class="term">` into the right alphabetical `letter-group`
   (create the group if that letter has none). Copy the existing entry
   structure: `term-head` (with `term-name` and a `term-kind` chosen from the
   ones already in use — `api`, `app`, `artifact`, `concept`, `convention`,
   `endpoint`, `field`, `file`, `format`, `helper`, `infra`, `model`, `param`,
   `pattern`, `system`, `tech`), a `<p>` definition, an optional `<span
   class="heads-up">` for a trap, and `term-refs` links to the reports that
   cover it.
2. **Existing terms the new report also covers.** `term-refs` is cumulative —
   if the new report is now a good source for a term that's already listed,
   add a link to it on that entry. Don't create a second entry for a term that
   already exists; extend the one that's there.
3. **Confusables.** If Step 2's "Identify adjacent systems" turned up a name
   collision — the new system reusing a word that already means something else
   in another report (`config`, `status`, `slug`, and `runtime` each already
   have entries) — add or extend a `<div class="confusable">` in the
   `#confusables` section. These are the highest-value part of the glossary;
   a new report that introduces a collision and doesn't record it has left the
   most useful thing on the floor.
4. Bump the `Terms drawn from the N system primers` pill.

### Grounding

Every definition must come from what the report actually says, which in turn
came from the code — do not define a term from general knowledge of the
technology's name. If a term is used across the docs but never actually
explained by any of them, it's fine to say so in the entry rather than invent
a definition (see the `Tapped` entry for the established phrasing). The
filter box searches raw text content, so no data attributes or registration
are needed — a well-written entry is automatically findable.

## Rules

### Brevity is the #1 rule — walls of text are a failure

This is the rule most often violated. Treat it as a hard constraint, not a
preference. If you are unsure whether a block is too long, it is — cut it.

**Hard caps (enforce on every single block you write):**
- **Sentences: max ~20 words.** If a sentence has a comma-spliced second
  clause explaining the first, split it or delete the second clause.
- **Paragraphs: max 3 sentences.** A 4th sentence means the content belongs
  in a list, a later section, or the bin.
- **No block exceeds ~50 words of prose.** Why This Exists paragraphs and
  scenario steps included.
- **Prefer a list to a paragraph** the moment you are describing more than one
  thing. Two related facts = two bullets, not one sentence with "and".

**Cut these on sight — they are pure filler:**
- Framing preambles: "It's worth noting that", "The key thing to understand
  is", "At a high level", "Essentially", "Fundamentally".
- Restating the heading in the first sentence of a block.
- Explaining *why something is nice* ("this is elegant because…",
  "the guiding idea is…") — state the fact, drop the appreciation.
- Second clauses that re-say the first in different words.
- Adjectives that add no information: "deliberately", "comprehensive",
  "robust", "powerful", "simply", "just".

**Concrete before/after** — this is the target density:

> ❌ *"This repo does two jobs. First, it converts any of those foreign
> formats into `.xd`. Second, it turns an `.xd` document into a deliberately
> over-rich JSON object (`CrosswordJSON`) that an app can render with zero
> further parsing — the grid is pre-expanded into typed tiles, clues carry
> their board positions, and clue text is pre-parsed into a markup tree."*
>
> ✅ *"Two jobs:"* followed by two bullets: *"**Converts** foreign formats into
> `.xd`."* / *"**Parses** `.xd` into a rich `CrosswordJSON` — typed tiles,
> clues with positions, markup trees. Parse once, render with zero work."*

The ✅ version says everything the ❌ version does in ~40% of the words. That
gap is the bar. When drafting a section, write it, then delete every word that
survives its sentence being true without it.

- Do NOT modify the template's CSS, JS, or structure — only replace slot
  comments. This includes the Mermaid setup (`<script type="module">` and the
  `.diagram`/`.mermaid` styles) — it's already wired; just emit `.diagram`
  blocks.
- Favor diagrams over text for flow and architecture. How It Works must lead
  with a Mermaid architecture diagram; multi-participant Scenarios should use a
  Mermaid `sequenceDiagram`. See "Diagrams" above for the snippet.
- Do NOT let later sections repeat earlier sections' framing — each section
  should add new information, not restate the last one in more words.
- Every prose block obeys the hard caps in "Brevity is the #1 rule" above:
  ≤20-word sentences, ≤3-sentence paragraphs, ≤50 words per block, lists over
  prose. This is not aspirational — a block that breaks a cap is wrong and must
  be cut before you move on.
- How It Works and Scenarios are different in *kind*, not just length: How
  It Works stays at the architecture level (system participants, boundaries,
  what crosses them) with no files/functions/personas; Scenarios is where
  the concrete, file-referencing, person-driven walkthroughs live. Don't
  write How It Works as a shrunken Scenario.
- Always include at least one scenario in Scenarios, End to End — it is not
  optional. If the system has significant branches, write one scenario per
  branch (see "Identify branches" in Step 2 and the SLOT:scenarios guidance).
- Name a UI screen by its URL/route in running prose; reserve `file-path`
  links for source code. See "Screens vs. file paths" above.
- Assume the reader is an experienced engineer new to *this* codebase — don't
  explain generic language/framework concepts (React, GraphQL, HTTP), do
  explain this codebase's specific names, conventions, and non-obvious
  choices.
- Every code/file reference MUST include a copyable file path with a line
  number, looked up on HEAD, not the search-result line.
- HTML-escape any code content that contains `<`, `>`, or `&`.
- If a section has no content, use the `<p class="empty">` pattern rather
  than omitting the section entirely.
- Keep the page scannable. Prefer structured content (lists, tables, cards)
  over paragraphs, except in Why This Exists, which should read as concise
  prose.
