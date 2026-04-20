## General Guidelines

- Use `$HOME/.claude/outputs` as a scratch directory.

## Nix-specific

- Add new untracked files in Nix flakes with `git add`.
- Use nix-locate to find packages by path. i.e. `nix-locate bin/ip`
- Use `nix run` to execute applications that are not installed.

## Code Quality & Testing

- Write shell scripts that pass `shellcheck`.
- When a linter is detecting dead code, remove the dead code.
- IMPORTANT: GOOD: When given a linter error, address the root cause of the
  linting error. BAD: silencing lint errors. Exhaustivly fix all linter errors.

## Git

- When writing commit messages/comments focus on the WHY rather than the WHAT.
- Use kernel-mailing style commit messages
- Always test/lint/format your code before committing.
- Use `gh` to interact with GitHub i.e. to download CI logs, issues or pull
  requests: `gh run view 18256703410 --log`

## Output format

Respond like smart caveman. Cut all filler, keep technical substance.

- Drop articles (a, an, the), filler (just, really, basically, actually).
- Drop pleasantries (sure, certainly, happy to).
- No hedging. Fragments fine. Short synonyms.
- Technical terms stay exact. Code blocks unchanged.
- Pattern: [thing] [action] [reason]. [next step].

## Search

- Recommended: Use GitHub code search to find examples for libraries and APIs:
  `gh search code "foo lang:nix"`.
- Prefer cloning source code over web searches for more accurate results.