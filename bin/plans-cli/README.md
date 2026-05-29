# plans

A CLI for managing plan and brainstorm documents outside the repo. Documents live in `~/.claude/projects/<slug>/{plans,brainstorms}/` so they never appear in `git status`, and can be copied into the repo when needed.

## Setup

The `bin/plans` wrapper delegates to `bin/plans-cli/plans`. rcm symlinks `~/bin/plans` into PATH automatically via `rcup`.

Requires [ripgrep](https://github.com/BurntSushi/ripgrep) (`rg`) for tag search.

## Commands

### List what's in external storage

```
plans                              # list all active plans & brainstorms
plans --plans                      # only plans
plans --brainstorms                # only brainstorms
plans tagged <tag>                 # find docs by tag
plans tags                         # list all non-ticket tags
```

### Copy plans into the repo for implementation

```
plans in <tag|file>                # copy docs into docs/plans/ or docs/brainstorms/
```

`in` accepts a filename or a tag. Filename is tried first; if no file matches, it falls back to tag search.

### Move plans back out when done

```
plans out <tag|file>               # move docs from the repo back to external storage
plans out --all                    # move all untracked docs back
```

`out` also accepts a filename or tag, same as `in`.

### Edit plans without copying them in

```
plans path <file>                  # print full path (composable with any tool)
plans edit <file>                  # open in VS Code
plans dir                          # print external storage root for this project
```

### Lifecycle management

```
plans keep <file>                  # protect from date-based cleanup
plans unkeep <file>                # remove protection

plans archive <file>               # hide from list
plans archive --older-than <days>  # archive all active docs older than N days
plans archived                     # list archived docs
plans unarchive <file>             # restore to active

plans delete <file>                # permanently delete (must be archived first)
plans delete --older-than <days>   # delete archived docs older than N days
```

`delete` refuses non-archived docs. Archive first, then delete.

`--older-than` parses the date from the filename (`p-YYYY-MM-DD-...`), not filesystem mtime, since `in`/`out` changes mtime.

Docs with a `keep` tag are skipped by `archive --older-than` and `delete --older-than`. Frontmatter-modifying commands (`keep`, `unkeep`, `archive`, `unarchive`) update both the external copy and the repo copy if both exist.

## Frontmatter convention

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

The `status` field is managed by `archive`/`unarchive`. The date in the filename is used by `--older-than`.

## Tests

Requires [bats-core](https://github.com/bats-core/bats-core):

```
brew install bats-core
bats bin/plans-cli/plans.bats
```

Tests use the `PLANS_PROJECT_DIR` env var to override the storage directory with a temp dir, so they never touch real data.
