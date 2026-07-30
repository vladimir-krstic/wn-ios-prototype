# White Noise iOS Prototype

## Mission

Build a polished native iPhone prototype quickly, one user-agreed screen or tightly related flow at a time. Product UI is for everyday people; development notes may use precise team terminology.

## Authority

1. Latest explicit user direction.
2. Official Apple sources in `docs/references/apple.md`.
3. Product language in `docs/product-language.md`.
4. The brief for the screen currently being built.
5. Read-only implementation evidence from `../whitenoise-ios` and product evidence from `../wn-ios-agile`.
6. Mobbin and shipped apps as optional comparative inspiration.

## Boundaries

- Use Xcode 27 beta, SwiftUI, public Apple APIs, iOS 27, iPhone only, and portrait only.
- Do not add backend, networking, Nostr, Marmot, Rust, real authentication, cryptography, Keychain, LocalAuthentication, UserDefaults, databases, or third-party runtime dependencies.
- Keep prototype state in memory and deterministic when a screen needs state.
- Product-surface copy must be production-ready. Never expose prototype, simulation, fixture, dummy-data, or implementation-boundary language outside development-only surfaces.
- Never edit `../whitenoise-ios` or `../wn-ios-agile`.
- Use native SwiftUI/UIKit components, SF Symbols, semantic typography, system spacing, system colors, native navigation, and system motion whenever an equivalent exists.
- Let standard Apple controls own typography, control height, padding, shape, material, spacing, and motion. Use safe areas, system margins, default spacing, and semantic values instead of copying numeric recipes; add explicit sizing only for a user-approved custom brand element recorded in the current screen brief.

## Screen workflow

- Work only on the screen or small flow the user has selected.
- Before implementation, create a short brief in `docs/screens/` for that work: purpose, navigation, exact copy, native components, important states, accessibility, relevant Apple links, and observable acceptance criteria.
- Keep briefs focused on durable accepted decisions. Do not record every temporary visual experiment or spacing iteration.
- Do not create speculative architecture, models, services, scenarios, assets, or future screens.
- Implement the requested change and use lightweight static validation by default. Do not compile previews, open Device Hub, launch a simulator, install the app, or capture simulator evidence unless the user explicitly asks.
- If repeated visual iterations or unresolved uncertainty make simulator inspection materially useful, ask the user for permission before opening or running it.
- When the user supplies visual evidence, inspect the current implementation, identify one concrete cause, and make one bounded change at a time. Never claim visual verification without inspecting the current build.
- Add tests only for meaningful nonvisual logic or a real regression.
- The user is the visual and product acceptance authority.
- Never invoke Claude or Fable automatically. When the user requests a major review, provide a neutral prompt for the user to run.
- Preserve unrelated user changes. Do not configure a remote, commit, or push unless explicitly requested.

## Build

Use `DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer` for every Xcode build or test command.

- When the user explicitly requests simulator inspection, use Device Hub as the default surface for selecting the device, installing and launching the build, interacting with the app, capturing evidence, and leaving the result ready for inspection.
- Use an iPhone Air running iOS 27 in portrait as the default inspection target. Do not use an iPhone Pro or Pro Max unless the user explicitly requests one.
- Reuse the booted Device Hub iPhone Air. Check for an existing booted simulator before launching and never boot a second device automatically.
- Fall back to the classic Simulator, `simctl`, or generic Computer Use only when Device Hub is unavailable. Tell the user before using that fallback.

## Completion

A screen is complete only when the user accepts it after hands-on inspection.
