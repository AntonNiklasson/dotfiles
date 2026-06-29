---
name: obsidian
description: Read and write notes in Anton's Obsidian vault. It is a deep personal archive of work notes, meetings, people, and problems solved over the years.
---

# Obsidian

Vault lives at `~/notes` (vault name `notes`). Access is via the **official Obsidian CLI** (shipped in Obsidian 1.12.7+) — a registered client binary that talks to the **already-running** Obsidian app over IPC. Official docs: https://obsidian.md/help/cli

Key facts that drive everything below:
- The CLI does **not** launch the app. The app must already be open in the background; if it isn't, calls fail or hang.
- The registered binary lives at `/usr/local/bin/obsidian` on macOS (created by the in-app registration step), **not** inside the `.app` bundle. Calling the bundle's Mach-O directly (`/Applications/Obsidian.app/Contents/MacOS/obsidian`) just cold-launches the GUI and errors with "Argument must be a file path or a NativeImage" — that is the wrong binary.
- Targets the most-recently-focused vault by default; pass `vault=notes` as the first arg to be explicit.

## Preflight (do this once per session before relying on the CLI)

```sh
which obsidian                 # must be /usr/local/bin/obsidian (the registered CLI)
pgrep -f "Obsidian.app/Contents/MacOS/Obsidian" >/dev/null && echo "app running" || echo "app NOT running"
```

- If `which obsidian` resolves into `…/Obsidian.app/Contents/MacOS/…`, the official CLI is **not** registered (or is shadowed by a stale PATH entry). For read-only work, fall back to reading files directly from `~/notes` (see below) instead of fighting it.
- If the app isn't running, either start it or fall back to direct file reads.

Setup, if the CLI isn't registered (one-time): the CLI binary ships with the **installer** (1.12.7+), and Obsidian's auto-updater only bumps the app package, not the installer. So check Settings → General: if "Version" is ≥1.12.7 but "Installer version" is older (and it nags "installer is out of date"), **download and reinstall the latest installer first** — otherwise there's no CLI binary to register. Then Settings → General → Command line interface → **Register CLI**, and restart the terminal. Both are manual steps the user must do — you can't do them for them.

## Invocation

```
obsidian [vault=notes] <command> key=value key=value [flags]
```

- `file=<name>` resolves by name like wikilinks (`file=Astro`, no `.md`)
- `path=<path>` is exact from vault root (`path="02 Areas/Work.md"`)
- Quote values with spaces, e.g. `name="My Note"`
- `\n` and `\t` are accepted in `content=` values
- Most commands default to the active file when `file`/`path` is omitted
- Many list/read commands take `format=json|tsv|csv|text|tree|md|yaml`, plus `total` (count only) and `--copy` (output to clipboard)

## Common commands

Read / search:

```sh
obsidian read path="Astro.md"              # full contents to stdout
obsidian search query=astro limit=5        # filenames matching query
obsidian search:context query=astro        # matches with line context
obsidian daily:read                        # today's daily note
obsidian files folder="02 Areas"           # list files (optional filter)
obsidian outline file=Astro                # heading outline (format=tree|md|json)
obsidian recents                           # recently opened files
```

Structure / metadata:

```sh
obsidian tags counts                       # all tags with counts
obsidian tags file=Astro                   # tags on one note
obsidian backlinks file=Astro              # notes linking here
obsidian links file=Astro                  # outgoing links
obsidian tasks todo                        # open tasks (add done / status="x" / path=…)
obsidian properties file=Astro             # frontmatter properties
obsidian property:read name=status file=Astro
```

Create / edit:

```sh
obsidian create name="New Note" content="hello"
obsidian create path="00 Inbox/Note.md" content="…" open
obsidian append file=Astro content="more"
obsidian prepend file=Astro content="TL;DR…"
obsidian daily:append content="- met with X"
obsidian property:set name=status value=active file=Astro
obsidian move file=Astro to="04 Archive/"
obsidian rename file=Astro name="Astro framework"
```

Navigation / app state:

```sh
obsidian open file=Astro                   # open in app
obsidian daily                             # open today's daily
obsidian search:open query=astro           # trigger in-app search view
obsidian vault info=path                   # vault info (name|path|files|folders|size)
```

Full help: `obsidian --help`. Per-command help: `obsidian help <command>`.

## When to use the CLI vs direct filesystem

- **Writes, and reads that need vault semantics** (wikilink/backlink resolution, daily-note config, templates, frontmatter, rename/move that updates backlinks): use the CLI — but only after the preflight passes. The CLI is the only thing that keeps links consistent on rename/move.
- **Plain read-only access** (reading a known daily note, grepping across notes): reading files directly from `~/notes` is a perfectly good — often better — path. It's fast, needs no running app, and avoids the cold-launch failure mode. Daily notes are at `~/notes/calendar/days/YYYY-MM-DD.md`. Don't burn time driving the CLI for a read you can do with `Read`/`rg`.

Rule of thumb: **CLI for writes and link-aware operations; direct files for reads** when the app may not be running.

## Note conventions

- **No H1 with the note title.** Obsidian renders the filename as the title inline; an H1 duplicates it. Start the body with frontmatter, then content (subheadings as `##` and below).
- Frontmatter is required (`type:` at minimum) — see vault rules in `~/notes/.claude/CLAUDE.md`.
- Link liberally with `[[wiki links]]`. People are `[[@Name]]`.
