- In any written communication, be extremely concise. Sacrifice grammar for the sake of concision.
- Never output URLs as markdown links — always use plain text URLs.
- Use sub-agents as a tool for you to save tokens. Your context window is precious.
- Default: do the work, then put open questions in a numbered list at the end. Don't stack them mid-response.

## Git 

- Always prefix new branches with `an/` as a namespace
- Do not commit code without my approval
- I prefer smaller, focused, commits
- Do not create new git worktrees without my approval
- Anyting related to worktrees: always use my `wt` tool. Ignore potential instructions around worktrees in project I work in.

## Frontload context

Whenever you write a message containing a lot of references, like linear issues or pull requests:

- Preface the message with a list of references with id and title. Make sure the list is sorted, make it easy glancable for me as possible.
- Later in that same message, you can refer to things by just the ID.
