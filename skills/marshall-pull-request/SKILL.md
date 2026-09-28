---
name: marshall-pull-request
description: Marshall Anton's open PRs across all authenticated GitHub hosts — surface unresolved review comments, CI failures, and merge blockers, and prepare fixes for mechanical problems (e.g. rebase out merge conflicts on his own PRs, pushing only after confirmation). Safe to run unattended on a schedule. Focus on ready-for-review PRs; drafts get one line each.
---

# Marshall pull requests

Keep Anton's open PRs moving: surface unaddressed review comments, CI failures, and whatever else blocks merge — and for mechanical blockers, do the legwork instead of just reporting. Anything requiring judgment (semantic conflicts, replying to reviewers, merging) is reported, never done.

Non-draft PRs are the focus — those are out for review and someone may be waiting on him. Drafts are work in progress; list them briefly only so red CI doesn't go unnoticed.

## Sources

Discover authenticated hosts via `gh auth status` and run every query once per host with `GH_HOST=<host>`. Anton's work and personal code live on different hosts; missing one is the main failure mode. If a host's auth is expired, say which and continue with the others.

## Queries

Per host, find open PRs:

```
GH_HOST=<host> gh search prs --author @me --state open --json number,title,isDraft,repository,url
```

Per non-draft PR:

- **Status + merge readiness:** `gh pr view <n> -R <owner>/<repo> --json isDraft,reviewDecision,mergeable,mergeStateStatus,statusCheckRollup,title,url,headRefName,baseRefName`
  - `statusCheckRollup` may contain stale failed runs from earlier pushes — judge CI by the latest run per check name, not by any-red.
  - `mergeStateStatus: DIRTY` = merge conflicts → candidate for a prepared rebase (below); `BLOCKED` = branch protection (usually missing approval).
- **Unresolved review threads:** GraphQL, count `isResolved: false` and capture author + one-line gist of each:

```
gh api graphql -f query='query { repository(owner:"OWNER", name:"REPO") { pullRequest(number: N) { reviewThreads(first: 50) { nodes { isResolved comments(first: 1) { nodes { author { login } body path } } } } } } }'
```

Per draft PR: just the rollup CI state from the search/view — no thread queries.

Prow-managed repos (e.g. scylla): the `tide` check pending is merge automation waiting on approval/lgtm, not a CI failure.

## Hands-on: prepare a rebase for conflicted PRs

When a non-draft PR authored by Anton is DIRTY, prepare the fix so all that's left for him is a yes/no.

Eligibility — all must hold, otherwise report only:
- PR authored by Anton, non-draft, in a repo he has push access to.
- The head branch is not checked out in the current session's working tree or any existing worktree (`git worktree list`) — never touch a branch a live session may be on.

Flow (in a throwaway worktree, never the main checkout):
1. After `git fetch`, `git -C <main-checkout> worktree add /tmp/marshall-<branch> <headRefName>`. Clean up the worktree when done — success, failure, or declined push.
2. Rebase onto the up-to-date base branch.
3. Classify each conflict:
   - **Mechanical** — lockfiles (regenerate, e.g. `pnpm i` for pnpm-lock.yaml), generated files (regenerate), pure import/adjacent-line collisions where both sides clearly survive. Resolve these.
   - **Semantic** — overlapping logic edits, deleted-vs-modified, anything where the right answer needs intent. Abort the rebase, clean up, report the conflicting files + a one-line gist of what collided.
4. All conflicts mechanical → run the repo's relevant checks on touched packages (in sana-ai: `pnpm format`, then lint/`check-ts` scoped to affected packages). Checks fail → abort and report; don't offer a broken branch.
5. **Ask before pushing.** Present what was resolved and how, then wait for Anton's go-ahead. On yes, push with `--force-with-lease` only — a lease failure means the remote moved; abort and report, never retry with plain force. Unattended (no answer yet) → the pending question in the terminal is the deliverable; don't push.
6. In the report, state exactly what was rebased, which conflicts were resolved and how, and link the PR.

Never: resolve semantic conflicts, touch branches not authored by Anton, merge/close PRs, comment on PRs, resolve review threads, re-run CI jobs, or push without a fresh yes in this conversation.

## Output shape

Lead with what needs action, then the rest. Terse, plain-text URLs.

```
# PR marshall — YYYY-MM-DD HH:MM UTC

## Prepared (awaiting go-ahead)
- repo #NNN title — rebased onto <base>, resolved <files> (mechanical: <how>), checks green. Push?
  <url>

## Needs action
- repo #NNN title — <unresolved comment from <login>: gist / CI red: <check name> / semantic conflict in <files>>
  <url>

## Waiting on others
- repo #NNN title — <approved, ready to merge / review required, CI green>

## Drafts
- repo #NNN title — CI green|red(<check>)
```

- Empty section → drop it. Nothing anywhere → one line: "All quiet — N open PRs, nothing needs action."
- **Delta mode:** if a previous marshall report exists earlier in this conversation (scheduled re-runs), lead with what changed since then (new comments, CI flips, newly mergeable, fixes prepared) and compress unchanged items to one line total. No changes at all → just say so.

## Guardrails

- The only mutation path is the rebase flow above, and its push is confirmation-gated. Everything else is read-only — even if a fix looks obvious, suggest, don't act.
- Don't fabricate: a failed query is reported as a gap, not guessed around.
- When invoked by a scheduled/cron prompt, consider delegating the fan-out queries (and rebase preparation) to a general-purpose subagent to keep the long-running session's context small; the report shape stays the same. The push confirmation always happens in the main conversation, not inside a subagent.
