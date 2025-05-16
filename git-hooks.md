# Git hooks I sometimes use

## Pre-commit hook to remind me that I have files flagged as skip-worktree

```sh
SKIPPED=$(git ls-files -v | grep '^S' | cut -c 3-)
if [ -n "$SKIPPED" ]; then
echo "⚠️  Reminder -- You have skip-worktree files:"
echo "$SKIPPED" | sed 's/^/  /'
echo "To unskip them, run 'git update-index --no-skip-worktree <file>'"
fi
```
