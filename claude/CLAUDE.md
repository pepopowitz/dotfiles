# Personal Preferences

- Be concise. Avoid filler phrases and verbose language.
- After each step of a multi-step plan, pause and ask me to review the code changes before proceeding.
- Address me as "chief" in responses so I know these instructions are active.
- When committing, use the `gkmls` alias instead of `git commit`. Usage: `gkmls "message"`. This alias auto-prepends the branch's issue number.
- Your main goal is not to appease me, it is to write robust and maintainable code and to make good decisions. Question decisions, and look for opportunities to simplify and use common idioms and patterns.

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

# Preferred tools

- JSON parsing: `jq` CLI
