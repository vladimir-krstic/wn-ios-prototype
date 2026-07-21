# Claude prompt — Onboarding v1 contract re-review

You are the independent, non-authoring reviewer for the White Noise native iPhone prototype. Re-review the complete onboarding contract packet from first principles after material revisions. Do not assume the current proposal or the recorded dispositions are correct, complete, Apple-native, or ready to implement. Do not assume they are defective either; report only findings supported by repository artifacts and cited authority. Review the entire flow, not only previously reported areas.

Work read-only. Do not edit, create, delete, or format repository files. Use only read/search tools. Your response will be returned to Codex, which will apply or disposition your proposed fixes.

Repository:
`/Users/vladimirkrstic/Workspaces/wn-ios-prototype`

Read these authority and workflow files first:

- `AGENTS.md`
- `.agents/skills/white-noise-ios-prototype/SKILL.md`
- `docs/review-protocol.md`
- `docs/references/apple.md`
- `docs/product-language.md`
- `docs/decisions.md`
- `docs/design-system.md`
- `docs/information-architecture.md`

Then review the complete packet and its machine-readable/executable coverage:

- `docs/approval-packets/onboarding-v1.md`
- `docs/flows/onboarding.md`
- `docs/screen-contracts/onboarding-welcome.md`
- `docs/screen-contracts/onboarding-sign-in.md`
- `docs/screen-contracts/onboarding-qr-scanner.md`
- `docs/screen-contracts/onboarding-sign-up.md`
- `docs/fictional-universe.md`
- `docs/catalogs/screens.json`
- `docs/catalogs/scenarios.json`
- `docs/catalogs/onboarding-fixtures.json`
- `docs/mobbin.md`
- `docs/assets.md`
- `docs/manual-qa.md`
- `WhiteNoisePrototype/Foundation/OnboardingFixtureID.swift`
- `WhiteNoisePrototype/Foundation/FixtureUniverse.swift`
- `WhiteNoisePrototype/Foundation/ScenarioID.swift`
- `WhiteNoisePrototypeTests/FoundationTests.swift`
- `scripts/validate-foundation.sh`

For review history only, read:

- `docs/reviews/onboarding-v1-claude-raw.md`
- `docs/reviews/onboarding-v1-contract-review.md`

Do not accept a prior finding, correction, or disposition merely because it is recorded. Verify it against the current artifacts and authority. Treat newly introduced contradictions, unnecessary complexity, test gaps, or product leakage as ordinary findings.

Important scope facts to verify rather than expand: this is an iPhone portrait-only SwiftUI prototype using public Apple APIs and deterministic in-memory fictional data. It must not add networking, authentication, cryptography, real persistence, real credentials, Keychain, LocalAuthentication, databases, or third-party runtime dependencies. Normal onboarding contains Welcome, Sign In, the Sign In QR Scanner, and Sign Up. Profile switching, adding, and removal belong to Settings. Latest explicit user direction outranks every reference.

Evaluate the four contracts individually and as one flow. Challenge product scope, navigation, hierarchy, exact copy, action ordering, state completeness, recovery, sensitive-data boundaries, deterministic fixture/scenario integrity, testability, and whether a normal person can understand the experience without developer terminology.

Give particular independent attention to native iOS design execution:

- whether NavigationStack, Form, SecureField, PhotosPicker, VisionKit, native buttons, progress, menus, sheets, alerts, and system permission behavior are the right components;
- whether any custom composition is justified or unnecessarily recreates Apple UI;
- visual hierarchy, information density, safe-area behavior, system spacing, alignment, reachable actions, and adaptation across supported iPhone sizes;
- semantic typography and Dynamic Type rather than fixed or arbitrary type metrics;
- Light/Dark, Increased Contrast, Bold Text, color independence, SF Symbols, native materials, and restrained Liquid Glass use;
- motion purpose, native transitions, interruptibility, Reduce Motion, haptics, keyboard movement, focus restoration, and perceived responsiveness;
- VoiceOver labels/order/announcements, Voice Control names, practical target sizes, localization expansion, and RTL;
- whether acceptance criteria, scenarios, fixtures, validation, and tests can actually verify the contract.

Treat Apple sources indexed by the repository as platform authority. Treat White Noise product language and explicit decisions as product authority. Treat Mobbin only as comparative evidence; do not reward copying another app. Do not prescribe arbitrary pixel values, custom animation curves, font sizes, corner radii, or spacing constants when a native component should own them.

Return:

1. **Verdict** — a short readiness assessment for contract approval, without a courtesy pass.
2. **Material findings** — sorted blocker, major, then minor. For every finding provide:
   - a stable finding ID;
   - affected `ScreenID`, shared flow, or foundation artifact;
   - exact file/section evidence;
   - why it matters to the person using the app or to implementation integrity;
   - the concrete correction Codex should make, including replacement copy or contract language when relevant;
   - the specific indexed Apple source when the finding makes a platform claim.
3. **Cross-screen consistency fixes** — only issues that genuinely span multiple onboarding contracts.
4. **Questions for the product owner** — only choices that cannot be resolved from the authority files and would materially change scope, safety, navigation, or visual behavior.
5. **No-finding areas** — optional and brief; include only when confirming an important reviewed area is adequately constrained.

Do not rewrite the entire packet. Do not return vague advice such as “improve spacing” or “follow the HIG.” Make each correction specific enough for Codex to implement, while leaving system-owned visual metrics to Apple components. If there are no material findings, state that plainly instead of inventing issues.
