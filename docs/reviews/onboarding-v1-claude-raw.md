# Onboarding v1 contract packet — independent review

**Reviewer basis:** repository artifacts at commit `d9c9f3a`; Apple sources per `docs/references/apple.md`; product authority per `docs/product-language.md`, `docs/decisions.md`, and the approved issue drafts in `../wn-ios-agile/drafts/2026-07-20/` (read-only, verified against the ledger mapping to #827–#832). One packet-listed file, `docs/native-design.md`, does not exist; I used `docs/design-system.md`, which carries the intended content (see WN-ONB-013).

## 1. Verdict

**Not ready for approval as written.** The packet's scope, navigation, component selection, custom-UI restraint, sensitive-data boundaries, and copy discipline are strong and faithful to both the Apple sources and the approved White Noise direction. However, one blocker and six major findings prevent approval: the deterministic fixtures every contract depends on are documented nowhere, the Welcome contract names a scenario that does not exist in the registry, the Sign In validation trigger cannot be implemented coherently as specified, two required scenario classes are missing from the QR registry coverage, the Sign Up progress copy contradicts the very issue the contract cites for it, and the asset manifest's Dark logomark URL is corrupted. All are correctable with bounded edits; nothing structural needs rework.

## 2. Material findings

### Blocker

**WN-ONB-001 — The "cataloged" onboarding fixtures do not exist in any document.**
- **Affected:** shared flow; `onboarding.sign-in`; `onboarding.qr-scanner`; `onboarding.sign-up`.
- **Evidence:** `docs/screen-contracts/onboarding-sign-in.md:55` ("the cataloged fictional valid fixture"), `onboarding-sign-in.md:29` (fixture classifications), `docs/flows/onboarding.md:38` ("payloads from the documented fictional universe"), `docs/screen-contracts/onboarding-qr-scanner.md:59` ("resolving to an approved fictional fixture"), `docs/screen-contracts/onboarding-sign-up.md:57` ("its documented deterministic default name"). `docs/fictional-universe.md` contains only people and chats — no credential fixtures, no `wnproto` fixture IDs, no created-Profile fixture, no default name. `docs/scenarios.md:5` requires every scenario to fix profile state and outcomes.
- **Why it matters:** the packet's determinism, safety, and testability claims all rest on documents that don't exist. The reviewer (and the user at approval) cannot verify that fixture values are safely fictional, which Profile a successful Sign In activates, or what name an empty-Name Sign Up produces — all user-visible product outcomes.
- **Correction:** add an "Onboarding fixtures" section to `docs/fictional-universe.md` defining, with fixed IDs and values: the accepted Sign In fixture and the Profile it activates; the invalid fixture; the existing-Profile fixture and which seeded Profile it matches; the valid and invalid `wnproto://private-key/<fixture-id>` payloads; and the Sign Up created-Profile fixture (ID, deterministic default display name when Name is empty, monogram initials). Then reference those exact fixture IDs from each contract's state table. Fixture values stay out of product UI per the existing constraints.

### Major

**WN-ONB-002 — Welcome references a scenario ID that does not exist.**
- **Affected:** `onboarding.welcome`.
- **Evidence:** `docs/screen-contracts/onboarding-welcome.md:16` and `:67` name `welcome-default`; the registry (`docs/catalogs/scenarios.json:5`) and Swift enum (`WhiteNoisePrototype/Foundation/ScenarioID.swift:2`) define `onboarding.welcome.default`. `docs/scenarios.md:3` requires exact matching, and `WhiteNoisePrototype/Foundation/LaunchConfiguration.swift:30` makes an unknown `-WNScenario` value a precondition failure — a test launched from the contract as written crashes by design. The validator checks Swift↔catalog parity but not contract text, so this passes silently.
- **Correction:** replace both occurrences with `onboarding.welcome.default`.

**WN-ONB-003 — Sign In's invalid-classification trigger is undefined and the Return-key rule is circular.**
- **Affected:** `onboarding.sign-in`.
- **Evidence:** `docs/screen-contracts/onboarding-sign-in.md:57` (invalid state), `:64` ("Arbitrary manually entered content can only reach the invalid UI state"), `:72` ("Hardware Return submits only when the fictional state is accepted"). The approved source (#828, `redesign-identity-import-login.md`) triggers validation "when the field reaches the complete plausible shape" via bech32 checksum — a mechanism the flow explicitly prohibits (`docs/flows/onboarding.md:36`: no key parsing or checksum validation) — and the contract defines no deterministic replacement.
- **Why it matters:** as written, an implementer can defensibly show "That private key isn't valid" from the first keystroke (hostile), or never show it for typed content (contradicting line 64). The enable/validate/submit loop cannot be built coherently.
- **Correction:** add a classification-trigger clause to Actions and deterministic states: all cataloged credential fixtures share one documented fixed length (define it with WN-ONB-001); classification evaluates on every change; content shorter than that length stays neutral (helper visible, Sign In disabled); content at full length classifies by exact fixture equality into accepted, existing-Profile, or invalid; editing or Clear returns to neutral; Return attempts submission only while Sign In is enabled. This reproduces #828's validate-on-complete model without parsing. (`APPLE-INPUT-003` governs the focus/error-recovery behavior already specified.)

**WN-ONB-004 — The QR valid-scan return has no ScenarioID despite being claimed as scenario coverage.**
- **Affected:** `onboarding.qr-scanner`; shared flow.
- **Evidence:** `docs/flows/onboarding.md:54` lists "deterministic valid-code return" under Scenario coverage; `docs/screen-contracts/onboarding-qr-scanner.md:57` defines "Simulated valid result" with no state ID; `docs/catalogs/scenarios.json:14-19` contains no valid-scan scenario. QR acceptance criterion 7 ("UI tests cover every simulated state") and Sign In criterion 7 ("QR return") therefore have no launchable registry entry for the screen's core success path.
- **Correction (preferred):** add `onboarding.qr.valid-code` (`screen: onboarding.qr-scanner`, `class: populated`, `systemMode: simulated`) to `docs/catalogs/scenarios.json` and `ScenarioID.swift`, seeding a fixed-delay deterministic valid emission, and give the contract row that ID. Alternative: amend the flow bullet and both contracts to state the valid return is exercised via the test-only emission inside `onboarding.qr.ready` under `-WNUITesting` — but then remove it from the flow's "Scenario coverage" list.

**WN-ONB-005 — QR Scanner has no accessibility-stress state or scenario.**
- **Affected:** `onboarding.qr-scanner`.
- **Evidence:** Sign In and Sign Up each define an accessibility-stress state and scenario (`docs/catalogs/scenarios.json:13`, `:26`); QR has none, yet its contract demands Dynamic Type reflow, localization expansion, and RTL over the camera surface (`docs/screen-contracts/onboarding-qr-scanner.md:66`) and acceptance criterion 6 requires large-text/localization/RTL representations. `docs/scenarios.md:14` lists these stress classes as required. The scanner's error/recovery layouts are the densest text-over-camera compositions in the packet — exactly where clipping appears.
- **Correction:** add `onboarding.qr.accessibility-stress` (`class: accessibility`, `systemMode: simulated`) to the registry and Swift enum, and a matching contract state row mirroring the siblings — largest accessibility Dynamic Type, Bold Text, Increased Contrast, localization expansion, and RTL over the simulated scanner surface with a dense recovery state active (camera-error is the natural choice). (`APPLE-A11Y-003` governs the stress behavior.)

**WN-ONB-006 — Sign Up progress copy contradicts the issue the contract cites for it.**
- **Affected:** `onboarding.sign-up`.
- **Evidence:** `docs/screen-contracts/onboarding-sign-up.md:43` specifies **Creating Profile…** while `:100` claims #832 supplies the progress language — but #832's Creating state specifies **Signing Up…**. Meanwhile `docs/product-language.md:20` lists **Creating Profile…** as an example. Two product authorities conflict, and the contract silently misattributes its choice.
- **Why it matters:** this is user-visible copy in the approval decision, and the contract's evidence chain is currently false.
- **Correction:** resolve explicitly (see Question Q1). My recommendation is **Signing Up…** — it follows the "progress uses the action" rule literally (the action is **Sign Up**), matches **Signing In…** across the flow, and is faithful to the screen-specific approved issue; if the owner keeps **Creating Profile…**, record the deviation from #832 in the contract's White Noise direction section.

**WN-ONB-007 — The asset manifest's Dark logomark URL is corrupted.**
- **Affected:** `onboarding.welcome` (asset blocker).
- **Evidence:** `docs/assets.md:8` ends `…30e3fb6072`; the contract (`docs/screen-contracts/onboarding-welcome.md:97`) and issue #830's supplied-assets list both end `…30e3fbdb6072`. The manifest URL is missing `db` and is not a well-formed asset UUID.
- **Why it matters:** the Welcome approval gate makes correct retrieval and provenance of these two files an explicit blocker; a corrupted manifest URL stalls or mis-sources the packet's only custom visual.
- **Correction:** fix `docs/assets.md:8` to `https://github.com/user-attachments/assets/1bd78fac-3d62-4bd8-90a5-30e3fbdb6072`.

### Minor

**WN-ONB-008 — Welcome's VoiceOver order omits the logomark it declares an accessibility element.**
- **Affected:** `onboarding.welcome`. **Evidence:** `docs/screen-contracts/onboarding-welcome.md:53-54` states the order is "**Login**, then **Sign Up**" yet gives the logomark the label **White Noise** — making it a focusable element whose position is unspecified. **Correction:** state the full order: **White Noise** (image), **Login**, **Sign Up**. (`APPLE-A11Y-001`.)

**WN-ONB-009 — Welcome drops the approved logo-scale anchor, leaving "visually prominent" unverifiable.**
- **Affected:** `onboarding.welcome`. **Evidence:** `docs/screen-contracts/onboarding-welcome.md:27` says only "visually prominent without crowding the actions"; approved #830 specifies "roughly two-thirds of compact-screen width." This is approved product direction, not an invented constant. **Correction:** quote #830's sizing rule in Native composition (portrait-iPhone scope only) so acceptance criterion 6 has something to check.

**WN-ONB-010 — QR merges #829's distinct no-camera copy without recording the deviation.**
- **Affected:** `onboarding.qr-scanner`. **Evidence:** `docs/screen-contracts/onboarding-qr-scanner.md:40` and `:54` fold "no camera" into the unsupported copy; #829 defines separate copy: "This device doesn't have a camera available. Enter your private key instead." **Correction:** either add the no-camera row, or (reasonable for an iPhone-only prototype where the state is simulator-only) add one sentence to the White Noise direction section recording the deliberate merge. AGENTS.md requires material deviations to be recorded.

**WN-ONB-011 — Sign Up failure presentation is unspecified.**
- **Affected:** `onboarding.sign-up`. **Evidence:** `docs/screen-contracts/onboarding-sign-up.md:63-64` says "show creation failure with **Retry** and **Back**" without saying whether this is inline text or an alert; **Back** could be misread as a duplicated in-content button beside the system Back. #832 supplies labels, not presentation. **Correction:** specify inline error text adjacent to the primary action (per `docs/product-language.md` failure rules and design-system "feedback near the initiating action"), with **Retry** as the adjacent button and **Back** naming the standard navigation-bar action; partial-save shows its copy inline with **Retry** and **Continue** buttons.

**WN-ONB-012 — Sign Up's stated VoiceOver order contradicts its own footer placement.**
- **Affected:** `onboarding.sign-up`. **Evidence:** `docs/screen-contracts/onboarding-sign-up.md:26` places the public-avatar disclosure as a section footer (native order: rows, then footer) while `:72` demands "avatar preview, avatar disclosure, avatar actions." **Correction:** reorder the VoiceOver expectation to preview → actions → disclosure to match native Form footer semantics; #831 only requires the disclosure be visible before Photos opens, which a footer satisfies. (`APPLE-A11Y-001`.)

**WN-ONB-013 — The reusable review prompt names a nonexistent authority file.**
- **Affected:** shared workflow. **Evidence:** `docs/review-prompts/onboarding-v1-claude.md:18` lists `docs/native-design.md`; the file is `docs/design-system.md`. **Correction:** update the path in the review prompt (or rename the file, updating any other references — none exist today).

**WN-ONB-014 — Contracts have nowhere to record this review's disposition.**
- **Affected:** all four contracts. **Evidence:** `docs/review-protocol.md:31` requires recording review date, CLI version, model, and dispositions "in the screen contract's Review section"; `docs/screen-contracts/TEMPLATE.md:44` defines it; none of the four onboarding contracts include one. **Correction:** append a `## Review` placeholder section to each contract.

## 3. Cross-screen consistency fixes

1. **Fixture registry (WN-ONB-001)** spans all four contracts — fix once in `docs/fictional-universe.md`, then reference consistently, so Sign In's accepted fixture, the QR payload that produces it, and the seeded Profiles agree by construction.
2. **Progress-copy symmetry (WN-ONB-006):** whichever term the owner picks, **Signing In…** and the Sign Up progress term should follow the same formation rule; today the flow mixes action-based and result-based progress.
3. **Registry parity hardening (optional):** after WN-ONB-002/004/005, every dotted state ID in a contract corresponds to a catalog ScenarioID. Codex could cheaply extend `scripts/validate-foundation.sh` to check that dotted `onboarding.*` state IDs appearing in contracts exist in `docs/catalogs/scenarios.json` — the class of error in WN-ONB-002 is currently invisible to automation.

## 4. Questions for the product owner

- **Q1 (WN-ONB-006):** For Sign Up progress, **Signing Up…** (per approved issue #832, symmetric with Signing In…) or **Creating Profile…** (per the example list in `docs/product-language.md`)? The chosen answer should also correct the losing document.
- **Q2 (WN-ONB-001):** Two user-visible fixture identities need your decision before the fixture registry can be written: (a) which fictional Profile a successful Sign In activates (Maya Chen, the documented default active profile, is the natural candidate); and (b) the deterministic default display name a Sign Up with an empty Name receives (the prototype stand-in for the engine-generated name in #832).

## 5. No-finding areas

- **Component selection and custom-UI restraint:** NavigationStack, Form, SecureField, FocusState, PhotosPicker, `DataScannerViewController`, native ProgressView, and system permission behavior are the right choices and correctly cited. The three custom compositions (logomark, scanner guidance overlay, circular avatar preview) are justified, minimal, and match the approved exceptions — and the prototype correctly declines #828's custom `UITextField` paste-interception wrapper, which only makes sense with real clipboard credentials.
- **Sensitive-data boundaries:** scrub points, privacy-sensitive marking, no-logging rules, launch-argument state injection instead of typing key-shaped strings in UI tests, and the QR payload allowlist are thorough and consistent with #828/#829. I verified rather than re-litigated the deliberately strict choices (no reveal control; scrub-on-failure returning to empty) — both are verbatim approved direction.
- **Scope and navigation:** the packet matches decision WN-PROTOTYPE-0006 exactly — no stored-profile chooser, QR returns to Sign In without auto-submitting, success replaces onboarding, and the `chats.list` gate is not bypassed.
- **Copy and terminology:** Login/Sign In/Sign Up usage is consistent with `docs/product-language.md` across all four contracts; no team terminology, scheme names, or fixture IDs leak into product or accessibility output.
- **Mobbin discipline:** two focused comparisons per screen, each with dates, capture sizes, and explicit accepted/rejected lessons; nothing copied.
