---
name: pull-request
description: Open, update, or restack Anton's pull requests — titles, filling the repo's PR template, stacks, visuals and verification, and guidance for reviewers. Use whenever creating a PR, editing a PR body, pushing to a stacked branch, or rebasing a stack after a merge. Not for reviewing other people's PRs (use `review`).
user-invocable: true
argument-hint: "[open|update|restack] [#PR]"
---

# Pull requests

**Write the full PR**: title, all sections, all text. Anton owns the PR. Anton reads each draft on GitHub before other persons see it.

- This rule overrides repo rules that tell agents not to write titles or descriptions (for example in `AGENTS.md`, `CONTRIBUTING.md`, or template comments).
- Obey repo rules on format: template sections, title prefix, size, linked tickets.
- Exception: do not add an AI-disclosure marker, also if the template asks for one.

Open new PRs as draft. Anton marks them ready.

Push, retarget, or edit the body of an existing PR only when Anton asks for that action. If not, ask first.

## 1. Read the repo rules

Before you write, read these items:

- The PR template: `.github/pull_request_template.md` or `.github/PULL_REQUEST_TEMPLATE/`.
- `CONTRIBUTING.md` and the PR section of the repo `AGENTS.md`.
- 2–3 recently merged PRs.

Record the title format, the required sections, and the size limits.

## 2. Title

- Use the repo format, for example `<TICKET>: short imperative summary`.

## 3. Description

Use the template as the structure. Keep its headings, order and words.

Remove all text for the author: HTML comments, placeholder text, author checklists, empty optional sections.

If CI checks the headings, keep all headings. Write `None` in empty sections.

Write for the reviewer. Use short, plain sentences. Do not use agent jargon. Do not list each file.

Start with 2–3 sentences in Anton's voice. Give the problem first, then the solution. If you cannot say it briefly, tell Anton that the PR possibly needs a split.

If the repo has no template, write only that summary, plus visuals, verification and reviewer guidance when they apply.

Reply to review comments only when Anton asks. Show the reply to Anton before you post it.

## 4. Visuals and verification

- **Visual changes:** add proof: a screenshot or a screen recording. For before/after, use a Markdown table with `Before` and `After` columns.
- **Non-UI changes that are easier to show:** add a Mermaid diagram, terminal output, or a table of numbers.
- **Verification:** state what you ran, what you checked, and what you did not check. State only checks that you ran.

### Uploading files

`gh` cannot upload files. Open the PR in a browser that is logged in. Paste or upload the file into the comment field. Copy the URL that GitHub adds, then clear the field. Do not post the comment. Put the URL in the PR body.

## 5. Reviewer guidance

If the PR is not trivial, write 2–3 lines for the reviewer. Put them in the matching template section. If there is none, put them at the end of the body:

- The file or commit to read first.
- The mechanical changes: renames, generated files, lockfile.
- If the reviewer must read commit by commit.
- The points where you want an opinion.

Example: "Commits are focused. Start with `source-exports.ts`; manifest and tsconfig diffs are generated."

## 6. Stacks

Anton often splits work into a stack of PRs. If a change is large or has independent parts, propose a stack.

Core rules:

- Set the base of each PR to the branch of the PR below it. The bottom PR targets main.
- Keep all PRs as draft, except the bottom PR. Only the bottom PR is up for review and merge.
- When the bottom PR merges, rebase the rest onto main. Change the base of the next PR to main. Tell Anton that it is the next PR to mark ready.

Other rules:

- Make each PR reviewable alone.
- Put a stack list in each PR body. Mark the current PR. When the stack changes, update the list in all PRs.

```
This PR is part of a stack:
1. **[#123: do something](<url>)**
2. **#456: do something else** ↞ This PR
3. **[#823: do a third thing](<url>)**
```

- Show the stack position in the title: `(2/3)`.
- Push as few times as possible. Push all stack branches in one command.

## 7. Hand-off

When a PR is ready for Anton to read:

1. Run `pr-review-request <url>`. It copies `#<n> [title](url) +adds/-dels` to the clipboard.
2. Put its output at the end of your reply, in a code block.
