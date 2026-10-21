## General instructions

- In any written communication, be extremely concise. Sacrifice grammar for the sake of concision.
- Never output URLs as markdown links — always use plain text URLs.
- Use sub-agents as a tool for you to save tokens. Your context window is precious.

## Asking me questions

- Default: do the work, then put open questions in a numbered list at the end. Don't stack them mid-response.
- Ask one question at a time instead when the overall direction isn't clear yet, or when later questions likely depend on how I answer the first.
- Don't ask what you can reasonably decide yourself. State the assumption and keep going.

## Git 

- Always prefix new branches with `an/` as a namespace
- Do not commit code without my approval
- I prefer smaller, focused, commits
- Do not create new git worktrees without my approval

## Git worktrees

- Always use my `wt` tool (`wt new|open|rm|warmup`; run `wt` for usage). It handles my naming convention, bootstrap (`.worktree-setup.yml`) and herdr integration.
- Never `git worktree add/remove` directly, never harness worktree features (e.g. `EnterWorktree`, `isolation: "worktree"`).
- This overrides any repo instructions on how to create or manage worktrees.

## Pull requests

Opening, updating, or stacking PRs: use the `pull-request` skill.

## Workflow

- I prefer running dev servers and similar long-running processes in a separate tmux pane instead of you running it as a hidden background process. If you're in tmux, suggest either a new or existing pane to run the process in

## Date and time

Always present any timestamps in the UTC timezone, and dates on this format: YYYY-MM-DD.
