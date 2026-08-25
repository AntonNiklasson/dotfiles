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

## Workflow

- I prefer running dev servers and similar long-running processes in a separate tmux pane instead of you running it as a hidden background process. If you're in tmux, suggest either a new or existing pane to run the process in
