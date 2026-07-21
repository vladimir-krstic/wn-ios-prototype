# Design decision record

Records are append-only. Supersede; do not rewrite history.

## WN-PROTOTYPE-0001 — Foundation v1

- Date: 2026-07-21
- Status: approved
- Authority: explicit user-approved plan
- Decision: Use Xcode 27 beta, Swift 6.4, SwiftUI, iOS 27, iPhone portrait, no third-party runtime dependencies, and deterministic in-memory data.

## WN-PROTOTYPE-0002 — Dual audience

- Date: 2026-07-21
- Status: approved
- Decision: Product UI serves everyday people; team-only tools serve White Noise product, design, engineering, and QA. Technical fixture language cannot leak into ordinary UI.

## WN-PROTOTYPE-0003 — Screen gate

- Date: 2026-07-21
- Status: approved
- Decision: Each `ScreenID` requires user and independent approval before implementation, followed by independent implementation review and user visual acceptance.

## WN-PROTOTYPE-0004 — Comparative evidence

- Date: 2026-07-21
- Status: approved
- Decision: Use Mobbin first with two to four focused shipped-app comparisons per screen. Do not buy ScreensDesign or install the Emil Kowalski skill unchanged.

## WN-PROTOTYPE-0005 — Avatar strategy

- Date: 2026-07-21
- Status: approved
- Decision: Mix locally bundled, documented Open Peeps/DiceBear Open Peeps avatars with native initial monograms. No runtime fetching or generation.

## WN-PROTOTYPE-0006 — Profile management is not onboarding

- Date: 2026-07-21
- Status: approved
- Authority: explicit user direction
- Decision: Normal launch never presents a stored-profile chooser. Onboarding contains Welcome, Sign In, the Sign In QR Scanner, and Sign Up only. Profile switching, adding, and removal belong to `settings.profiles`; **Add Profile** may reuse Welcome as a dismissible Settings flow.
- Supersedes: the Foundation v1 `onboarding.profile-selection` catalog entry and scenario.

## WN-PROTOTYPE-0007 — Neutral Claude review handoff

- Date: 2026-07-21
- Status: approved
- Authority: explicit user direction
- Decision: Before each independent Claude review, Codex supplies the user with a neutral copyable prompt. The prompt must invite first-principles review without predicting a pass or seeding suspected findings, and must explicitly cover Apple-native components, hierarchy, spacing, typography, motion, accessibility, and adaptation when UI is in scope. Claude remains read-only and returns concrete proposed fixes for Codex to apply or disposition; material revisions require re-review.

## WN-PROTOTYPE-0008 — Onboarding fixture identities

- Date: 2026-07-21
- Status: approved
- Authority: explicit user direction
- Decision: A successful fictional Sign In activates Maya Chen (`profile.maya`). Sign Up with an empty Name creates the deterministic fictional Profile **Quiet Pine**, with initials **QP**. These fixture identities are team-facing test data and never expose credential values or fixture identifiers in product UI or accessibility output.
