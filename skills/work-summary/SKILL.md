---
name: work-summary
description: Pull Anton's work signal for a given ISO week from GitHub, Linear, Fantastical, Obsidian daily notes, and Todoist, and print a dense research brief he uses to draft his Work Log bullets manually. Use for the Friday ritual (current week) or backfilling past weeks.
---

# Work Summary

**Anton writes the Work Log bullets himself.** The agent's job is to surface enough signal across his work systems that drafting becomes a 5-minute scan rather than a memory exercise. Don't write to Work Log.md.

End goal context: bullets eventually go under the right ISO-week heading in `~/notes/02 Areas/Sana/Work Log.md`. The log is low-bar and matter-of-fact; see `~/notes/02 Areas/Sana/My weekly approach to logging work.md` for the philosophy ("log, don't curate"). Knowing this shapes the output: it's research material *for* a Work Log entry, not a polished summary.

## Sources

| Source | Tool | What to pull |
|--------|------|--------------|
| GitHub | `gh` CLI | PRs opened/merged, reviews, commits |
| Linear | `linear-server` MCP | Issues completed/created, cycle progress |
| Fantastical | `fantastical` MCP | Calendar events, meeting load |
| Obsidian | `obsidian` CLI | Daily notes (vault: `~/notes`, daily folder: `calendar/days/`) |
| Todoist | `td` CLI | Completed and added tasks |

If a tool is missing or unauthenticated, say abort and let me reconfigure it.

## Resolving the week

The Work Log is keyed by ISO week (`YYYY-Www`, Mon–Sun). Resolve the target week first:

- "This week" / "the Friday ritual" → ISO week containing today.
- "Last week" → previous ISO week.
- "Backfill week N" / "2026-W14" → that exact week.
- A date range that doesn't align to a single ISO week → confirm before proceeding; the log is per-week.

Compute the Mon/Sun boundaries and the ISO week number, and state both at the start: e.g. `Target: 2026-W18 · Apr 27 – May 3`. The user should sanity-check before the agent fans out into source queries.

## Per-source instructions

### GitHub — `gh` CLI

Prefer the events API over `gh search` (no rate limits, includes draft activity):

```bash
gh api user/events --paginate | jq --arg since "<ISO>" '
  [.[] | select(.created_at >= $since)
        | select(.type | IN("PullRequestEvent","PullRequestReviewEvent","PushEvent","IssuesEvent"))]'
```

For PRs specifically (clearer titles + state):

```bash
gh search prs --author=@me --created=">=YYYY-MM-DD" --json number,title,state,repository,url,createdAt,closedAt
gh search prs --author=@me --updated=">=YYYY-MM-DD" --state=merged --json number,title,repository,mergedAt,url
```

For reviews given to others:

```bash
gh search prs --reviewed-by=@me --updated=">=YYYY-MM-DD" --json number,title,repository,author,url
```

Group by repo. Note draft vs. ready vs. merged. Skip dependabot/renovate noise unless asked.

### Linear — `linear-server` MCP

Use the Linear MCP tools (already connected). Relevant ones:

- `list_issues` with `assignee: "me"`, `updatedAt: { gte: "<ISO>" }`, and a state filter for completed issues. Use `completedAt` filter when you want strictly "shipped this week" rather than "touched this week".
- `list_cycles` to find the current cycle, then `list_issues` with that `cycleId` for sprint-scoped reports.
- `list_comments` with `userId: "me"` for visibility into discussions/decisions Anton drove, when relevant for retro/promo prep.

For each issue, capture identifier (e.g. `ENG-1234`), title, state, and project — the project is what makes the summary readable.

### Fantastical — `fantastical` MCP

Tools: `queryCalendars`, `queryCalendarItems`. Use `queryCalendarItems` with the resolved date range.

Filter the list before reporting:
- Drop declined invites and tentative responses.
- Drop all-day blocks like OOO, focus blocks, and "Lunch".
- Drop recurring placeholders with no real attendees.
- Keep 1:1s, sprint ceremonies, interviews, external meetings.

Report meeting count and rough total hours, then 5–10 highlights grouped by theme (1:1s, planning, interviews, customer). Don't dump a flat list.

### Obsidian — `obsidian` CLI

The vault is `~/notes`. Daily notes live in `calendar/days/YYYY-MM-DD.md`. Read them directly:

```bash
obsidian daily:read date=YYYY-MM-DD     # if the date is "today" or relative this works
cat ~/notes/calendar/days/YYYY-MM-DD.md  # exact path read; faster for ranges
```

Iterate the date range, read each daily note, and surface: explicit work items, people mentioned (`[[@Name]]`), projects (`[[Project Name]]`), and decisions/blockers. Skip empty or near-empty notes. Daily notes are the richest signal for *why* something happened — quote them sparingly when they explain context the other sources can't.

### Todoist — `td` CLI

`td` is `@doist/todoist-cli`, installed globally under fnm-managed node. Non-interactive shells (like this Bash tool) don't load fnm, so invoke via the stable shim:

```bash
~/.local/share/fnm/aliases/default/bin/td completed --since YYYY-MM-DD --until YYYY-MM-DD --json
~/.local/share/fnm/aliases/default/bin/td activity --json   # added/completed/edits feed
```

Use `--json` (or `--ndjson` for streaming) — the CLI explicitly recommends it for agent use. Surface operational/admin work that doesn't show up in GitHub or Linear; group by project where useful.

## Output shape

Print a single research brief in the chat. Anton reads it and writes his own bullets. Suggested structure:

```
# Work signal — <ISO week> · <date range>

## GitHub
- <PRs merged, opened, reviewed — with numbers and titles, grouped by repo>

## Linear
- <issues completed/touched — with identifiers and project>

## Calendar
- <meetings that mattered: 1:1s, interviews, customer, sprint ceremonies. Drop OOO/focus/declined>

## Daily notes
- <people mentioned, projects mentioned, decisions, blockers, dead ends — quote sparingly when context isn't obvious from the other sources>

## Todoist
- <completed tasks worth surfacing — operational/admin work that GitHub and Linear miss>
```

Keep it dense and skimmable. No prose paragraphs, no narrative — Anton wants to scan and pick. Cite identifiers (PR numbers, `ENG-1234`, dates) so anything is checkable. No puffery: "merged X" not "successfully delivered X".

The W17 entry in `Work Log.md` is a useful reference for what kind of detail level eventually lands in the log — that informs which bullets are worth surfacing in the brief.

## Guardrails

- **Don't fabricate.** If a source is empty, say so and skip it. No plausible-sounding work to fill gaps.
- **Don't write to Work Log.md.** Anton drafts the bullets himself.
- **Pull from artifacts, not memory.** If a source is unavailable, abort that source rather than guessing — matches the rule on line 20.

## Common requests

| Request | What to do |
|---------|-----------|
| "Friday signal" / "what did I do this week" | Resolve current ISO week, query all sources, print the brief |
| "Backfill signal for W14" / "research 2026-W14" | Resolve that exact ISO week, query all sources, print the brief |
| "Catch me up on the last 4 weeks" | Iterate week by week; one brief per week, not a merged 4-week dump |
