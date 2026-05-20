---
name: commit-history-cleanup
description: Reshape the commit history of the current branch / PR. Soft-reset back to the base branch so every change is staged as one blob, review it end-to-end, then split it into focused commits with clear messages. Invoke explicitly — not auto-triggered.
---

# commit-history-cleanup

Take a branch with messy history (WIP commits, fixups, "address review", out-of-order changes) and rewrite it as a tidy sequence of focused commits. Net diff vs. base is unchanged; only the commit boundaries move.

## North star: make the PR easy to review

The single goal is to make the PR understandable to a reviewer reading it commit-by-commit. Commit count, "cleanliness", and aesthetic tidiness are not goals — they're side effects of doing the real job: turning a blob of changes into a narrative the reviewer can follow.

Concretely, after the rewrite a reviewer should be able to:

- Read the commit subjects top-to-bottom and predict roughly what the PR does and in what order.
- Open any single commit and understand it without holding the rest of the diff in their head.
- Tell at a glance which commits are the *interesting* ones (real behaviour change) and which are noise (renames, formatting, generated files, lockfiles, mechanical refactors).
- Skip the noise commits with confidence and spend their attention on the substance.

Every decision below — chunk boundaries, ordering, what gets its own commit, what gets merged — is in service of that.

## Flow

### 1. Confirm scope and base

- Current branch: `git rev-parse --abbrev-ref HEAD`
- Base branch is usually `main`. Verify with `git merge-base --fork-point main HEAD` or just `git merge-base main HEAD`.
- Count commits being rewritten: `git log --oneline <base>..HEAD`
- If the branch is already pushed, note that the cleanup will require `git push --force-with-lease` afterwards. **Ask the human for confirmation before force-pushing.**

### 2. Safety net

Before rewriting, capture the current tip so it's recoverable:

```sh
git branch backup/$(git rev-parse --abbrev-ref HEAD)-$(date +%s)
```

Or just remember the SHA from `git rev-parse HEAD`. Reflog also keeps it for ~90 days but an explicit backup branch is cheap.

### 3. Soft reset to base

```sh
git reset --soft <base>     # e.g. main, or origin/main, or the merge-base SHA
```

Now: working tree unchanged, index unchanged, but `HEAD` points at base. Every change on the branch is staged.

### 4. Review the blob

```sh
git diff --cached --stat                 # files touched, +/- summary
git diff --cached                        # full diff
git diff --cached -- <path>              # one file at a time when the blob is big
```

Read everything once before deciding on chunks. Look for:

- **Mixed concerns** in one file (e.g. an unrelated rename alongside the real change) — these split at the hunk level, so the reviewer isn't decoding two things at once.
- **Refactor vs. behaviour change** — almost always belong in separate commits, refactor first. Reviewer reads the no-op move, then the real change against a stable baseline.
- **Dependency order** — if commit B won't build without commit A, A must come first.
- **Tests** — colocate with the code they cover unless tests stand alone.
- **Generated files / lockfiles / formatting / mass renames** — usually their own commit so the reviewer can skip them.

### 5. Plan the chunks

Write out the planned commits (subject lines) before staging anything. For each one, answer: "if a reviewer reads only this commit's subject + diff, will they understand it?" If two chunks have the same answer, merge them. If one chunk needs two answers, split it.

**"and" in a subject is a smell.** If the subject reads "do X and Y", that's usually two commits hiding as one. Try dropping the "and" — if the remaining half still describes the diff honestly, split. If both halves are genuinely one cohesive change ("rename and reflow `foo.ts`", "add user and admin endpoints"), leave it. The point is to force the question, not to ban the word.

Order the chunks the way you'd want a reviewer to encounter them: setup / refactors / mechanical noise first, the meaty behaviour change next, follow-ups (docs, tests that exercise the new behaviour) last. The PR should read like a story, not a checklist.

### 6. Stage and commit, chunk by chunk

Reset the index first so everything is unstaged but still in the working tree:

```sh
git reset                    # mixed reset — index cleared, working tree intact
```

Then for each planned commit:

```sh
git add <file>                       # whole file
git add -p <file>                    # hunk-by-hunk (use `s` to split, `e` to edit)
git diff --cached                    # verify what's about to be committed
# run formatter on the staged set — see §7
git commit -m "subject"              # or use a heredoc for body
git status                           # confirm remaining changes
```

Repeat until `git status` is clean.

**Do not commit without explicit approval.** Surface the planned commits for sign-off first, then execute.

### 7. Each commit must pass formatting

Hard rule: every commit must be formatter-clean on its own. Linting and tests are allowed to be red mid-sequence (they often depend on which chunks have landed), but formatting has no such excuse and `git bisect` should never land on an unformatted commit.

Workflow per chunk, before `git commit`:

1. Identify the formatter for the repo (e.g. `prettier`, `gofmt`, `ruff format`, `cargo fmt`, `biome format`, project-level `make fmt` / `npm run format`). Check `package.json` scripts, `Makefile`, pre-commit config, or recent commits for the canonical command.
2. Run the formatter against the **staged paths only** so untouched files don't get pulled in:
   ```sh
   git diff --cached --name-only --diff-filter=ACMR | xargs <formatter>
   ```
3. Re-stage any formatter-induced changes: `git add <same paths>`.

If a pre-commit hook enforces formatting and the commit fails: fix and re-stage, then make a **new** commit. Never `--amend` blindly during a rewrite — you'll lose track of where you are in the sequence.

### 8. Verify

```sh
git log --oneline <base>..HEAD                    # the new history
git diff <base>..HEAD --stat                      # should match step 4's stat
git diff <backup-branch>..HEAD                    # MUST be empty — net change preserved
```

The last check is the important one: if `git diff backup..HEAD` is non-empty, something was dropped or added. Investigate before pushing.

Then sanity-check from a reviewer's seat: read just the `git log --oneline` output. Does it tell a coherent story? If a subject is vague ("misc fixes", "updates") or you can't guess what's inside, rename or re-split before pushing.

### 9. Push (with confirmation)

```sh
git push --force-with-lease
```

Only after the human confirms. `--force-with-lease` (not `--force`) refuses to overwrite if the remote moved.

## Tips

- For one-line tweaks scattered across files, `git add -p` is the right tool — accept `y`/`n`/`s` (split)/`e` (edit hunk) per hunk.
- If a planned chunk turns out to need pieces from multiple files, stage them all before committing — don't make a separate commit per file just because the chunking command was per-file.
- If the soft reset reveals the branch is actually clean enough already, abort and `git reset --hard <original-sha>` (the backup branch or reflog SHA). No shame in doing nothing.
- If hunks are entangled (same hunk contains two concerns), use `git add -p` with `e` to edit the hunk, or `git stash -p` to set aside the part you don't want yet.
- For commits that need a body: `git commit -m "subject" -m "body"` or `git commit` (opens editor) — but prefer subject-only unless context is genuinely needed.
