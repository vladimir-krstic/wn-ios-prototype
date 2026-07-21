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
