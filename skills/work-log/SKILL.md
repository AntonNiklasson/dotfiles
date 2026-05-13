---
name: work-log
description: Pull Anton's work signal for a given ISO week from GitHub, Linear, Fantastical, Obsidian daily notes, and Todoist, and print a dense research brief he uses to draft his Work Log bullets manually. Use for the Friday ritual (current week) or backfilling past weeks.
---

# Work Log

**Anton writes the Work Log bullets himself.** The agent's job is to surface enough signal across his work systems that drafting becomes a 5-minute scan rather than a memory exercise. Default flow ends at the printed brief — only draft and write to Work Log.md if Anton explicitly asks (see "After the brief" below).

End goal context: bullets eventually go under the right ISO-week heading in `~/notes/02 Areas/Sana/Work Log.md`. The log is low-bar and matter-of-fact; see `~/notes/02 Areas/Sana/My weekly approach to logging work.md` for the philosophy ("log, don't curate"). Knowing this shapes the output: it's research material *for* a Work Log entry, not a polished summary.

## Sources

| Source | Tool | What to pull |
|--------|------|--------------|
| GitHub (all hosts) | `gh` CLI | PRs opened/merged, reviews — across every authenticated host |
| Linear | `linear-server` MCP | Issues completed/created, cycle progress |
| Fantastical | `fantastical` MCP | Calendar events, meeting load |
| Obsidian | `obsidian` CLI | Daily notes (vault: `~/notes`, daily folder: `calendar/days/`) |
| Todoist | `td` CLI | Completed and added tasks |

## Pre-flight tool check

Before fanning out, probe every source. If any is missing, expired, or broken, stop and tell Anton which one — wait for him to fix it (`/mcp` re-auth, etc.) before continuing. Don't paper over a missing source by guessing from memory.

For GitHub specifically: discover hosts at runtime rather than hardcoding them. `gh auth status` lists every authenticated host (e.g. `github.com`, plus any GitHub Enterprise instance). Cross-check against `git -C ~/code/<repo> remote -v` if you want to confirm a host shows up in real work. Run every GitHub query once per authenticated host using `GH_HOST=<host>` — Anton's day-job code typically lives on a different host than personal projects, and missing one is the biggest failure mode of this skill.

## Resolving the week

The Work Log is keyed by ISO week (`YYYY-Www`, Mon–Sun). Resolve the target week first:

- "This week" / "the Friday ritual" → ISO week containing today.
- "Last week" → previous ISO week.
- "Backfill week N" / "2026-W14" → that exact week.
- A date range that doesn't align to a single ISO week → confirm before proceeding; the log is per-week.

Compute the Mon/Sun boundaries and the ISO week number, and state both at the start: e.g. `Target: 2026-W18 · Apr 27 – May 3`. The user should sanity-check before the agent fans out into source queries.

## Per-source instructions

### GitHub — `gh` CLI

Run every query once per authenticated host (see Pre-flight). For each host, pull:
- PRs **opened** by `@me` in the date range
- PRs **merged** by `@me` in the date range — use `--merged --merged-at=">=YYYY-MM-DD"`. Don't use `--state=merged`; that flag only takes `open|closed`.
- PRs **reviewed** by `@me` in the date range — `--reviewed-by=@me --updated=">=YYYY-MM-DD"`

Group by repo. Note draft vs. ready vs. merged. Skip dependabot/renovate noise unless asked. If a snippet is needed, derive it from `gh search prs --help` rather than copying old patterns — the flags drift.

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

The vault is `~/notes`. Daily notes live in `calendar/days/YYYY-MM-DD.md`. Always go via the `obsidian` CLI per the obsidian skill — don't `cat` the files directly.

Iterate the date range, read each daily note, and surface: explicit work items, people mentioned (`[[@Name]]`), projects (`[[Project Name]]`), and decisions/blockers. Skip empty or near-empty notes. Daily notes are the richest signal for *why* something happened — quote them sparingly when they explain context the other sources can't.

### Todoist — `td` CLI

Use the **`todoist` skill** for all `td` invocations — it's the single source of truth for the shim path, JSON shape, and known quirks. For work-summary specifically, you want completed-in-range; the todoist skill recommends `td activity --event completed --by me --since/--until` over `td completed` (richer event log).

Surface operational/admin work that doesn't show up in GitHub or Linear; group by project where useful. If output looks wrong (open tasks instead of completions, etc.), flag it and skip — don't guess.

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

## After the brief — drafting and writing

Default flow:
1. Print the research brief.
2. If Anton asks for a draft, propose bullets in chat *first* (matching the prior week's tone — open `Work Log.md` and skim 1–2 recent entries to calibrate detail level). **Don't write to the file yet.**
3. Wait for explicit go-ahead ("looks good, add it", "yes write it"). Only then append the new ISO-week heading above the most recent week in `~/notes/02 Areas/Sana/Work Log.md` via the `obsidian` CLI.
4. Preserve any existing edits Anton made manually — only insert the new heading + bullets, don't rewrite surrounding weeks.

Keep the brief itself dense and over-inclusive. Boiling down to bullets happens at step 2, not step 1 — better to have too much context and trim than to filter prematurely.

## Guardrails

- **Don't fabricate.** If a source is empty, say so and skip it. No plausible-sounding work to fill gaps.
- **Don't write to Work Log.md without explicit consent.** Default is print-and-wait. Anton drives when bullets land.
- **Pull from artifacts, not memory.** If a source is unavailable after the pre-flight check, abort that source rather than guessing.

## Common requests

| Request | What to do |
|---------|-----------|
| "Friday signal" / "what did I do this week" | Resolve current ISO week, query all sources, print the brief |
| "Backfill signal for W14" / "research 2026-W14" | Resolve that exact ISO week, query all sources, print the brief |
| "Catch me up on the last 4 weeks" | Iterate week by week; one brief per week, not a merged 4-week dump |
