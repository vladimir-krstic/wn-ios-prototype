# Decisions

This file records only material decisions that continue to govern the prototype.

## WN-PROTOTYPE-0001 — Minimal clean restart

- Date: 2026-07-23
- Status: Approved

The repository is a fast native iPhone prototype workspace. It started with a clean development placeholder and builds one user-agreed screen or tightly related flow at a time. WN-PROTOTYPE-0002 supersedes the original per-batch build and inspection cadence below.

- Native Apple components and APIs are the default.
- Each selected screen gets one concise brief; future screens are not predesigned.
- Architecture, state, fixtures, permissions, assets, and tests are introduced only when current work needs them.
- Every batch is built, previewed, launched, and inspected directly by the user.
- The user alone accepts product and visual results.
- Claude is never invoked automatically; a neutral prompt is supplied only when the user requests a major review.
- Existing Git history is preserved. The pre-reset working tree was archived outside the repository before cleanup.

## WN-PROTOTYPE-0002 — Fast iteration and inspection workflow

- Date: 2026-07-30
- Status: Approved

The prototype now contains implemented product flows, but the clean-restart
working style remains authoritative.

- Work on one user-agreed screen or bounded flow at a time.
- Screen briefs record durable accepted decisions rather than every iteration.
- Small changes use static validation; build once at the end of a meaningful
  batch.
- Device Hub inspection occurs only when requested or explicitly approved.
- The iPhone Air running iOS 27 is the single default inspection device. Reuse
  it rather than booting another simulator.
- Never claim visual verification without inspecting the current build.
- The user alone accepts visual and product results.
- Claude and Fable are manual major-batch reviewers only.

## WN-PROTOTYPE-0003 — Consolidate only proven duplication

- Date: 2026-07-30
- Status: Approved

- Keep the empty unit-test target and its tracked `.gitkeep` as a normal Xcode
  project placeholder; add a test only when meaningful nonvisual logic
  justifies one.
- Keep mutable chat state with its owning profile so list actions and profile
  unread badges share one source of truth.
- Use one shared profile-avatar renderer, one QR-image generator, and one
  physical VisionKit scanner after repeated implementations proved those
  abstractions necessary.
- Bundle profile imagery at a maximum 512-pixel dimension. Preserve the
  scanner backdrop dimensions while using efficient photographic compression.
- Raw public-key QR values and key-shaped export fixtures must not expose
  prototype terminology through shareable product surfaces.

## WN-PROTOTYPE-0004 — Self-contained project knowledge

- Date: 2026-07-31
- Status: Approved

- All White Noise product knowledge, terminology, screen requirements,
  decisions, and workflow rules required for normal work live in this
  repository.
- Do not read, invoke, or depend on project-specific files, source code,
  instructions, or skills from another local project unless the user explicitly
  requests a bounded cross-project investigation.
- Current official Apple design and developer documentation is an intentional
  live authority. Use `docs/references/apple.md` to open the relevant source
  before a material platform decision and apply
  `docs/references/native-ui.md` when evaluating the result.
- The user’s latest direction outranks Apple’s default pattern. Record an
  approved exception in the selected screen brief.
- User-supplied Figma links, GitHub issues, shipped-app examples, and asset
  sources may remain as optional provenance or comparison evidence, but no
  implementation may require them.

## WN-PROTOTYPE-0005 — Per-profile relay roles

- Date: 2026-08-03
- Status: Approved

- Each profile owns an independent union list of configured relay endpoints.
- Ordinary Settings shows that single list. Relay Details assigns any capable
  relay to one or more human-facing roles: **Profile**, **Inbox**, and **Chat
  Messages**. The main list summarizes those assignments with semantic role
  symbols so a separate Advanced destination is unnecessary.
- **Profile** represents the account relay behavior used to publish profile and
  connection information. Key-package publication uses the appropriate
  profile-relay behavior internally and is not a fourth product setting.
- **Inbox** receives invitations to new chats and groups.
- **Chat Messages** is the per-profile default relay set copied into chats that
  profile creates. Existing chats retain their signed routing, and incoming
  chats carry their own routing. Per-chat editing is a separate future flow.
- At least one capable relay remains assigned to every role. Read-only relays
  can remain configured but cannot be assigned to these write-requiring roles.
- A new relay’s roles are chosen before it becomes active and default to all
  three. Initial onboarding relay selection remains a future requirement.
- The production transport layer currently accepts default group-routing
  relays at process construction. Production translation therefore requires a
  per-profile default-routing input or public setter; this local decision is
  complete and does not require access to another repository.

## WN-PROTOTYPE-0006 — Relay Details owns removal

- Date: 2026-08-03
- Status: Approved

- The main Relays list is a quiet two-line endpoint overview. It has no Edit
  mode, inline role controls, or swipe-to-delete behavior.
- Every relay row opens Relay Details. That destination owns the three role
  toggles and a destructive **Remove Relay** action at the bottom.
- Removal always requires the native consequence-aware confirmation. A normal
  removal says that this profile will stop using the relay; a removal that
  empties roles also names the capabilities that become unavailable.
- **Add Relay** remains directly available from the main list.

## WN-PROTOTYPE-0007 — Relay degraded mode and recovery

- Date: 2026-08-03
- Status: Approved; supersedes the minimum-role invariant in
  WN-PROTOTYPE-0005

- A person may intentionally leave **Profile**, **Inbox**, or **Chat Messages**
  without a relay. Relay choices belong to the active profile; leaving a role
  empty never assigns that profile to an unwanted endpoint.
- Assignment alone does not make a role operational. A role is **Available**
  only while at least one assigned read/write relay is connected. Otherwise it
  is **Reconnecting**, **Disconnected**, or **Unassigned**. Read-only relays
  never satisfy availability.
- Every unavailable state degrades only the role's dependent capability:
  Profile editing is unavailable without an available Profile relay,
  invitations cannot arrive without an available Inbox relay, and new chats
  cannot be created without an available Chat Messages relay. A connected
  sibling relay keeps the role available when another assigned relay fails.
  Existing chats keep their own routing and history remains available; while
  any profile relay role is unavailable, the empty Fiatjaf composer
  prioritizes the direct recovery route.
- Turning off the final relay for a role and removing a relay that empties a
  role are allowed after a native consequence-aware confirmation.
- Relays owns the complete recovery explanation through its inline status
  callout. While setup needs attention, Chats replaces its New Message toolbar
  symbol with a compact outlined orange warning, and an open conversation uses
  its complete empty composer as the same recovery link. Both push the active
  profile's Relays destination; the native Back action returns to the
  originating screen. Other signed-in destinations don't repeat the warning.
- Relay connection feedback uses green for Connected, a neutral spinner for
  Reconnecting, and red for Disconnected. The user approved red as the clearer
  concrete endpoint-failure status even though the condition is recoverable.
  Aggregate recovery links and callouts remain orange so they read as guidance
  rather than destructive actions or field validation. Symbols, text, and
  accessibility values carry the meaning without relying on color.
- **Restore Default Relays** performs a confirmed full reset for the active
  profile. It removes custom endpoints and restores the original seven-relay
  list and role assignments.
