---
name: obsidian
description: Read and write notes in Anton's Obsidian vault. It is a deep personal archive of work notes, meetings, people, and problems solved over the years.
---

# Obsidian

Vault lives at `~/notes` (vault name `notes`). The `obsidian` command on PATH is the Obsidian.app binary — it doubles as a full CLI that drives the running app. First call launches the app (~2s); subsequent calls return in <300ms and exit cleanly.

## Invocation

```
obsidian <command> key=value key=value
```

- `file=<name>` resolves by name like wikilinks (`file=Astro`, no `.md`)
- `path=<path>` is exact from vault root (`path="02 Areas/Work.md"`)
- Quote values with spaces, e.g. `name="My Note"`
- `\n` and `\t` are accepted in `content=` values
- Most commands default to the active file when `file`/`path` is omitted

Wrap with `timeout 5 obsidian …` as a safety belt on the first invocation in a session. Every call prints two noise header lines — strip them or just ignore them:

```
2026-04-24 13:24:22 Loading updated app package …
Your Obsidian installer is out of date. Please download the latest installer …
```

To suppress: `| grep -vE '(Loading updated app package|installer is out of date)'`.

## Common commands

Read / search:

```sh
obsidian read path="Astro.md"              # full contents to stdout
obsidian search query=astro limit=5        # filenames matching query
obsidian search:context query=astro        # matches with line context
obsidian daily:read                        # today's daily note
obsidian files folder="02 Areas"           # list files (optional filter)
obsidian outline file=Astro                # heading outline
obsidian recents                           # recently opened files
```

Structure / metadata:

```sh
obsidian tags counts                       # all tags with counts
obsidian tags file=Astro                   # tags on one note
obsidian backlinks file=Astro              # notes linking here
obsidian links file=Astro                  # outgoing links
obsidian tasks todo                        # open tasks (add done / status=x / path=…)
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
obsidian command id=editor:toggle-fold     # execute any Obsidian command id
```

Full help: `timeout 5 obsidian --help`. Per-command help: `obsidian help <command>`.

## When to use CLI vs direct filesystem

Prefer the CLI — it understands wikilinks, tags, backlinks, daily-note config, templates, and frontmatter, and updates backlinks on rename/move. Fall back to `Read` + `rg ~/notes` only for raw multi-file scans the CLI can't express, or when the app isn't available.
