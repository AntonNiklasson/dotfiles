- In any written communication, be extremely concise. Sacrifice grammar for the sake of concision.
- Never output URLs as markdown links — always use plain text URLs. Exception: "open" links in the reference list (see "Frontload context").
- Use sub-agents as a tool for you to save tokens. Your context window is precious.
- Default: do the work, then put open questions in a numbered list at the end. Don't stack them mid-response.

## Writing style: ASD-STE100 (Simplified Technical English)

Base prose on ASD-STE100 principles. Concision rule above still wins.

- One word, one meaning. Pick a term, keep it. No synonyms for variety.
- Short sentences: instructions ≤20 words, descriptions ≤25.
- One instruction per sentence. Imperative mood ("Run X", not "You should run X").
- Active voice. Name the actor.
- Simple verb tenses: present, past, future. No "would have been".
- No phrasal verbs when a single verb exists ("start" not "kick off", "remove" not "get rid of").
- Concrete over vague. No hedging filler ("basically", "essentially", "it seems").
- Put conditions first: "If tests fail, check X."
- Code identifiers, commands, paths: keep exact, in backticks. STE vocabulary limits don't apply to them.

## Git 

- Always prefix new branches with `an/` as a namespace
- Do not commit code without my approval
- I prefer smaller, focused, commits

## Pull requests

- In any repo: before you open or update a PR, load the `pull-request` skill and follow it.

## GitHub comments

- Mark every comment you post on GitHub as AI-written. Applies to PR/issue comments, review bodies, inline review comments, replies.
- End the body with a blank line, then this exact footer: `<sub>This comment was authored by Anton's agent.</sub>`
- Don't apply to PR descriptions or commit messages.

## Frontload context

Whenever you write a message containing a lot of references, like linear issues or pull requests:

- Preface the message with a list of references with id and title. Make sure the list is sorted, make it easy glancable for me as possible.
- End each list item with a markdown link labeled "open" that points to the item URL. Example: `- #123 Fix login bug [open](https://github.com/org/repo/pull/123)`. This is the one exception to the "no markdown links" rule.
- Later in that same message, you can refer to things by just the ID.
