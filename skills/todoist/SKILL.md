---
name: todoist
description: Query and modify tasks in Anton's Todoist via the `td` CLI (`@doist/todoist-cli`). Use for listing today/upcoming/overdue/inbox/completed tasks, adding tasks (natural language or explicit flags), completing/updating/moving tasks, listing projects, and pulling completion or addition activity in a date range. Read-mostly; writes (add/complete/update/delete) only on explicit ask.
---

# Todoist (`td`)

`td` is `@doist/todoist-cli` (Doist), v1.2.0+, installed globally under fnm-managed node. Non-interactive shells (Claude Code's Bash tool) don't load fnm, so always invoke via the stable shim:

```
~/.local/share/fnm/aliases/default/bin/td
```

Plain `td` will fail with `command not found` from a non-interactive shell. The shim resolves to `…/dist/index.js` regardless of which Node version fnm currently has active.

## Agent flags (use these)

- `--json` — parseable output. `results: [...]` array plus `nextCursor`.
- `--ndjson` — newline-delimited; better for large result sets.
- `--full` — include all fields (default JSON is trimmed essentials).
- `--all` — fetch all pages, ignore `--limit`. Prefer this over manual cursoring.
- `--limit N` / `--cursor <c>` — paginate; `nextCursor` from previous response.
- `--no-spinner` — top-level; quiet animations.

The CLI itself prints `Use --json or --ndjson flags for unambiguous, parseable output.` in its help — Doist designed this for agents.

## Read commands

### Today / upcoming / overdue / inbox

```sh
~/.local/share/fnm/aliases/default/bin/td today --json --all          # due today + overdue, mine
~/.local/share/fnm/aliases/default/bin/td upcoming 14 --json --all    # next 14 days
~/.local/share/fnm/aliases/default/bin/td inbox --json --all
~/.local/share/fnm/aliases/default/bin/td inbox --priority p1 --json
```

`today`/`upcoming`/`inbox`/`task list` default to assignee=me (or unassigned). `today` and `upcoming` accept `--any-assignee` for shared workspace tasks. `task list` uses `--assignee <ref>` (`me` or `id:xxx`) or `--unassigned` instead — there's no `--any-assignee` flag on `task list` or `inbox`.

### Task list (most flexible)

```sh
td task list --json --all                                   # all open tasks
td task list --project Work --json --all
td task list --label deep-work --json
td task list --priority p1 --json
td task list --filter "today | overdue" --json --all        # raw Todoist filter syntax
td task list --filter "@deep-work & p1" --json
```

`--filter` accepts the full Todoist filter query language (`today`, `overdue`, `p1`, `#Project`, `@label`, `&`, `|`, `!`, `7 days`, etc.) and is the most reliable way to slice once you need any compound logic. For simple cases, `--due today` and `--due overdue` work fine.

### Completed

Two ways, with different shapes:

```sh
# 1. completed: returns task records (content, project, due, etc.)
td completed --since 2026-05-01 --until 2026-05-08 --json --all
td completed --since 2026-05-01 --until 2026-05-08 --project Work --json --all

# 2. activity: returns event log with completion timestamps + extraData
td activity --since 2026-05-01 --until 2026-05-08 \
  --by me --event completed --json --all
```

For "what did Anton complete this week" (work-summary use case), `activity --event completed --by me` is richer — gives `eventDate` (precise completion timestamp), `parentProjectId`, and `extraData.content`. Use `completed` when you want task-shaped records.

### Activity (general)

```sh
td activity --since 2026-05-01 --until 2026-05-08 --by me --json --all
td activity --event added --by me --since 2026-05-01 --json   # tasks Anton added
td activity --type task --event updated --by me --json
```

Events: `added`, `updated`, `deleted`, `completed`, `uncompleted`, `archived`, `unarchived`, `shared`, `left`. Types: `task`, `comment`, `project`.

### Projects / labels

```sh
td project list --json --all
td project view <name>
td label list --json
```

## Write commands

Writes mutate Anton's real Todoist. Don't run unprompted — confirm intent first.

### Add a task

Natural language (preferred for one-shot):

```sh
td add "Buy milk tomorrow p1 #Shopping @errand"
td add "Reply to Marcus every Monday at 9am #Work"
```

Recognized inline syntax: `tomorrow`, `next monday`, `every friday at 16:00`, `p1`–`p4`, `#Project`, `@label`. See [Todoist quick add docs](https://todoist.com/help/articles/use-task-quick-add-in-todoist-va4Lhpzz) for the full grammar.

Explicit flags (preferred when fields are structured):

```sh
td task add --content "Review PR #1234" \
  --project Work --priority p2 --due "tomorrow 10am" \
  --labels deep-work,review --duration 30m \
  --description "Linear: ENG-1234"
```

### Complete / uncomplete / update / move / delete

```sh
td task complete <id-or-name>
td task complete --forever <id>             # stop recurrence permanently
td task uncomplete id:6gWwf85RrWMmjMFH      # uncomplete REQUIRES id: prefix
td task update <ref> --priority p1 --due "friday"
td task move <ref> --project Work --section "In progress"
td task delete --yes <ref>                  # --yes required, no interactive prompt
```

`<ref>` accepts: task name (fuzzy match), `id:6gWwf85RrWMmjMFH`. Prefer `id:` form when the task came from a previous JSON query — name matching is ambiguous. Get the id from any `task list`/`today`/`completed` JSON output (`.results[].id`).

### View one task

```sh
td task view id:6gWwf85RrWMmjMFH --json --full
```

## JSON shapes (essentials)

`task list` / `today` / `upcoming` / `completed` `.results[]`:

```
id, content, description, priority (1=p4..4=p1, inverted!),
due { isRecurring, string, date, timezone, lang } | null,
deadline | null, duration { amount, unit } | null,
projectId, sectionId, parentId, labels[], url,
responsibleUid, isUncompletable
```

Priority is **inverted** in JSON: API `priority: 4` = UI `p1` (highest), `1` = `p4` (lowest / no flag). The CLI flags (`--priority p1`) use the UI numbering — only the JSON field is flipped.

`activity .results[]`:

```
objectType (task|comment|project), objectId, eventType, eventDate (ISO),
parentProjectId, parentItemId, initiatorId,
extraData { content, dateAdded, dueDate, priority, isRecurring, wasOverdue, … }
```

Project resolution: `task.projectId` is opaque — join against `td project list --json --all` to get names.

## Known quirks

- `td filter list` returns `Failed to fetch filters: 410` — server-side endpoint deprecated. Saved filters can't be enumerated via CLI. Workaround: pass the filter expression directly via `td task list --filter "<query>"`.
- Some queries with small `--limit` (e.g. `td today --limit 2`) returned `results: []` plus a `nextCursor` while `--all` returned data — the first page can land on a slice that filters out. If a query looks empty unexpectedly, retry with `--all`.
- Activity API occasionally `HTTP 502: Bad Gateway` — transient; retry once.
- `task uncomplete` requires `id:xxx` form; name matching doesn't work for completed tasks.

## Auth

Token is stored via `td auth login` / `td auth token <t>`. Check with `td auth status`. If queries return auth errors, stop and tell Anton — don't try to re-auth from the agent.
