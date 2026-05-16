---
name: standup
description: Pull Anton's last-24-hour signal from GitHub (all authenticated hosts), Linear, and Obsidian (daily note + freshly created notes), and print a tight standup brief.
---

# Standup

Anton uses this before a daily standup. The job is to surface what moved on GitHub, Linear, and his notes in the last 24h so he doesn't have to think about it. Print one short brief — that's it.

For a wider weekly view across all sources (calendar, Todoist, etc.), use the `work-log` skill instead.

## Window

Default to **the last 24 hours from now** (rolling). State the exact window at the top, e.g. `Window: 2026-05-12 09:00 → 2026-05-13 09:00 (local)`.

**Monday exception:** if today is Monday, extend the window back through Friday morning — treat the weekend as a gap, not a window. A pure 24h cutoff on Monday would miss everything shipped Friday afternoon, which is exactly what standup needs to cover.

If Anton asks for "since yesterday's standup" or names a specific cutoff, use that instead. If he names a longer window (48h, "since Friday"), honor it but keep the output shape the same.

## Sources

| Source | Tool | What to pull |
|--------|------|--------------|
| GitHub (all hosts) | `gh` CLI | PRs opened, merged, reviewed by `@me` |
| Linear | `linear-server` MCP | Issues completed, created, or moved by Anton |
| Obsidian | `obsidian` CLI | Today's daily note + any notes created in window |

## Pre-flight

Probe both sources before fanning out. If one is missing/expired, tell Anton which and stop — don't paper over with guesses.

For GitHub: discover authenticated hosts via `gh auth status`. Anton's work code and personal code typically live on different hosts; missing one is the main failure mode. Run every query once per host with `GH_HOST=<host>`.

## Per-source instructions

### GitHub — `gh` CLI

For each authenticated host, pull:
- PRs **opened** by `@me` with `--created=">=<cutoff>"`
- PRs **merged** by `@me` with `--merged --merged-at=">=<cutoff>"` (don't use `--state=merged`)
- PRs **reviewed** by `@me` with `--reviewed-by=@me --updated=">=<cutoff>"`

JSON fields: `gh search prs --json` accepts `closedAt`, not `mergedAt` — drift bites here. Valid fields: number, title, repository, state, isDraft, createdAt, closedAt, updatedAt, url.

Group by repo. Note draft vs. ready vs. merged. Skip dependabot/renovate. Filter own merged PRs out of the reviewed list — they're already covered under Merged.

### Linear — `linear-server` MCP

- `list_issues` with `assignee: "me"` and `updatedAt: { gte: "<cutoff ISO>" }`. Separate completed (use `completedAt` filter) from merely touched.
- For each issue, capture identifier (`ENG-1234`), title, state, project.

### Obsidian — `obsidian` CLI

Use the `obsidian` skill for invocation details. Two things to pull:

1. **Daily notes.** Standup runs in the morning, so most of the work happened *yesterday* — always read yesterday's daily note (`obsidian read path="calendar/days/YYYY-MM-DD.md"`) in addition to today's (`obsidian daily:read`, mostly for early-morning notes). On Mondays read Friday's note instead of "yesterday" (the weekend exception from the Window section). Surface: explicit work items, people (`[[@Name]]`), projects (`[[Project]]`), decisions, blockers. Skip if a note is empty or just a template stub.
2. **Notes created in the window.** Use `find ~/notes -type f -name '*.md' -newermt "<cutoff>" -not -path '*/.obsidian/*' -not -path '*/calendar/days/*'` to find recently created notes outside the daily-notes folder (those are covered above). For each, print path + a one-line gist.

**Filter to work / developer signal only.** This is a standup brief, not a journal — drop anything that's clearly personal or off-topic. Skip notes about: hobbies, gear/purchases (cameras, bikes, etc.), travel, family, health, finance, books/music, recipes, home stuff. Keep notes about: engineering problems, architecture, meetings/1:1s with colleagues, customers, projects, research relevant to current work, decisions, tickets, debugging write-ups. When in doubt about a note, peek at its frontmatter `type:` and tags — `type: research` on a web-performance topic stays; `type: gear` or untagged personal scratch goes. Apply the same filter to people and topics surfaced from daily notes — drop `[[Fujifilm X-T5]]`, keep `[[@Colleague]]` and `[[Project]]`.

Quote sparingly. The point is signal, not transcription.

## Output shape

Use **nested lists** for PRs and Linear issues — one item per line, never `·`-separated runs. Scannability beats density here; the reader is reading aloud at standup.

```
# Standup — <window>

## GitHub

**<host> / <owner>/<repo>** (other hosts: nothing)

- Merged
  - #NNN title
  - #NNN title
- Opened
  - #NNN title (draft)
  - #NNN title
- Reviewed
  - #NNN title

## Linear

- Completed
  - AI-1234 title · project
  - AI-1234 title · project
- In review
  - AI-1234 title · project
- Created
  - AI-1234 title · project
- Touched (no movement)
  - AI-1234 title · project

## Notes

- Daily (YYYY-MM-DD): <people / projects / decisions / blockers>
- Today: <same, or "empty">
- New notes
  - `<path>` — one-line gist
```

Identifiers + titles, nothing else. If a section is empty, say "nothing" — don't pad. If a sub-bucket (e.g. Reviewed) is empty, drop the header rather than write "nothing".

## Guardrails

- **Don't fabricate.** Empty source → say so.
- **Don't draft talking points** unless Anton asks. Default is the brief, nothing more.
- **Pull from artifacts, not memory.** If a source fails pre-flight, abort that source.
