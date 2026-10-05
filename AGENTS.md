## Git workflow in this repo

Edited from two laptops, often in sessions I don't come back to. Goal: no change ever lives only in a working tree or a side branch. These rules override the global git rules.

- Work directly on `main`. No branches, no worktrees.
- Before the first edit: `git pull --rebase --autostash`. If it fails or history has diverged, stop and tell me — don't edit on a stale base.
- Commit without asking: one small, focused commit per logical change, right after making it. Don't batch unrelated changes.
- Don't push without asking. When done, ask once: "push N commits?"
- Never reset, rebase away, or delete commits that aren't on `origin/main` without showing me what would be lost.
- Laptop-specific settings belong in gitignored local override files (e.g. `~/.zshrc.local`, `files/.config/lazygit/config-sana.yml`), not in shared config.
