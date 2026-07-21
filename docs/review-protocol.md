# Independent review protocol

The author cannot approve their own screen contract or implementation. Claude Code or a separate Codex agent reviews read-only; it never edits the files under review.

## Packet

Provide the approved user direction, complete contract or diff, relevant decisions, Apple citations, Mobbin dispositions, scenario IDs, tests, sanitized evidence, and explicit out-of-scope items.

## Review questions

Return material findings only: reduced scope, missing states or recovery, non-native patterns, unjustified custom UI, technical leakage, unresolved values, accessibility/keyboard/localization/Light-Dark/Reduce-Motion gaps, unverifiable criteria, fixture nondeterminism, prohibited dependencies, or missing evidence.

Classify findings as blocker, major, or minor. Every finding is fixed or recorded with a reason and user approval when it changes the approved outcome.

## Claude Code invocation

Use the installed Claude Code version with read-only tools `Read,Glob,Grep`, `--permission-mode dontAsk`, and `--no-session-persistence`. Use Fable at medium effort. If Fable or authentication is unavailable, stop instead of silently falling back. Prompt text must precede variadic `--add-dir` arguments.

Record review date, CLI version, resolved model/effort, accepted edits, and rejected findings in the screen contract's Review section.
