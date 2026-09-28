---
name: review
description: Review a PR's big picture, merge readiness, deploy risk, and rollback. No code edits or GitHub posts.
disable-model-invocation: true
user-invocable: true
argument-hint: <#PR number | PR URL>
---

# Review

Help Anton understand *where this is going* and *what can break when it ships*. Prioritize the big picture and meaningful risks over line-level nits. Choose tools and depth yourself; use project-specific guidance where available.

## First: get the branch checked out

Accept a PR number in the current repo or a PR URL. Ask if no target is given; don't assume the current branch.

Before reviewing, help Anton get the PR branch checked out locally. Identify the source branch and offer to check it out in the existing review worktree; wait for his answer. If already checked out, confirm and continue. If he declines (including in the initial request), skip checkout and proceed with the review remotely.

Preserve local work: no stashing, discarding changes, or forced checkouts. If checkout isn't safe, explain and agree on an alternative before reviewing. Creating a worktree requires approval.

## Boundaries

Review only: don't edit code, rebase, merge, commit, push, or post reviews/comments. Output is for Anton only.

## 0. Merge readiness

**If Anton approves this PR, is it ready to merge?** Check CI, conflicts, review requirements, branch rules, draft status, and dependencies on other PRs. Being behind the target branch isn't necessarily a blocker.

Report remaining blockers or what couldn't be verified. Keep merge readiness separate from code quality and deploy safety.

## 1. Big picture

Explain the goal, where this PR fits in the larger effort, and what's still to come. Investigate relevant issues, design docs, related PRs, and stacks as needed. Distinguish evidence from inference; flag claims in the PR description that don't match the diff.

Review this PR's changes relative to its target branch. Delegate large reviews when useful to conserve context.

## 2. Risks worth investigating

Use judgment about which topics deserve a deeper look; this isn't an exhaustive checklist:

- **Database migrations:** compatibility, operational impact, data safety.
- **Rollback:** can we safely return to the previous version after this runs? Explain the recovery path and any irreversible effects, not just whether the commit can be reverted.
- **Dependencies:** why they're needed, maintenance/security costs, and integration impact.
- **Compatibility and rollout:** old/new versions coexisting, clients and consumers, deployment order, configuration.
- **Correctness and security:** behavior changes, failure modes, permissions, sensitive data.
- **Operational confidence:** tests, observability, performance, and how we'd notice something going wrong.

Follow the project's architecture and actual deployment model, not assumptions about a particular stack. Focus on concrete risks; state uncertainty and skip irrelevant topics.

## Output

Be terse. Plain-text URLs; code references as `path:line`. Dates YYYY-MM-DD, times UTC.

- **PR:** title, number, author; URL on its own line, then the PR's source branch directly below it.
- **Merge readiness:** ready after your approval, blocked, or unknown — why.
- **Big picture:** goal, context, what comes next.
- **What it does:** short summary verified against the diff.
- **Deploy risk:** verdict and relevant findings, including whether and how it can be rolled back.
- **Worth a comment:** prioritized concerns with evidence and why they matter; omit if none.
- **Questions for author:** only what couldn't be established independently; omit if none.

Help Anton decide where and why to comment. Don't draft comment text unless asked.
