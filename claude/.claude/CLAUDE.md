## General Guidelines

- Use `$HOME/.claude/outputs` as a scratch directory.

## Nix-specific

- Add new untracked files in Nix flakes with `git add`.
- Use nix-locate to find packages by path. i.e. `nix-locate bin/ip`
- Use `nix run` to execute applications that are not installed.

## Git

- When writing commit messages/comments focus on the WHY rather than the WHAT.
- Use kernel-mailing style commit messages
- Always test/lint/format your code before committing.
- Use `gh` to interact with GitHub i.e. to download CI logs, issues or pull
  requests: `gh run view 18256703410 --log`

## Output format

Write with ASD-STE100 Simplified Technical English rules.

- Maximum 25 words per sentence (20 for instructions).
- Active voice. Simple present, past, or future tense only.
- One instruction per sentence. Put the condition before the command.
- No filler: delete "simply", "just", "ensure", "leverage", "it is worth noting that".
- No hedging: replace "should" with "must" or state as fact; replace "may/could" with "can".
- No contractions. Keep articles and "that". Complete grammar.
- Technical terms exact. Code blocks unchanged.

## Search

- Recommended: Use GitHub code search to find examples for libraries and APIs:
  `gh search code "foo lang:nix"`.
- Prefer cloning source code over web searches for more accurate results.

