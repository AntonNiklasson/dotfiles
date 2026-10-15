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
3. Otherwise → list hosts from `gh auth status` and ask which one. Don't guess.

Scope is all of Anton's open PRs on that host, grouped by repo. If an argument names a repo, filter to it.

## 2. Fetch

One GraphQL call gets everything (PR meta, review decision, merge state, CI rollup, review threads, recent comments):

```sh
gh api graphql --hostname <host> -F query=@~/.claude/skills/pr-dashboard/open-prs.graphql
```

Pipe through `jq` to keep context small. Ignore comments authored by Anton and by noise bots (deploy previews, coverage, changesets, linear linkbacks). Keep review bots (e.g. CodeRabbit, Copilot) — their comments can be real.

## 3. Classify each PR

Drafts go in a compact separate section — status only, no actions unless CI is red.

For non-drafts, bucket by first match:

| Bucket | Signal | Suggested action |
|---|---|---|
| 🔴 CI failing | rollup `FAILURE`/`ERROR` | name failing checks; one-line likely cause |
| 💬 Comments | unresolved, non-outdated threads or unanswered top-level comments from others | per-comment act/skip (below) |
| 🔀 Conflicts | `mergeStateStatus: DIRTY` | trivial → offer to resolve; complex → loop Anton in (below) |
| ✅ Ready | `reviewDecision: APPROVED`, CI green, `CLEAN`/`UNSTABLE` mergeable | suggest merge (stacked: merge bottom first) |
| 👀 Needs review | `REVIEW_REQUIRED` / no approval, CI green | Slack message (below) |
| ⏳ Waiting | CI pending, or `CHANGES_REQUESTED` already addressed | note who/what it waits on |

A PR can show secondary flags (e.g. comments + conflicts) but lives in one bucket.

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

Tight, scannable, one line per PR where possible:

```
## <host> — N open (M drafts)

🔴 CI failing
- repo#123 Title — `lint`, `test-unit` fail; looks like snapshot drift → fix
💬 Comments
- repo#124 Title — 2 unresolved
  - @alice api.ts:42 "null check missing" → Act: real bug
  - @bob ui.tsx:10 "rename var?" → Skip: nit
✅ Ready to merge
- repo#125 Title — approved by @carol, CI green
👀 Needs review
- repo#126 Title — 3d old, no reviewers requested
⏳ Waiting / 🔀 Conflicts / Drafts …

Slack (copied):
<rr lines>
```

Omit empty sections. End with a numbered list of proposed actions (merge X, rebase Y, re-run Z) for Anton to pick from; execute only the ones he approves.
