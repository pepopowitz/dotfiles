---
name: what-did-i-just-do
description: >-
  Generates a readable HTML page summarizing the learnings, decisions, and work
  done on the current branch. Opens in the browser. Use when finishing a branch,
  preparing a handoff, or reviewing what happened during a piece of work.
---

# Branch Recap

Generate a self-contained HTML summary of the current branch's work — decisions,
learnings, interesting code, and progress — then open it in the browser.

## Step 1: Identify the diff range

```bash
BASE=$(stack-base)
BRANCH=$(git branch --show-current)
```

## Step 2: Gather raw material

Run these commands to collect data. Read all outputs fully before proceeding.

### Git history
```bash
git log ${BASE}..HEAD --pretty=format:'%h|%s|%ai|%an' --reverse
```

### Diff stats
```bash
git diff ${BASE}..HEAD --stat
git diff ${BASE}..HEAD --shortstat
```

### Files added/changed on this branch
```bash
git diff --name-status ${BASE}..HEAD
```

### Plan and brainstorm docs (if any were added on this branch)
From the file list above, identify any files matching:
- `docs/plans/*`
- `docs/brainstorms/*`
- `docs/solutions/*`

Read the full contents of each.

### Steering and convention changes
From the file list, identify any changes to:
- `.claude/steering/*`
- `docs/conventions/*`

For each, run:
```bash
git diff ${BASE}..HEAD -- <file>
```

### PR info (if one exists)
```bash
gh pr view --json title,body,url,number 2>/dev/null
```

### Key diffs for code analysis
For files that are new or significantly changed (not test files, not generated),
read the actual code to identify interesting patterns worth highlighting:
```bash
git diff ${BASE}..HEAD -- <file>
```

Read enough diffs to have a solid understanding of the code changes — at minimum
the non-test source files. This is essential for generating the "Worth knowing"
and code sample content.

## Step 3: Synthesize content

Read the template at `.claude/skills/what-did-i-just-do/template.html`.

For each `<!-- SLOT:name -->` placeholder, generate HTML content that replaces it.
Do NOT modify the template structure, CSS, or JS. Only replace the slot comments
with content HTML.

### SLOT:title
The branch name, humanized. e.g. `ls-3449-migrate-card-movement-apis` becomes
"Migrate Card Movement APIs".

### SLOT:header_pills
One `<span class="pill">` per metadata item:
- Base branch
- PR link (if exists): `<span class="pill"><a href="URL">#NUMBER</a></span>`
- Date range (first commit → last commit)
- Commit count

### SLOT:narrative
2-4 sentences in `<p>` tags. What this branch accomplished and why. Written for
a human who wasn't involved. Lead with the problem or motivation, not the
solution.

### SLOT:decisions
One `<div class="decision-card">` per key decision. Include:
- `<h3>` — what was decided
- `<p>` — why, with context
- `<div class="alt">` — what the alternative was (if relevant)
- Code samples in `<pre class="code-block">` when the decision manifests in code
- File paths with line numbers as `<span class="file-path" data-path="relative/path:LINE"><span class="copy-label">relative/path:LINE</span> <svg class="copy-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1"/></svg></span>`
  When referencing code, look up the line number in the current file on HEAD (not the diff line number) and include it after a colon, e.g. `cardService.ts:198`. Both the `data-path` attribute and the visible label include the line number (VS Code navigates to the line when you open `path:line`).

If there are no meaningful decisions, include one card saying so.

### SLOT:learnings
Mix these formats to keep it varied — do NOT use the same format for consecutive items:

**Quote-style** (for concise insights):
```html
<div class="learning-quote">Insight text here.</div>
```

**Insight card** (for learnings that need explanation):
```html
<div class="learning-insight">
  <h3>Title</h3>
  <p>Explanation...</p>
  <!-- optional code block or file path -->
</div>
```

**Before/after comparison** (for code pattern learnings):
```html
<div class="learning-comparison">
  <div class="before"><div class="label">Before</div><pre>...</pre></div>
  <div class="after"><div class="label">After</div><pre>...</pre></div>
</div>
```

Each learning should include a copyable file path with line number (e.g. `cardService.ts:198`) if it relates to specific code.

### SLOT:timeline
Group commits into logical phases of work (3-6 phases). For each:
```html
<div class="timeline-phase">
  <h3>Phase label</h3>
  <ul class="timeline-commits">
    <li><span class="hash">abc1234</span> commit message</li>
  </ul>
</div>
```

### SLOT:files
Group changed files by top-level area (e.g., `apps/api`, `apps/web`, `packages/core`).
For each group:
```html
<div class="file-group">
  <h3>apps/api</h3>
  <div class="count">5 files changed</div>
</div>
```

### SLOT:discoveries
Interesting code patterns, architecture details, or techniques from the branch
that are worth understanding — even if they weren't a "decision" or "learning."

Look for:
- Clever or non-obvious use of a library/framework API
- Architectural boundaries or ownership patterns
- Patterns worth replicating elsewhere
- Gotchas that are easy to miss
- Interesting test patterns

For each:
```html
<div class="discovery">
  <h3>Title</h3>
  <p>Why this is worth knowing...</p>
  <pre class="code-block">code sample</pre>
  <span class="file-path" data-path="relative/path"><span class="copy-label">relative/path:LINE</span> ...</span>
</div>
```

If nothing stands out, use `<p class="empty">No notable discoveries on this branch.</p>`.

### SLOT:conventions
If `.claude/steering/` or `docs/conventions/` files were modified, show each as:
```html
<div class="convention-diff">
  <div class="convention-diff-header">path/to/file</div>
  <pre><span class="diff-add">+ added line</span>
<span class="diff-remove">- removed line</span>
 context line</pre>
</div>
```

If none, use `<p class="empty">No convention changes on this branch.</p>`.

### SLOT:stats
```html
<div class="stats-bar">
  <div class="stat"><div class="stat-value">N</div><div class="stat-label">Files</div></div>
  <div class="stat-divider"></div>
  <div class="stat"><div class="stat-value green">+N</div><div class="stat-label">Additions</div></div>
  <div class="stat-divider"></div>
  <div class="stat"><div class="stat-value red">-N</div><div class="stat-label">Deletions</div></div>
</div>
```

## Step 4: Write and open

Write the filled template to `/tmp/branch-recap-${BRANCH}.html`, then:

```bash
open /tmp/branch-recap-${BRANCH}.html
```

## Rules

- Do NOT modify the template's CSS, JS, or structure — only replace slot comments.
- Do NOT include raw error messages or stack traces — summarize for humans.
- Do NOT write walls of text. Each prose block should be 1-4 sentences max.
- Do NOT use the same visual format for consecutive items in any section.
- Every code reference MUST include a copyable file path with a line number (e.g. `path/to/file.ts:42`). Look up the line number in the current file on HEAD, not the diff hunk number. Both `data-path` and the visible `.copy-label` text include the line number — VS Code opens the file at that line when you use the `path:line` format.
- HTML-escape any code content that contains `<`, `>`, or `&`.
- If a section has no content, use the `<p class="empty">` pattern rather than omitting it.
- Keep the page scannable. Prefer structured content over paragraphs.
