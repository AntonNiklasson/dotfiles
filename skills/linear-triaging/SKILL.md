---
name: linear-triaging
description: "Triage one Linear issue — pick the issue yourself when none is named (Triage first, `Bugs`-labeled issues when Triage is empty), work out whether it is real, ours, and worth fixing, and land on exactly one clear suggestion: ask the reporter, cancel, duplicate, backlog at a non-urgent priority, or do the work in a `wt` worktree handed back uncommitted. Safe to run unattended on a schedule — mutations stay approval-gated. Use when asked to triage a bug, work through Triage, or investigate a Sentry-filed Linear issue."
user-invocable: true
argument-hint: "[issue-id]"
---

# Triage a Linear issue

Take one issue from Triage to a decision. **Choosing which issue is your job, not the user's** (step 0) — they invoke the skill, you come back with a decision on something.

The decision is one of five (step 4): `ASK`, `CANCEL`, `DUPLICATE`, `BACKLOG`, `WORK`. Four of them are a ticket action and no code. Only `WORK` produces a change, and it lands in a worktree, uncommitted, never a PR. Most issues in Triage should be closed, not fixed, and the job is to find that out cheaply.

The deliverable is one **clear suggestion**, stated as an imperative in the report's first line — "Cancel: third-party, filter recommended", "Backlog at P4: real but rare", "Apply the diff in worktree X". Investigation that ends in "it depends" is a failed invocation.

Optimise for correctly closing things. A wrong "fix it" costs a day; a wrong "close it" costs a recurrence you'll see again in Sentry.

## Step 0 — Pick the issue yourself

With an issue ID in args, use it. Otherwise **you choose** — list candidates and commit to one. Do not ask the user which; a list of options handed back is a failed invocation.

```
mcp__linear-server__list_issues  assignee="me"  state="triage"
  fields=["title","status","priority","url","labels","createdAt","updatedAt","project"]
```

**Fallback — Triage empty:** pick a `Bugs`-labeled issue assigned to me instead (exact label name, workspace-level). Same fields; query `label="Bugs" assignee="me"`. Skip anything started, done, or canceled. For these the ticket already lives in Backlog/Todo, so `BACKLOG` means "stays put, priority corrected", not a state move. Both empty → say "nothing to triage" in one line and stop; that's a successful run, not a failure.

Pick the one that most cheaply reaches a decision, in this order:

1. **Reopened** (`Done` → `Triage`, visible in `stateHistory`) — gate C often closes these in minutes.
2. **Obvious duplicate or third-party** from the title alone — gates A and B are cheap.
3. **Oldest `updatedAt`** — Triage rot is the thing being fought.
4. **Highest priority** last. Stated priority is wrong often enough (step 3) that it never outranks the above.

Skip and say so in one line: anything with reporter discussion in the last day, and anything obviously covered by someone else's in-flight work.

Open the report with one sentence on why this issue over the others. Never triage more than one per invocation — depth is the point.

## Step 1 — Gather evidence

Delegate to a subagent. Sentry payloads and stack traces are large and you only need the conclusions.

Collect:
- Linear issue + comments (`get_issue`, `list_comments`), including `stateHistory` — a Done→Triage transition changes the whole analysis (see gate C).
- Sentry issue for each attachment: full source-mapped stack, event count, user count, first/last seen, browser/OS breakdown, release, environment, route/URL, `handled`, tags, replay ID.
- Git history for prior fix attempts: `git log --all -i --oneline --grep="<ISSUE-ID>" --grep="<parent-id>"` plus a grep for the error message.
- The implicated code, read properly — not just the grep hit.

## Step 2 — Four gates, cheapest first

Run these in order and stop at the first that fires. Each is a cheap disqualifier that saves a deep investigation.

**A. Is it ours?** → `CANCEL`
A stack with no first-party frame is a third-party bug. Note that the throwing line often belongs to a library while the *trigger* is ours — so identify which of our components pulls that library path in before concluding. Usually `CANCEL` with a recommended Sentry filter plus an upstream issue, not a code change.

**B. Is it a duplicate?** → `DUPLICATE`
One throw is routinely filed as two Sentry issues when two capture mechanisms see it — an ErrorBoundary (`handled: yes`) and the global `onerror`/`onunhandledrejection` (`handled: no`). Tells: identical trace ID, identical replay ID, timestamps within seconds, same user. Also check whether one message has fragmented across several issue groups; search the message org-wide before believing any volume number.

**C. Is it already fixed?** → `Done`
Critical for reopened issues. Events arriving *after* a fix merged usually come from long-lived browser tabs on pre-fix bundles, not from a regression. Check release ancestry rather than dates:

```bash
git merge-base --is-ancestor <fix-commit> <event-release-sha> && echo "post-fix — real" || echo "pre-fix bundle — stale tab"
```

If every post-fix event is on a non-descendant release, the fix stuck — back to `Done` (see `CANCEL`), and set a Sentry alert filtered to descendants of the fix commit so it doesn't get reopened for the same wrong reason.

**D. Is the volume real?**
See step 3 before trusting any number.

## Step 3 — The numbers lie in known ways

Never quote Sentry counts without checking these. Each has produced a wrong priority in this repo:

- **`users: 0` does not mean zero users.** With `sendDefaultPii: false` no identity is attached, so the count is meaningless — not evidence of low impact.
- **Beacon-delivered events collapse to one "user".** Anything sent via `sendBeacon` through the Sentry tunnel (e.g. `entry-chunk-beacon.ts`) carries no user or browser context, so Sentry attributes every event to the tunnel's egress IP. Undercounts badly.
- **Several events can be one session.** Compare replay IDs and geo before reporting "N users affected".
- **One bug can be many issue groups.** Different browsers phrase the same error differently and fingerprint apart.
- **`handled: yes` still means user-visible** if a route-level boundary caught it — the pane dies even though the shell survives. Check which boundary caught it.

State the corrected reading explicitly, and say plainly when a High priority looks unjustified.

## Step 4 — The decision

Exactly one of five, every time. Pick one and commit; don't hand over two half-decisions.

| Decision | Means | Where the ticket ends up |
|---|---|---|
| `ASK` | Can't decide without a repro or reporter input | Stays in Triage, assigned to the reporter, one specific answerable question in a comment |
| `CANCEL` | Not ours, expected behaviour (cancellation, unload), or real but never worth fixing | `Canceled` + comment: what you found and what would justify reopening. If the reason is "the fix already landed" (gate C), the state is `Done`, not `Canceled` |
| `DUPLICATE` | Same throw as another issue (gate B) | `Duplicate`, linked to the canonical issue, comment naming it |
| `BACKLOG` | Real and ours, but not now — or this ticket is the wrong unit of work (too big, several bugs in one, root cause uncertain) | Out of Triage to `Backlog` with an **explicit non-urgent priority** (usually P3/P4; step 3 justifies anything higher — never inherit the reporter's priority unexamined), fix plan in a comment. Split into subissues under it when it's genuinely several bugs. **No code** |
| `WORK` | Real, ours, and small enough that you can name the exact lines to change | Stays yours. The change lands in a worktree (below) |

`WORK` is the expensive decision and the easiest to get wrong. If you can't name the lines, it's `BACKLOG`. Most of Triage should end on `CANCEL`, `DUPLICATE`, or `BACKLOG`.

Pair the decision with **importance** — corrected reach × severity (silent / degraded / pane dead / work lost) × trend (rising, flat, or dead for weeks).

## Step 5 — Validation plan

Required for `WORK`; for `BACKLOG`, sketch it in the plan so whoever picks it up knows whether the fix is checkable at all. The user cares as much about this as about the fix. Rate how validatable the fix is:

- **Deterministic** — the failure can be forced locally and a test can lock it. Highest confidence.
- **Probabilistic** — only observable in production; needs a release-filtered watch and time.
- **Unfalsifiable** — too rare to observe and no repro path. Fixing is a guess; say so, and prefer a guardrail (lint rule, type constraint) that makes the class of bug unrepresentable over a speculative patch.

Techniques that have worked here for forcing a deterministic repro:
- Delete the missing builtin (`delete Array.prototype.toSorted`) in a unit test.
- Remove the DOM node the library assumes (`document.body.remove()`).
- Insert a temporary delay in the tRPC resolver to widen a race window — more faithful than DevTools throttling, which can't isolate one call.
- Serve two builds behind a round-robin proxy to reproduce mid-rollout skew.
- `pnpm test:stale-chunk` for chunk/deploy-skew failures.

Always give both halves:
- **Before merge** — repro steps and the test that locks the regression.
- **After deploy** — the specific Sentry issue and the signal that means success, *release-filtered*.

Traps to call out when they apply:
- **Low volume makes absence meaningless.** At a handful of events, "no recurrence" is not evidence. Lean on the test.
- **StrictMode does not surface everything.** It double-invokes render and effects but does not create controlled/uncontrolled desyncs — a clean local run is not proof.
- **Filters need a negative test.** When the fix is a Sentry `beforeSend` filter, assert that the *first-party* variant of the same message still gets through. Over-broad filters hide real bugs. Prefer a frame-based filter in `beforeSend` over a message string in `ignoreErrors`.

## Step 6a — Delivering `WORK`: a worktree, never a PR

AI-authored PRs are frowned on in these repos. The handover is a worktree with the change **uncommitted** — Anton reads it, reshapes it, and owns everything downstream of that.

A Sentry `beforeSend` filter is still code, so `NOISE` whose fix is a filter is `WORK`, not `CANCEL`.

Create the worktree with `wt` — not `create-worktree.sh`, not the repo's `worktree` skill. `wt` puts worktrees as siblings of the checkout (`~/code/sana-ai--<name>`) and applies `.worktree-setup.yml`.

```bash
wt new <short-name> --branch an/<slug> --no-agent --wait
```

- `<short-name>`: ticket id plus something human, e.g. `ai-12113-stale-chunk`. Never the bare id.
- Branch from Linear's `gitBranchName`, re-namespaced to `an/`.
- `--no-agent` because you apply the change yourself — don't hand the fix to a second agent that lacks the investigation. It also keeps `wt` non-interactive and stops the new tab taking focus.
- `--wait` because setup runs `pnpm install` + `pnpm build`; without it `wt` returns the moment the tab exists and your first `pnpm -C` hits a worktree with no `node_modules`. It takes minutes, so run it in the background and poll — don't block a foreground call on it.
- `wt` needs herdr (`HERDR_PANE_ID` set) — it opens the worktree as a tab. Outside herdr it creates the worktree and *then* errors, so check the env before running it; with no herdr, hand over the diff inline instead and say why.

Then:
- Apply the change with absolute paths into the worktree. Run checks without `cd`: `pnpm -C ~/code/sana-ai--<short-name> check-ts`, `... format`, and the narrowest useful tests.
- **Leave it uncommitted.** No commit, no push, no PR, no PR description.

A diff with no argument is not a deliverable. Ship it with three parts, a couple of sentences each:

1. **Why this is a bug** — the invariant that's broken, at `file:line`. Not "Sentry reports X".
2. **Why this change fixes it** — where it breaks the causal chain, and what it deliberately does *not* cover.
3. **How to validate it** — from step 5, both halves.

Close with the worktree path, how to run it (the `run-worktree-client` skill serves a worktree's client against the main backend), and how to bin it: `wt rm <short-name>`.

## Step 6b — Delivering the other four: a ticket action

No code. Preview the action — target state, assignee, and the comment text verbatim — and execute only after approval.

The comment *is* the explanation: same burden as the three parts above, compressed. Anyone reopening this in six months should be able to tell from the comment alone whether the reasoning still holds.

For `BACKLOG` that splits into subissues, preview each subissue title and its one-line scope before creating anything.

Sentry hygiene (filters, alerts, resolve, ignore) is a **recommendation** in the report. Never execute it.

## Unattended runs

This skill may fire on a schedule with nobody watching. Same pipeline, two differences:

- The report **is** the deliverable. End on it — the approval gate in step 6b means ticket actions simply wait for the next human look; don't treat "couldn't get approval" as a blocker or retry for it.
- `WORK` still prepares the worktree (reversible, `wt rm` bins it) when herdr is available; without herdr, put the diff inline in the report instead of erroring out.

Preview the pending action verbatim in the report so approving it later is a one-word reply, not a re-investigation.

## Report format

Keep it terse. Sacrifice grammar for concision.

```
## <ISSUE-ID> — <title>
**Suggestion:** <one imperative sentence — the action to take, e.g. "Cancel: third-party, add Sentry filter" / "Backlog at P4" / "Apply diff in worktree X">
**Picked because:** <one line; omit when the id came from args>
**Decision:** ASK | CANCEL | DUPLICATE | BACKLOG | WORK
**Importance:** <corrected reach, severity, trend — and whether the current priority is wrong>
**Validation:** Deterministic | Probabilistic | Unfalsifiable

**Why it's a bug** — broken invariant, concrete file:line.
**Root cause** — assessment + explicit confidence.
**Why the change fixes it** — `WORK` only. Include what it doesn't cover.
**Validate** — before merge / after deploy.
**Effort** — one line.
**Handover** — worktree path + `wt rm <name>` to bin it, or the proposed ticket action awaiting approval.
```

## Never

- Hand the issue choice back to the user. No "which of these should I look at?" — pick one, say why, go (step 0).
- Open a PR, or write a PR title/description. AI-authored PRs are frowned on here; the human who owns the PR writes those.
- Commit or push without explicit approval.
- Change Linear state, create a subissue, or post a comment before showing the preview and getting approval.
- Resolve, ignore, or otherwise mutate Sentry state. Recommend it; let the human do it.
- Report a Sentry count without applying step 3.
- Claim a fix is validated when only the "after deploy" half exists.
- Write code for a `BACKLOG`, or hand over a worktree without the three-part explanation.
- Move a ticket to Backlog without setting an explicit priority.
