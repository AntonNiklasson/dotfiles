---
name: pr-shepherd
description: Daily tech-lead pass over Anton's open PRs in the current repo. Collect status, start one sub-agent per PR that needs mundane work (rebase, conflicts, formatting, failed CI), and print Slack review-request lines for every PR that is ready for review. Use only when Anton invokes it (`/pr-shepherd`).
user-invocable: true
argument-hint: "[#PR ...] (default: all open PRs)"
---

# PR shepherd

You are the tech lead. Sub-agents do the mundane work. Anton does reviews, replies, and Slack messages.

## 1. Collect

Run in the repo root:

```sh
gh pr list --author @me --state open --json number,title,url,isDraft,reviewDecision,mergeable,baseRefName,headRefName,statusCheckRollup,updatedAt
```

For each PR, also get the unresolved review threads (`gh api graphql`, `reviewThreads(isResolved)`). If arguments name PRs, limit the pass to those PRs.

## 2. Classify

Put each PR in one bucket:

| Bucket | Rule |
|---|---|
| `ready` | Not draft. `mergeable == MERGEABLE`. All checks pass (pending checks OK if only slow non-required ones). No unresolved threads. Not approved yet. |
| `approved` | `reviewDecision == APPROVED`, checks green. Anton merges. |
| `fix` | Not draft, and one or more mundane blocker: conflict, base behind and stack parent merged, failed format/lint/type/test check, failed title check. |
| `human` | Unresolved review threads, or failure that needs a product/logic decision. |
| `draft` | Draft. Report only. Do not touch. |
| `stale` | Prototype or superseded PR. Suggest close. Do not close. |

Stacks: treat a stack (`(1/3)`, `(2/3)` in title, or base branch = other PR head) as one unit. Fix from the bottom up.

## 3. Delegate `fix` PRs

Start one `Agent` per `fix` unit, all in one message so they run in parallel. Use `isolation: "worktree"`, `run_in_background: false`. Brief each child with:

- PR number(s), URL, branch, base, and the exact failing check names and their log excerpt (`gh run view --log-failed`).
- Scope: mundane fixes only. Rebase on base, resolve conflicts, `pnpm i`, `pnpm format`, fix lint/type/test failures caused by drift. Run `pnpm --filter <pkg> test` for packages touched.
- If a fix needs a logic or product decision: stop and report. Do not guess.
- Commit locally with focused commits. **Do not push.** Do not edit PR title/body. Do not comment on GitHub. Do not watch PRs.
- Final report: worktree path, branch, commits (`git log --oneline base..HEAD`), diff stat, test result, and open questions.

## 4. Report to Anton

Use the "Frontload context" rule: a sorted reference list first. Then one section per bucket, one line per PR, with a reason.

For `fix` PRs: show each child's commits and diff stat. Ask: "Push these? (all / list / none)". After Anton approves, push from each worktree with `git push --force-with-lease`. For a stack, push bottom up. Do not push without approval.

## 5. Slack lines for `ready` PRs

For each `ready` PR (including PRs that became ready after the push and their checks went green), run:

```sh
review-request <url>
```

Take all output lines after the first (the message: title line plus diff line). Print all lines as one block that Anton can paste into Slack:

```
[AI-19935: Require DB migrations to merge in their own PR](https://...)
+120/−4 · 2 commits · 4 files changed
```

The tool also copies to the clipboard, so the last PR overwrites the clipboard. The printed block is the source of truth.

## Rules

- Never mark ready, merge, close, or reply to reviews. Anton does that.
- Never push without approval for this run.
- After a push, `watch_pull_request` the PRs whose checks you wait on. `unwatch_pull_request` before handback.
- Keep the report short. No logs unless a child stopped on a question.
