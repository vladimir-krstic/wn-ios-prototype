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
- Do not create speculative architecture, models, services, scenarios, assets, or future screens.
- Build, compile previews, launch on the requested simulator, and make the result directly inspectable by the user.
- Add tests only for meaningful nonvisual logic or a real regression.
- The user is the visual and product acceptance authority.
- Never invoke Claude automatically. When the user requests a major review, provide a neutral prompt for the user to run.
- Preserve unrelated user changes. Do not configure a remote, commit, or push unless explicitly requested.

## Build

Use `DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer` for every Xcode build or test command.

## Completion

A screen is complete only when the user accepts it after hands-on inspection.
