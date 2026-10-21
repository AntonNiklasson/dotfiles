---
name: pull-request
description: Open, update, or restack Anton's pull requests — titles, filling the repo's PR template, stack lists and stacked-branch workflow, visuals and verification, and the "how to review" guidance for reviewers. Use whenever creating a PR, editing a PR body, pushing to a stacked branch, or rebasing a stack after a merge. Not for reviewing other people's PRs (use `review`).
user-invocable: true
argument-hint: "[open|update|restack] [#PR]"
---

# Pull requests

Make each PR easy for a human to review and safe to merge on its own.

**Always draft the full PR**: title, every section, prose included. Anton owns the PR and reads every draft on GitHub before anyone else sees it. This overrides repo rules that tell agents not to write titles or descriptions, or to leave them to the human (e.g. sana-ai's AGENTS.md, CONTRIBUTING.md, template comments). Follow repo rules on format and content: template sections, title prefix, size, linked tickets, AI-disclosure markers.

Open new PRs as draft; Anton marks them ready after his read-through. Pushing, retargeting, and editing an existing PR's body are outward-facing: confirm first unless he asked for that exact action.

## 1. Read the repo's rules first

Before writing anything, read:

- The PR template: `.github/pull_request_template.md` (or `.github/PULL_REQUEST_TEMPLATE/`, `docs/`)
- `CONTRIBUTING.md` and the repo's `AGENTS.md` PR section
- Two or three of the repo's recently merged PRs, for tone and level of detail

Note: title format (ticket prefix?), required sections, size limits, AI-disclosure markers, opt-out mechanisms.

## 2. Title

- Follow the repo's format (e.g. `AI-1234: short imperative summary`).
- Stack position in round brackets, never square: `(2/3)`, not `[2/3]`.

## 3. Description: use the template, cleaned

Use the repo's template as the skeleton, then strip everything that's there to guide the author. The result should be as clean and minimal as possible.

**Remove:**
- Every HTML comment: header, per-section guidance, footer notes (`<!-- ... -->`)
- Placeholder and example text, checklists meant for the author
- Optional sections with nothing to say, unless CI validates that they exist (sana-ai's `Validate PR description` requires every heading: keep it and write `None`)

**Keep:**
- Section headings, in the template's order and wording
- `None` where the template asks for it
- The AI-disclosure marker, if the template asks for one (the only HTML comment left)

**Write:**
- For the reviewer: plain, short, what they need to know. No agent jargon, no changelog of every file.
- What & why: a few sentences in Anton's voice. Problem first, then what the PR does about it. If it's hard to say briefly, flag that the PR may need a split.

sana-ai's template, cleaned, for a standalone non-UI PR:

```
## What & why

Two or three sentences.

## Related

[AI-1234: Ticket title](<linear url>)

## Behavior changes

None

## How to review

Start with `foo.ts`; the rest is renames.

## Visuals

None

<!-- AI disclosure marker -->
```

Reply to review comments only when Anton asks, and show the reply before posting.

## 4. Visuals and verification

Reviewers should see the result, not reconstruct it.

- **UI changes:** before/after screenshots or a short clip. Capture them yourself when you can (local app, Storybook, Playwright); save to `/tmp/pr-<n>/` with descriptive names and tell Anton which file goes where. `gh` can't upload images into a PR body, so Anton drags them in. Link the Figma/design if one exists.
- **Non-UI changes that are easier shown than told:** a diagram (Mermaid renders on GitHub), a before/after terminal output, a table of numbers.
- **Verification:** say how the change was verified, in the reviewer's terms: what was run, what was checked, what wasn't. E.g. "Ran the integration tests for meetings, notifications, discover and workspace; all green, one test still skipped (see comment)". If the template has no testing section, put it under "How to review".
- Only claim what was actually run. Say plainly what's unverified.

## 5. How to review

If the template has a "How to review" section (or the PR is bigger than trivial), guide the reviewer:

- Where to start (the one file or commit that carries the real logic).
- What's mechanical (renames, generated files, lockfile, moved code) vs. what needs thought.
- Whether to read commit by commit.
- What you're unsure about, or where you want a specific opinion.

Two or three lines. E.g. "Commits are focused. Start with `source-exports.ts`; manifest and tsconfig diffs are generated."

Before marking ready, self-review as the reviewer would: read the full diff on GitHub, check size against the repo's limit, CI green, bot review comments resolved or answered.

## 6. Stacks

Squash merges, slow CI, and approvals dismissed on push mean every rebase + push costs a CI run and a re-approval. Minimize them. Full rationale: `~/notes/Stacked PRs in sana-ai.md`.

### Branches

- Names: `an/<stack>/<index>/<slug>`, e.g. `an/page-int-tests/2/meetings`. `<stack>` is a made-up slug, not a ticket ID (PRs in a stack often have different tickets; the ticket goes in the title). With `wt`, pass `--branch`.
- Siblings on the same parent share an index. Never renumber or rename: that means a new PR. Gaps after merges are fine.
- Never create bare `an/<stack>` or `an/<stack>/<index>` branches (git ref conflict).

### PR bases

- Each PR targets the branch below it, not main, so its diff shows only its own commits.
- Never merge an upper PR into its parent branch.
- Every PR in a stack must be reviewable on its own.

### Stack list in the body

Put it in the template's Related section (plus any format the template asks for, e.g. "2/4, based on #456"). Update it in every PR of the stack when the stack changes.

```
This PR is part of a stack:
1. **[#123: do something](<url>)**
2. **#456: do something else** ↞ This PR
3. **[#823: do a third thing](<url>)**
```

Siblings on one parent nest under it:

```
This PR is part of a stack:
1. **[#7325: Prepare test:integration](<url>)**
2. Independent PRs on top of 1:
   - **[#7326: Migrate meetings tests](<url>)**
   - **#7327: Migrate notifications tests** ↞ This PR
```

### Rebasing and pushing

- Rebase from the top branch; `rebase.updateRefs` moves the rest. Push the stack in one go: `git push --force-with-lease origin <br1> <br2> ...`.
- Don't rebase onto main just to stay fresh. Only on conflict, or when the PR below has merged.
- Batch review fixes into one push per round. Put fixes on the right commit (`git commit --fixup <sha>` + autosquash).

### After the bottom PR squash-merges

1. `git fetch && git rebase --onto origin/main <merged branch> <top branch>`. Drops the squashed commits; if the local merged branch is gone, use the last commit of the merged PR instead.
2. Resolve conflicts against main. A file the branch deletes but main modified: check what main changed and whether it still matters for the replacement, then keep the deletion.
3. Verify: `git log --oneline origin/main..<top>` lists only unmerged PRs' commits. Run the affected tests.
4. `gh pr edit <next> --base main`, then push. Update the stack lists.
