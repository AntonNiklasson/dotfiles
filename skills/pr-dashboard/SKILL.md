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

One block per PR, ordered by bucket (table order), then by age. Each block: status line, then the suggested actions for that PR. Number actions globally (1, 2, 3 … across all PRs) so Anton can reply "do 1, 4, 7".

```
## <host> — N open (M drafts)

🔴 repo#123 Title — CI failing (`lint`, `test-unit`); 1 comment
  1. Fix snapshot drift in `test-unit` — looks related to the diff
  2. Re-run `lint` — timeout, looks flaky
  3. Act on @alice api.ts:42 "null check missing" — real bug

🔀 repo#124 Title — conflicts with main (trivial: pnpm-lock.yaml)
  4. Rebase + resolve, show result before force-push

✅ repo#125 Title — approved by @carol, CI green
  5. Merge (bottom of stack, merge before #126)

👀 repo#126 Title — no approval, 3d old, no reviewers requested
  6. Ping for review — `[Title](url) \`+120/-30\``

💬 repo#127 Title — 2 unresolved
  7. Reply to @bob "why not X?" — suggest: <one-line answer>
  –  Skip @bob ui.tsx:10 "rename var?" — nit

⏳ repo#128 Title — CI pending — no action

Drafts: repo#129 (CI green), repo#130 (CI red → 8. check `build`)

Slack review requests (copied):
<rr lines>
```

Rules:

- Actions are concrete and executable by the agent or by Anton (fix, re-run, rebase, merge, reply, ping, close if stale). Skipped comments get `–` instead of a number, with a reason.
- Mark actions needing Anton's judgment (complex conflicts, debatable review comments) with "→ you".
- PRs with nothing to do get one line, no actions.
- Omit nothing silently: every open PR appears once.

Execute only the actions Anton picks.
