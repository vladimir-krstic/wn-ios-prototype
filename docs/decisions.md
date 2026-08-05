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

## WN-PROTOTYPE-0008 — App Security

- Date: 2026-08-04
- Status: Approved

- Privacy & Security uses separate native Form sections for **Hide Screen in
  App Switcher** and **Require Face ID**, allowing each preference to carry its
  own concise explanation. **App Security** is their shared visible heading.
- Require Face ID uses device-owner authentication: Face ID first with the
  iPhone passcode as the system fallback. White Noise does not add a separate
  PIN. If no iPhone passcode is configured, Require Face ID is unavailable
  until that device requirement is resolved.
- Hide Screen in App Switcher covers the UIKit app snapshot. It does not claim
  to prevent screenshots or active screen recording.
- The prototype models these states deterministically and does not use
  LocalAuthentication or real snapshot replacement.
- Anonymous Telemetry and Audit Logging are developer controls and live in
  Developer Tools rather than Privacy & Security.

## WN-PROTOTYPE-0009 — Profile exit and local data removal

- Date: 2026-08-04
- Status: Approved

- A profile’s stored local data and its active signed-in session are separate.
  **Sign Out** ends the session but preserves the profile, chats, and settings
  on this device for a later sign-in.
- Settings exposes one neutral **Sign Out** action. It opens a native Form
  sheet whose **Wipe Data From This Device** Toggle is off by default. The
  sheet is the complete confirmation task; it doesn't stack a second alert or
  wipe sheet.
- With wiping off, the primary **Sign Out** action keeps local data. With
  wiping on, the same action becomes destructive and requires exact
  profile-name confirmation. Previous chats don't return after a later sign-in
  on this or another device.
- **Wipe All Profiles** uses a pushed review list followed by a native Form
  sheet requiring a generated three-word lowercase confirmation phrase. It
  removes every locally stored profile and returns to Welcome. Its neutral
  navigation row lives in Privacy & Security under **Device Data**, not in the
  Sign Out flow.
- Sign Out and Wipe All entry rows remain neutral. The Sign Out sheet uses the
  primary confirmation treatment whether local data is retained or wiped; the
  selected Toggle, exact-name gate, consequence copy, and accessibility label
  communicate the wipe. The final Wipe All confirmation remains red.
- Typed profile and all-profile wipe confirmations remain disabled until their
  required text matches.
- After a single-profile exit, the app presents the profile switcher as the root
  view when another signed-in profile remains and Welcome when none remain.
  Selecting a profile from either switcher opens Settings for that profile.
- The prototype models these outcomes deterministically in memory and performs
  no real authentication, persistence, cryptography, or remote account
  deletion.

## WN-PROTOTYPE-0010 — Unified single-profile and all-profile sign out

- Date: 2026-08-05
- Status: Approved; supersedes WN-PROTOTYPE-0009 only for the placement and
  presentation of device-wide sign out and wipe

- Settings keeps session-management actions together in one native section.
  **Sign Out** affects the active profile. **Sign Out All Profiles** appears as
  a separate sibling row only when multiple profiles are signed in.
- The two scopes are separate before presentation; no scope picker is embedded
  inside a destructive task.
- Sign Out All Profiles uses the same native Form-sheet model as single-profile
  Sign Out. **Wipe Data From This Device** starts off, so signing out all
  profiles preserves their local data and returns to Welcome.
- Enabling the wipe choice requires the deterministic three-word lowercase
  confirmation phrase. The final action uses the destructive role, removes
  every stored profile and its local data, and returns to Welcome.
- The previous **Wipe All Profiles** destination is removed from Privacy &
  Security. Sign Out is the single owner of both session scopes and their
  optional local-data removal.
- Wipe-enabled completion actions use the destructive role. Data-preserving
  sign-out actions use the primary role; all entry rows remain neutral.

## WN-PROTOTYPE-0011 — Separate profile sign out from app data erasure

- Date: 2026-08-05
- Status: Approved; supersedes WN-PROTOTYPE-0010 and the device-wide
  placement and presentation decisions in WN-PROTOTYPE-0009

- Settings exposes only **Sign Out** for the active profile. Its native Form
  sheet retains the optional **Wipe Data From This Device** choice and the
  existing current-profile routing behavior.
- Device-wide sign-out without erasure is unsupported. The app does not offer
  **Sign Out All Profiles**.
- Privacy & Security owns the uncommon, irreversible **Erase All App Data**
  action under **Device Data**. Its footer states that every profile is signed
  out and all local White Noise data is permanently removed from this iPhone.
- The action opens a native Form sheet with concise consequences, the stable
  three-word lowercase confirmation phrase, a **Confirmation phrase** field,
  **Cancel**, and a destructive **Erase Data** action. The destructive action
  remains disabled until the phrase matches exactly.
- The erasure flow does not show a profile list or a keep-data choice. Success
  removes every stored and signed-in profile, all profile-owned chats, media,
  drafts, keys, settings, and transient app state, then returns to Welcome.
- The entry and final action use the destructive role. **Erase Data** is not
  presented as a black primary action.

## WN-PROTOTYPE-0012 — Concise app data erasure warning

- Date: 2026-08-05
- Status: Approved; supersedes only the product label and consequence
  presentation in WN-PROTOTYPE-0011

- Privacy & Security and the confirmation sheet use **Erase App Data**. The
  consequence copy still states explicitly that every profile and all local
  White Noise data are removed.
- The confirmation sheet presents the irreversible consequence as a native
  warning callout with a semantic orange warning symbol, a primary **This
  can’t be undone** title, and secondary detail. The final **Erase Data** action
  remains destructive red and phrase-gated.

## WN-PROTOTYPE-0013 — Prominent app data erasure action

- Date: 2026-08-05
- Status: Approved; supersedes only the final action label and treatment in
  WN-PROTOTYPE-0011 and WN-PROTOTYPE-0012

- The confirmation sheet's final action is **Erase**.
- It uses the same native prominent red toolbar treatment as the wipe-enabled
  Sign Out action and remains disabled until the confirmation phrase matches.

## WN-PROTOTYPE-0014 — Stable destructive Sign Out treatment

- Date: 2026-08-05
- Status: Approved; supersedes the Sign Out default and action-color decisions
  in WN-PROTOTYPE-0009 through WN-PROTOTYPE-0011

- **Wipe Data From This Device** starts on in the Sign Out sheet.
- The final **Sign Out** action uses the same native prominent red toolbar
  treatment whether wiping is on or off. Changing the Toggle does not change
  the button's color or prominence.
- Wiping still requires the exact profile-name confirmation. Turning wiping
  off preserves local data and removes the confirmation field.

## WN-PROTOTYPE-0015 — Standard destructive toolbar actions

- Date: 2026-08-05
- Status: Approved; supersedes only the prominent visual treatment in
  WN-PROTOTYPE-0013 and WN-PROTOTYPE-0014

- **Sign Out** and **Erase** remain compact trailing toolbar actions. They are
  not duplicated as large buttons inside their Form sheets.
- Both actions use the native destructive role without a prominent button
  style, manual tint, or manual font weight. The system owns their
  regular-weight enabled-red and subdued disabled appearance.
- **Sign Out** keeps the same destructive treatment whether wiping is on or
  off. **Erase** and wipe-enabled **Sign Out** remain disabled until their
  confirmation input matches.
- A large in-sheet action was rejected because it would overemphasize an
  irreversible outcome and compete with the confirmation content.

## WN-PROTOTYPE-0016 — Full-width destructive sheet actions

- Date: 2026-08-05
- Status: Approved; supersedes WN-PROTOTYPE-0015 and only the final-action
  placement and visual treatment in WN-PROTOTYPE-0013 and WN-PROTOTYPE-0014

- **Sign Out** and **Erase** are full-width red destructive buttons at the
  bottom of their Form sheets. They are not trailing toolbar actions.
- Their labels use regular body weight rather than bold emphasis. Native
  `borderedProminent` buttons own control geometry, pressed behavior,
  accessibility, and disabled presentation.
- **Cancel** remains the only toolbar action in both sheets.
- Wipe-enabled **Sign Out** and **Erase** remain disabled until their required
  confirmation input matches. **Sign Out** keeps the same red destructive
  treatment when wiping is off.

## WN-PROTOTYPE-0017 — Large confirmation sheets with Close controls

- Date: 2026-08-05
- Status: Approved; supersedes only sheet detents, dismissal controls, and
  action-width details in WN-PROTOTYPE-0016

- Sign Out and Erase App Data always use the large sheet detent. They don't
  offer a compact medium presentation.
- A native leading `xmark` button is each sheet's sole toolbar action. The
  system toolbar supplies its Liquid Glass treatment; the app adds no custom
  background or geometry.
- Sign Out and Erase remove the standard Form row inset around their final
  actions so each visible destructive button spans the complete grouped
  content width.
- Profile-name confirmation uses local TextField state and native focus. Its
  enabled state updates directly as the person types the matching name.
