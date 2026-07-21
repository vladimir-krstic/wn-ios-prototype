---
name: white-noise-ios-prototype
description: Plan, contract, implement, test, or review White Noise native iPhone prototype screens, flows, scenarios, product copy, fixtures, system integrations, and team-only tools. Use for any work in the wn-ios-prototype repository that can affect UI behavior, navigation, deterministic state, accessibility, evidence, or screen acceptance.
---

# White Noise iOS Prototype

1. Read `AGENTS.md`, the target entry in `docs/catalogs/screens.json`, its contract, relevant decisions, `docs/product-language.md`, and the cited Apple sources.
2. Treat `../wn-ios-agile` and `../whitenoise-ios` as read-only. Prefer latest user direction over both.
3. Stop before implementation unless the screen is `independentlyApproved`. Draft or revise the contract instead. Once approved, register its `WhiteNoisePrototype/Screens/` implementation path in the catalog before creating the file.
4. Define purpose, audience, entry/exit, native component choices, exact copy, actions, all relevant states, accessibility, Light/Dark, Dynamic Type, Reduce Motion, and verification.
5. Use Mobbin only for two to four focused comparisons. Record what was accepted or rejected; never copy shipped-app UI or assets.
6. Require standard SwiftUI/UIKit components and SF Symbols. Record why any custom view is necessary before building it.
7. Keep product UI calm and human. Keep `ScreenID`, `ScenarioID`, fixture controls, and technical diagnostics inside team-only surfaces.
8. Use fixed IDs, clocks, ordering, delays, and outcomes. Add no networking, authentication, cryptography, real persistence, or third-party runtime dependency.
9. Implement only the approved contract. Add previews, unit/UI coverage, accessibility checks, sanitized evidence, and review disposition.
10. Run `./scripts/validate-foundation.sh` and Xcode 27 tests. A non-authoring agent must review material changes before user acceptance.

Stop and request direction when product scope, navigation, data-loss consequences, safety language, custom UI, or a visual decision is unresolved.
