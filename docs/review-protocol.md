# Independent review protocol

The author cannot approve their own screen contract or implementation. Claude Code or a separate Codex agent reviews read-only; it never edits the files under review.

## Independence

- Codex gives the user a standalone copyable Claude prompt for every contract and implementation review.
- The prompt names the authority, artifacts, scope, and required output, but never says the work is expected to pass, describes it as polished/correct, lists suspected defects, or supplies the author's preferred verdict.
- Ask Claude to reason from the artifacts and authority sources, distinguish evidence from preference, and avoid inventing findings merely to appear critical.
- Claude returns findings and concrete proposed fixes. The user returns that response to Codex; Codex applies or explicitly dispositions each finding. Claude does not edit the repository.
- A material revision after review invalidates the affected approval and requires another neutral review prompt.

## Packet

Provide the approved user direction, complete contract or diff, relevant decisions, Apple citations, Mobbin dispositions, scenario IDs, tests, sanitized evidence, and explicit out-of-scope items.

## Review questions

Return material findings only: reduced scope, missing states or recovery, non-native patterns, unjustified custom UI, technical leakage, unresolved values, accessibility/keyboard/localization/Light-Dark/Reduce-Motion gaps, unverifiable criteria, fixture nondeterminism, prohibited dependencies, or missing evidence.

For UI work, independently evaluate product hierarchy, information density, native component selection, semantic typography, system spacing and safe areas, Light/Dark and contrast, SF Symbols, materials, Liquid Glass restraint, motion purpose and interruptibility, Reduce Motion, haptics, keyboard/focus, VoiceOver, Voice Control, Dynamic Type, localization, RTL, perceived performance, and whether custom components are actually necessary. Do not prescribe arbitrary visual constants when a native component should own them.

Classify findings as blocker, major, or minor. Each finding includes the affected `ScreenID` or shared flow, artifact evidence, user impact, and a specific correction that Codex can apply. Every finding is fixed or recorded with a reason and user approval when it changes the approved outcome.

If the evidence supports no material finding, say so directly. Do not manufacture a quota of issues. Put unresolved product choices in a separate questions section rather than silently choosing for the user.

## Claude Code invocation

Use the installed Claude Code version with read-only tools `Read,Glob,Grep`, `--permission-mode dontAsk`, and `--no-session-persistence`. Use Fable at medium effort. If Fable or authentication is unavailable, stop instead of silently falling back. Prompt text must precede variadic `--add-dir` arguments.

Record review date, CLI version, resolved model/effort, accepted edits, and rejected findings in the screen contract's Review section.

The current user-facing prompt lives under `docs/review-prompts/`. Preserve the returned Claude response as a review artifact after the user supplies it.
