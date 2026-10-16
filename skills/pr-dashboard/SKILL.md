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

It overwrites the clipboard each call, so after collecting all lines, `pbcopy` the combined block. Present the lines in a code block. If `rr` fails, fall back to its format: `` [<title without ticket ids>](<url>) `+<add>/-<del>` ``.

## 4. Output

Two numbered lists that share numbering: the **PR list** (every open PR, numbered 1…N) and the **action list** at the very end, where each action carries its PR's number. Reading action `2b`, Anton glances up to PR `2`. He replies like to open questions ("1 go, 2a no, 2b go" or "go 1 3a"), so the action list is the point — everything above it is context.

### PR list

- Number every open PR, drafts included, in bucket order (table order); drafts last.
- Each entry: `N. <emoji> repo#123 Short title — status in a few words`. At most 2 short sub-bullets for context that matters to the decision (cause of CI failure, what conflicts). No paragraphs.
- Drafts: one line each, no sub-bullets. Stacks: one entry per PR, note `stacked on #N`.

### Actions

- Numbered by PR: `N` if the PR has one action, `Na`, `Nb` … if several. Gaps are fine — PRs with nothing to do have no action. Keep PR order.
- Each item is one line and says exactly what will happen, e.g. `2. rebase onto next, force-push (no conflicts)`. Prefix with `#123` for readability.
- One decision per item. Dependencies inline (`after 2a`).
- Fold questions in as decisions: `9. close as superseded by #6628?` — no separate questions section.
- Items needing input beyond go/no-go get "→ you: <question>".
- Cross-PR actions (e.g. sending Slack pings for several PRs) go last, numbered `S` (or `X1`, `X2` …) so they don't collide with PR numbers.

Skipped review comments get no action; mention them in the PR's line ("1 nit skipped"). Slack `rr` lines go in a code block right before the action list (copied to clipboard); "send pings" means Anton sends them — the agent doesn't.

```
**ghe.megaleo.com** — 17 open, 12 drafts

1. ✅ sana-ai#7229 [8/8] Ban per-test logger mocks — approved, green, clean
2. 🔴 sana-ai#5975 Delete CLAUDE.md stubs — CI red, approved, auto-merge on, trivial conflict w/ next
   - CI: "Check Migration Order" ran against main before retarget; stale
   - Conflict: 1 line in review-help/SKILL.md, keep both
3. 🔀 sana-ai#7262 test:integration for React — no approval, trivial conflict w/ next
4. 💬 sana-ai#5711 upgrade pnpm 12.7.0 — 1 thread, no approval, base main
5. ⏳ sana-ai#7258 Fail CI on CLAUDE.md — approved, green, stacked on #5975
6. 📝 sana-ai#7294 vi.mock 1/4 — draft, conflicts w/ #7229's branch
7. 📝 sana-ai#6259 hot-reload — draft, conflicts, 1 thread
8. 📝 sana-ai#6628 hot-reload v2 — draft, conflicts, 1 thread
…

Slack (copied):
<rr lines>

1.  #7229: merge
2.  #5975: rebase onto next, keep both SKILL.md edits, force-push — fresh CI, auto-merge lands it
3.  #7262: rebase onto next keeping the deletion, run test:integration, show before force-push
4a. #5711: reply to @viktor "covered in docs/pnpm-12-upgrade.md", resolve thread
4b. #5711: retarget to next, resolve package.json conflict → you: was main intentional?
5.  #7258: enable auto-merge after 2
6.  #7294: rebase after 1, cascade up through #7297
7.  #6259: close as superseded by #6628? → you: #6259 has an approval
S.  Send Slack pings for #7262, #5711 (after 3, 4b)
```

## 5. Go/no-go

Anything not given a go is a no-go — never assume. Accept any shorthand ("go all", "all but 2", "1 go 4a no", "go 4" = all of 4a, 4b …).

Execute go'd actions one at a time in list order (respecting dependencies), one-line result each. Stop and ask if an action turns out bigger than described. The action line spells out what happens, so the go *is* the approval for outward-facing steps (merge, force-push, comment) — don't re-confirm.
