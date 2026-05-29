# plans

A CLI for managing plan and brainstorm documents outside the repo. Documents live in `~/.claude/projects/<slug>/{plans,brainstorms}/` so they never appear in `git status`, and can be copied into the repo when needed.

## Setup

The `bin/plans` wrapper delegates to `bin/plans-cli/plans`. rcm symlinks `~/bin/plans` into PATH automatically via `rcup`.

Requires [ripgrep](https://github.com/BurntSushi/ripgrep) (`rg`) for tag search.

## Commands

### Listing

```
plans                              # list all active plans and brainstorms
plans list                         # same as above
plans list --plans                 # only plans
plans list --brainstorms           # only brainstorms
plans tagged <tag>                 # list docs matching a tag
plans tags                         # list all tags (excluding ls-* tickets)
plans archived                     # list archived docs
```

### Moving in/out of the repo

```
plans in <tag|file>                # copy docs into docs/plans/ or docs/brainstorms/
plans out <tag|file>               # move docs from the repo back to external storage
plans out --all                    # move all untracked docs back to external storage
```

`in` and `out` accept either a filename or a tag. Filename is tried first; if no file matches, it falls back to tag search.

### Inspection & editing

```
plans path <file>                  # print the full external path to a doc
plans edit <file>                  # open a doc in VS Code
plans dir                          # print the external storage root for this project
```

### Archiving & deletion

```
plans archive <file>               # archive a single doc (hides from list)
plans archive --older-than <days>  # archive all active docs older than N days
plans unarchive <file>             # restore an archived doc to active

plans delete <file>                # permanently delete an archived doc
plans delete --older-than <days>   # delete all archived docs older than N days
```

`delete` refuses to delete non-archived docs. Archive first, then delete.

### Keep protection

```
plans keep <file>                  # add keep tag (protects from --older-than)
plans unkeep <file>                # remove keep tag
```

Docs with a `keep` tag in their frontmatter are skipped by `archive --older-than` and `delete --older-than`.

## Frontmatter convention

All docs should include YAML frontmatter with `tags`:

```yaml
---
title: 'Fix chat sidebar state'
type: fix
status: draft
date: 2026-05-14
tags: ls-3483, chat, sidebar
---
```

- **Linear ticket**: `ls-XXXX`
- **Feature area**: `chat`, `sidebar`, `pricing`, etc.
- **Protection**: `keep` (prevents date-based archiving/deletion)

The `status` field is managed by `archive`/`unarchive` commands. The date in the filename (`p-YYYY-MM-DD-...`) is used by `--older-than`.

## Tests

Requires [bats-core](https://github.com/bats-core/bats-core):

```
brew install bats-core
bats bin/plans-cli/plans.bats
```

Tests use the `PLANS_PROJECT_DIR` env var to override the storage directory with a temp dir, so they never touch real data.
