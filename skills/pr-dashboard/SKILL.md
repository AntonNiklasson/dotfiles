---
name: pr-dashboard
description: Overview of Anton's open PRs on a GitHub host — failing CI, unresolved comments (with act/skip suggestions), merge-ready PRs, and Slack review-request messages for PRs needing approval. Use when Anton asks about the state of his PRs.
user-invocable: true
argument-hint: "[host] [repo filter]"
---

# PR dashboard

Give Anton a fast triage of his open PRs and a concrete next action for each. Read-only by default: never merge, comment, re-run CI, or request reviewers without his explicit go-ahead.

## 1. Pick the host

Resolve in order:

1. Host passed as argument → use it.
2. cwd is a git repo → host from `git remote get-url origin` (e.g. `ghe.megaleo.com` for GitHub Enterprise, `github.com` otherwise).
3. Otherwise → list instances (`ghd list --json | jq -r '.instances[].id'`) and ask which one. Don't guess.

Map host → ghd instance id by swapping `.` for `-` (`ghe.megaleo.com` → `ghe-megaleo-com`). Scope is all of Anton's open PRs on that instance, grouped by repo. If an argument names a repo, filter to it.

## 2. Fetch

Primary source is Anton's github-dashboard (`ghd`, repo `~/code/github-dashboard`) — same data he sees in the TUI. Sync once and read JSON, dropping heavy fields:

```sh
ghd once --json --kind prs --instance <id> | jq '.instances[].prs[] | del(.body, .authorAvatar)'
```

Exit code 2 = a fetch failed; fall back to `ghd list --json` (cache only) and say the data may be stale.

Per PR this gives `draft`, `ciStatus`, `reviewDecision`, `reviews.{approved,changesRequested}`, `unresolvedThreadCount`, `commentCount`, `mergeable`, `mergeStateStatus`, `autoMerge`, `inMergeQueue`, branches, `+/-`. Classify from that alone. ghd groups stacks by base/head branch — use the same logic to order stacked PRs.

Drill down with `gh` only for PRs that need detail (always with `GH_HOST=<host>` or the full PR URL):

- Failing checks: `gh pr checks <url> --json name,state,link | jq '.[] | select(.state=="FAILURE")'` — ghd only has the rollup.
- Requested reviewers: `gh pr view <url> --json reviewRequests`.
- Unresolved threads: `gh api graphql` on `pullRequest.reviewThreads` (filter `isResolved: false`, `isOutdated: false`) for PRs with `unresolvedThreadCount > 0`; `gh pr view <url> --comments` for top-level comments.

Ignore comments authored by Anton and by noise bots (deploy previews, coverage, changesets, linear linkbacks). Keep review bots (e.g. CodeRabbit, Copilot) — their comments can be real.

ghd stays a lean overview by design — the skill owns the detail. Decide per PR what's worth drilling into; don't suggest extending ghd.

## 3. Classify each PR

Drafts go in a compact separate section — status only, no actions unless CI is red.

For non-drafts, bucket by first match:

| Bucket | Signal | Suggested action |
|---|---|---|
| 🔴 CI failing | `ciStatus: failure` | name failing checks; one-line likely cause |
| 💬 Comments | `unresolvedThreadCount > 0`, or unanswered top-level comments from others | per-comment act/skip (below) |
| 🔀 Conflicts | `mergeStateStatus: DIRTY` | trivial → offer to resolve; complex → loop Anton in (below) |
| ✅ Ready | `reviewDecision: APPROVED`, `ciStatus: success`, `mergeStateStatus` `CLEAN`/`UNSTABLE` | suggest merge (stacked: merge bottom first); if `autoMergeAllowed`, enabling auto-merge is an option |
| 👀 Needs review | `reviewDecision: REVIEW_REQUIRED` / empty `reviews.approved`, CI green | Slack message (below) |
| ⏳ Waiting | `ciStatus: pending`, `autoMerge`/`inMergeQueue` set, or `CHANGES_REQUESTED` already addressed | note who/what it waits on |

A PR can show secondary flags (e.g. comments + conflicts) but lives in one bucket. `BEHIND` (not conflicting) → just note "update branch".

When an action exists in the ghd TUI (approve, toggle draft, toggle auto-merge — `.` action menu), mention it as an alternative so Anton can do it from there.

### CI failures

List failed check names with links. For GitHub Actions failures, a quick `gh run view <id> --log-failed | tail -50` is fine to guess the cause; if several PRs fail, fan out to sub-agents rather than pulling logs into main context. Flag flaky-looking failures (unrelated to the diff, infra/timeouts) as "probably re-run".

### Conflicts

For each `DIRTY` PR, say which base it conflicts with and size it up: dry-run the merge locally (`git fetch` then `git merge-tree --write-tree origin/<base> origin/<head>`) to list conflicting files. Label it:

- **Trivial** — lockfiles, generated files, imports, small non-overlapping hunks → offer to resolve it (rebase onto base, resolve, run relevant checks, show the result before force-pushing).
- **Complex** — overlapping logic changes, many files, or anything where intent is ambiguous → don't offer to auto-resolve; summarise what clashes (which files, which incoming change) and loop Anton in.

Never force-push without approval. Don't touch the cwd's working tree if it's dirty; use a temporary worktree only with Anton's approval.

### Comment triage

For each unresolved comment give: who, file:line, one-line gist, verdict **Act** / **Skip** / **Reply**, and a short why. Base the verdict on the comment plus the relevant diff hunk (`gh pr diff`); for PRs with many threads, delegate to a sub-agent and get back only the verdicts. Be opinionated — Skip nits and out-of-scope asks, Act on bugs and correctness, Reply when it's a question.

### Review-request messages

For each PR needing review, run Anton's `rr` script with the PR URL — it prints the Slack-formatted line:

```sh
rr <pr-url> | tail -1
```

It overwrites the clipboard each call, so after collecting all lines, `pbcopy` the combined block. Present the lines in a code block. If `rr` fails, fall back to its format: `` [<title without ticket ids>](<url>) `+<add>/-<del>` `` plus ` → <base>` when base isn't `main`.

## 4. Output

Two parts: a short status overview, then **one numbered action list at the very end**. Anton replies to the list like open questions ("1 go, 2 no, 3 go" or "go 1 3"), so the list is the point — everything above it is context.

### Overview

One line per PR, ordered by bucket (table order). Emoji + `repo#N` + short title + status in a few words. No numbers here, no explanations longer than a clause. Group drafts into a single compact line or two at the bottom of the overview. Stacks: `#7294→#7297`.

### Actions

A single numbered list, last thing in the response. Each item:

- Stands alone: starts with `#N` and says exactly what will happen, e.g. `#5975: rebase onto next, force-push (no conflicts)`.
- Is one line. Put the why in a short trailing clause only if it changes the decision.
- Is one decision. Dependencies stated inline (`after 1`), not as separate steps.
- Folds questions in as decisions: `#6259: close as superseded by #6628?` rather than a separate questions section.
- Marks items needing Anton's input beyond go/no-go with "→ you: <question>".

Skipped review comments don't get numbers; mention them in the overview line ("1 nit skipped"). Slack `rr` lines go in a code block right before the action list (copied to clipboard); a "ping for review" action means "send these", it isn't something the agent does.

```
**ghe.megaleo.com** — 18 open, 12 drafts

🔴 sana-ai#5975 Delete CLAUDE.md stubs — CI red (stale base after retarget), approved, auto-merge on
🔀 sana-ai#7262 test:integration for React — trivial conflict w/ next, no approval
💬 sana-ai#5711 upgrade pnpm 12.7.0 — 1 thread, conflict w/ next, no approval
✅ sana-ai#7258 Fail CI on CLAUDE.md — approved, green, stacked on #5975
⏳ sana-ai#7282, #7229 — in merge queue
Drafts: #7294→#7297 conflicts · #6259, #6628 conflicts · #7171 conflicts · #6907 1 thread · #6065, manifests#978→980 clean

Slack (copied):
<rr lines>

1. #5975: rebase onto next, force-push — fresh CI, auto-merge lands it
2. #7258: rebase onto #5975 after 1, force-push
3. #7262: rebase onto next keeping your deletion, run test, show before force-push
4. #5711: reply to @viktor "covered in docs/pnpm-12-upgrade.md", resolve thread
5. #5711: retarget to next, resolve package.json conflict → you: is main still valid?
6. Send Slack pings for #7262, #5711 (after 3, 5)
7. #6259: close as superseded by #6628?
```

Every open PR appears in the overview exactly once. PRs with nothing to do get no action.

## 5. Go/no-go

Anything not given a go is a no-go — never assume. Accept any shorthand ("go all", "all but 2", "1 go 2 no").

Execute go'd actions one at a time in list order (respecting dependencies), one-line result each. Stop and ask if an action turns out bigger than described. The action line spells out what happens, so the go *is* the approval for outward-facing steps (merge, force-push, comment) — don't re-confirm.
