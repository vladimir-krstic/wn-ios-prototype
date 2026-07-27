---
name: white-noise-ios-prototype
description: Build, iterate, or review one agreed White Noise native iPhone prototype screen or bounded flow using SwiftUI and public Apple APIs. Use for UI, navigation, copy, previews, dummy state, system integrations, accessibility, or simulator work in wn-ios-prototype.
---

# White Noise iOS Prototype

1. Read `AGENTS.md`, `docs/product-language.md`, the relevant entries in `docs/references/apple.md`, and the current screen brief if it exists.
2. Limit work to the user-agreed screen or tightly related flow. Do not prepare future screens or speculative shared architecture.
3. Write product-surface copy as production-ready UI. Keep prototype, simulation, fixture, dummy-data, and implementation-boundary language in documentation or development-only surfaces.
4. Prefer native SwiftUI/UIKit components, SF Symbols, semantic type, system colors, standard navigation, and system motion. Let standard controls own their metrics; use safe areas, system margins, and default spacing instead of numeric recipes. Apply explicit sizing only to a user-approved custom brand element documented in the current brief.
5. Create or update one concise brief in `docs/screens/` only after the user selects the screen.
6. Add fixed in-memory dummy data and capability wrappers only when the selected screen requires them.
7. Build with Xcode 27 beta, compile relevant previews, launch the app, and present the result for direct user inspection.
8. Add tests only for meaningful nonvisual logic or a confirmed regression.
9. Never invoke Claude. If the user requests a major review, provide a neutral copyable prompt.

Stop and ask only when an unresolved decision would materially change the product experience.
