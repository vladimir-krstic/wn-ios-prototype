---
name: white-noise-ios-prototype
description: Build, iterate, or review one agreed White Noise native iPhone prototype screen or bounded flow using SwiftUI and public Apple APIs. Use in wn-ios-prototype for UI implementation, navigation, product copy, native component selection, accessibility, motion, system integrations, previews, simulator inspection, or screen-level review.
---

# White Noise iOS Prototype

1. Read `AGENTS.md`, `docs/decisions.md`, and the selected local screen brief.
2. Read `docs/product-language.md` and `docs/terminology.md` whenever work touches product copy, labels, errors, permissions, destructive actions, or accessibility wording.
3. For a material platform decision or UI review, read `docs/references/native-ui.md`, route through `docs/references/apple.md`, and open the relevant current official Apple source. Do not rely only on remembered API behavior.
4. Use only White Noise knowledge stored in this repository. Do not read or invoke project-specific files, source code, instructions, or skills outside it unless the user explicitly requests a bounded cross-project investigation. Generic tooling and official Apple research remain allowed.
5. Limit work to the user-agreed screen or tightly related flow. Do not prepare future screens or speculative shared architecture.
6. Start with the closest public SwiftUI/UIKit component, SF Symbol, navigation pattern, system integration, and system motion. Let standard controls own their metrics and accessibility. Document why an approved custom exception is necessary.
7. Write final production copy on product surfaces. Keep prototype, simulation, fixture, dummy-data, and implementation-boundary language in documentation or developer-only surfaces.
8. Create or update one concise brief in `docs/screens/` only after the user selects the screen. Record durable decisions, relevant Apple links, custom exceptions, important states, accessibility, and observable acceptance criteria.
9. Add fixed in-memory data and capability wrappers only when the selected screen needs them.
10. Use lightweight static validation by default. Do not compile previews, open Device Hub, launch a simulator, install the app, or capture simulator evidence unless the user explicitly asks. Reuse the booted iPhone Air and never claim visual verification without inspecting the current build.
11. Add tests only for meaningful nonvisual logic or a confirmed regression.
12. Never invoke Claude or Fable. If the user requests a major review, provide a neutral copyable prompt.

Stop and ask only when an unresolved decision would materially change the product experience.
