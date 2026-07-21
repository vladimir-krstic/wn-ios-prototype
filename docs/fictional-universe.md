# Fictional universe

The house cast is stable across every screen and scenario. All names, relationships, messages, files, keys, and identifiers are fictional.

## Core cast

| ID | Name | Role in fixtures | Avatar |
|---|---|---|---|
| person.maya | Maya Chen | Default active profile; photographer and weekend hiker | Open Peeps asset planned |
| person.noor | Noor Haddad | Close friend; direct-chat long-form writer | Initials |
| person.luca | Luca Petrović | Project collaborator; file and reaction scenarios | Open Peeps asset planned |
| person.priya | Priya Shah | Group administrator; notification scenarios | Open Peeps asset planned |
| person.eli | Eli Okafor | Voice-message and media scenarios | Initials |
| person.sofia | Sofia Alvarez | New recipient and QR scenarios | Open Peeps asset planned |
| person.jordan | Jordan Kim | Archived and unread scenarios | Initials |
| person.ines | Ines Laurent | Permission and recovery walkthrough partner | Open Peeps asset planned |

## Stable chats

- Maya + Noor: ordinary daily planning, a long message, reply, reaction, edit history, and failed-send recovery.
- Weekend Hike: Maya, Noor, Eli, Sofia; photos, location prose without live maps, voice message, membership event.
- Studio Notes: Maya, Luca, Priya, Jordan; files, Markdown, mentions, retention and notification settings.
- Maya + Jordan: archived and unread variants.

Content must feel lived-in without using real people, organizations, addresses, credentials, or sensitive topics.

## Onboarding fixtures

`docs/catalogs/onboarding-fixtures.json` is the machine-readable source. The values below are conspicuously fictional test tokens, not real Private Keys. They may appear in team documentation and test code only; product UI, screenshots, accessibility output, logs, and diagnostics never reveal them.

All complete credential tokens contain exactly 32 characters so Sign In can reproduce a deterministic validate-on-completion interaction without parsing, checksums, authentication, or cryptography.

| FixtureID | Fixed value or identity | Deterministic outcome |
|---|---|---|
| `credential.maya.accepted` | `WNPROTO-ACCEPTED-MAYA-0000000001` | Accepted Sign In activates `profile.maya`, Maya Chen. |
| `credential.maya.existing` | `WNPROTO-EXISTING-MAYA-0000000001` | Existing-Profile recovery resolves to the already seeded `profile.maya`; it cannot create a duplicate. |
| `credential.invalid.complete` | `WNPROTO-INVALID-INPUT-0000000001` | Completed invalid entry remains masked and produces inline invalid feedback. |
| `qr.private-key.maya.accepted` | `wnproto://private-key/credential.maya.accepted` | Valid simulated scan returns the accepted Maya classification to Sign In without submitting. |
| `qr.private-key.unknown` | `wnproto://private-key/credential.unknown` | Unknown fixture ID remains on the scanner and produces invalid-code recovery. |
| `profile.quiet-pine` | Person `person.quiet-pine`; display name **Quiet Pine**; initials **QP**; empty About; no avatar | Empty-Name Sign Up creates this Profile exactly once in process memory. |

The accepted and existing-Profile credential fixtures are deliberately separate scenario tokens even though both resolve to Maya. Exact fixture equality, not real credential semantics, determines the simulated outcome.
