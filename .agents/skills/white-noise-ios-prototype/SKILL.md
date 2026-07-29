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
7. Implement the requested change and use lightweight static validation by default. Do not compile previews, open Device Hub, launch a simulator, install the app, or capture simulator evidence unless the user explicitly asks. If visual uncertainty or repeated iteration makes simulator inspection materially useful, ask the user for permission first.
8. Add tests only for meaningful nonvisual logic or a confirmed regression.
9. Never invoke Claude. If the user requests a major review, provide a neutral copyable prompt.

Stop and ask only when an unresolved decision would materially change the product experience.
