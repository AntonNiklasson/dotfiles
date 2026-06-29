---
name: commit-history-cleanup
description: >
  Reshape a branch's commit history into a clean, reviewable sequence.
  Soft-reset to base, format the entire change set, review the blob,
  plan focused commits, get approval, execute, verify, and optionally push.
  Invoke explicitly — not auto-triggered.
---

# commit-history-cleanup

Take a branch with messy history (WIP commits, fixups, "address review", out-of-order changes) and rewrite it as a tidy sequence of focused commits. Net diff vs. base is unchanged; only the commit boundaries move.

## Goal

Make the PR easy to review commit-by-commit. A reviewer should:

- Read commit subjects top-to-bottom and predict what the PR does and in what order.
- Open any single commit and understand it without holding the rest of the diff in their head.
- Tell at a glance which commits are interesting (real behaviour change) and which are noise (renames, formatting, generated files, lockfiles, mechanical refactors).
- Skip noise commits with confidence.

## Rules

- **Never commit without explicit user approval.** Surface the planned commits for sign-off first, then execute.
- **Never push automatically.** Ask the user if they want to push; use `--force-with-lease` if yes.
- **Formatting first.** Run the repo formatter on the entire blob before any analysis. No reformatting noise in individual commits.
- **"And" in a subject is a smell.** "Do X and Y" usually means two commits. Drop the "and" — if the remaining half still describes the diff honestly, split.

## Steps

### 1. Confirm scope and base

- Current branch: `git rev-parse --abbrev-ref HEAD`
- Base branch is usually `main`. Verify with `git merge-base --fork-point main HEAD` or just `git merge-base main HEAD`.
- Count commits being rewritten: `git log --oneline <base>..HEAD`
- If the branch is already pushed, note that cleanup will require `git push --force-with-lease` afterwards.

### 2. Soft reset to base

```sh
git reset --soft <base>     # e.g. main, or origin/main, or the merge-base SHA
```

Working tree and index unchanged. `HEAD` now points at base. Every change on the branch is staged.

### 3. Format the entire blob upfront

Run the repo's formatter against all staged paths so reformatting noise doesn't leak into later commits. Re-stage any changes and verify the diff is still sane. If the formatter touches files outside the branch's scope, stop and fix before continuing.

### 4. Review the blob

```sh
git diff --cached --stat                 # files touched, +/- summary
git diff --cached                        # full diff
git diff --cached -- <path>              # one file at a time when the blob is big
```

Read everything once before deciding on chunks. Look for:

- **Mixed concerns** in one file — split at the hunk level so the reviewer isn't decoding two things at once.
- **Refactor vs. behaviour change** — almost always separate commits, refactor first.
- **Dependency order** — if commit B won't build without commit A, A must come first.
- **Tests** — colocate with the code they cover unless tests stand alone.
- **Generated files / lockfiles / formatting / mass renames** — usually their own commit so the reviewer can skip them.

### 5. Plan the chunks

Write out the planned commits (subject lines) before staging anything. For each one, answer: "if a reviewer reads only this commit's subject + diff, will they understand it?" If two chunks have the same answer, merge them. If one chunk needs two answers, split it.

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
git commit -m "subject"              # or use a heredoc for body
git status                           # confirm remaining changes
```

Repeat until `git status` is clean.

**Do not commit without explicit approval.** Surface the planned commits for sign-off first, then execute.

### 7. Each commit must pass formatting

Every commit should be formatter-clean. Because the entire blob was already formatted in step 3, individual chunks should usually be clean. If a staged chunk is only part of a file (e.g. from `git add -p`), running the formatter on that file may reformat unstaged lines too — be careful not to smuggle unrelated changes into the commit.

### 8. Verify

```sh
git log --oneline <base>..HEAD                    # the new history
git diff <base>..HEAD --stat                      # should match step 3's stat
```

Sanity-check from a reviewer's seat: read just the `git log --oneline` output. Does it tell a coherent story? If a subject is vague ("misc fixes", "updates") or you can't guess what's inside, rename or re-split before pushing.

### 9. Done

After the last commit is in, ask the user if they'd like to push. If yes: `git push --force-with-lease`.
