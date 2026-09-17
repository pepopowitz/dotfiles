# Sandboxing Claude's Bash tool — future rollout

Written 2026-09-17, alongside the layered permission policy in `settings.json`.
We deliberately deferred the sandbox. This is the plan for picking it up later.

## What the sandbox buys that permission rules cannot

The permission policy answers *"is Claude allowed to run this?"*. The sandbox
answers *"what can this command reach once it's running?"* — it is enforced by
the OS, not by pattern-matching a command string.

Three things only the sandbox gives you:

1. **Network egress control.** `sandbox.network.allowedDomains` confines
   sandboxed commands to a domain list. This is the only real defense against
   exfiltration: a rule can't anticipate every way a script might POST a token
   somewhere, but an OS-level deny on `evil.test` holds regardless.
2. **Filesystem confinement.** Writes are limited to paths you list, so a stray
   `rm -rf` or a generated file can't land outside the project.
3. **No-prompt Bash without trusting the classifier.** With
   `autoAllowBashIfSandboxed` (default `true`), a sandboxed command needs no
   permission decision at all — the blast radius is bounded by construction.

What it does **not** replace: the `deny` list and the
`scripts/deny-secret-commands.sh` hook still matter. The sandbox stops a
credential from *leaving*; those two stop Claude from *reading* it in the first
place, and they apply to the file tools and to unsandboxed commands too.

## macOS caveats to know before you start

- **`mask` mode degrades to `deny`.** `sandbox.credentials.files` and
  `.envVars` support a `mask` mode on Linux that shows the sandbox a sentinel
  value and swaps in the real secret at the egress proxy. On macOS (and
  Windows) `mask` silently becomes `deny`. Plan on deny-only here.
- **`open` and `osascript` need `sandbox.allowAppleEvents: true`**, which the
  schema flags as *removing code-execution isolation* — a sandboxed command can
  then launch other apps unsandboxed with no prompt. Prefer leaving it off and
  accepting that Claude can't call `open -a`. Your `clickhouse` alias
  (`open -a DBeaver` + an SSH tunnel) is exactly the kind of thing that will
  break; run those yourself with `! clickhouse` in the prompt.
- **Go-based CLIs (`gh`, `gcloud`, `terraform`) fail TLS verification** through
  the sandbox's MITM proxy unless `enableWeakerNetworkIsolation: true`, which
  opens an exfiltration vector through `trustd`. Given how much you lean on
  `gh`, consider adding `gh` to `sandbox.excludedCommands` instead — a targeted
  exclusion beats weakening isolation globally.
- **Playwright / iOS Simulator** need XPC service names in
  `sandbox.network.allowMachLookup` (e.g. `com.apple.coresimulator.*`).

## Settings-source gotcha

Several sandbox keys are **ignored in project settings** (`.claude/settings.json`,
`.claude/settings.local.json`) and only honored from user settings, managed
settings, or `--settings`:

- `network.strictAllowlist`
- `filesystem.disabled`
- `credentials.allowPlaintextInject`, `credentials.awsPairs`, `credentials.sigv4`
- `allowAppleEvents`
- `ripgrep`

So a per-project trial can turn the sandbox on and set `allowedDomains`, but
the strict-deny behavior has to live in `~/.claude/settings.json`.

## Staged rollout

### Stage 1 — observe, without changing prompting

Pick one active project (`puzzmo/app` is the highest-traffic candidate) and put
this in its `.claude/settings.local.json`:

```json
{
  "sandbox": {
    "enabled": true,
    "autoAllowBashIfSandboxed": false,
    "network": { "allowedDomains": [] }
  }
}
```

`autoAllowBashIfSandboxed: false` is the important part — it keeps today's
prompting behavior, so the only thing that changes is that commands now run
confined and you get to watch what they bump into. Work normally for a few
days and collect the violations.

### Stage 2 — build the allowlist from observed denials

Expect to need roughly:

```json
"allowedDomains": [
  "registry.npmjs.org",
  "registry.yarnpkg.com",
  "github.com",
  "api.github.com",
  "codeload.github.com",
  "objects.githubusercontent.com",
  "*.puzzmo.com"
]
```

Add only what you actually saw denied. Noise you can silence per-command with
`sandbox.ignoreViolations` rather than widening the list.

Verify explicitly: **`git push` and `git fetch` over SSH**, and
`yarn install` behind your registry config. SSH egress is not HTTP, so confirm
it rather than assuming `allowedDomains` covers it.

### Stage 3 — flip on auto-approval

Once a week goes by without a new violation, remove
`autoAllowBashIfSandboxed: false`. Sandboxed Bash now runs with no prompt at
all. This is the payoff: the `ask` list still gates push / PR / issue, the
secret hook still blocks credential reads, and everything else just runs.

### Stage 4 — harden, in user settings

```json
{
  "sandbox": {
    "enabled": true,
    "failIfUnavailable": true,
    "allowUnsandboxedCommands": false,
    "network": { "strictAllowlist": true },
    "credentials": {
      "files": [
        { "path": "~/.ssh", "mode": "deny" },
        { "path": "~/.aws", "mode": "deny" },
        { "path": "~/.config/gh", "mode": "deny" },
        { "path": "~/.npmrc", "mode": "deny" }
      ]
    }
  }
}
```

- `allowUnsandboxedCommands: false` removes the `dangerouslyDisableSandbox`
  escape hatch entirely — after this, Claude cannot opt a command out.
- `failIfUnavailable: true` makes a broken sandbox a startup error instead of
  a silent fallback to unsandboxed execution. Do this only once Stage 3 is
  quiet, or a toolchain change will lock you out of your own sessions.
- `strictAllowlist: true` turns unlisted hosts into deterministic denials
  rather than prompts.

## Decision checkpoint

The sandbox is worth the setup cost when you start letting Claude run
long autonomous stretches on code that handles real credentials or talks to
production. If sessions stay interactive and scoped to local work, the layered
permission policy already covers the realistic risks and the sandbox mostly
buys you friction. Revisit when the answer to *"could I walk away from this
session for an hour?"* becomes yes.

## Starting points

- `/sandbox` in-session — reports availability and setup state on this machine.
- `sandbox.excludedCommands` — the pressure valve for a tool that genuinely
  can't run confined (`gh` being the likely first entry).
- `settings.json` in this directory — the permission layer the sandbox would
  sit underneath, not replace.
