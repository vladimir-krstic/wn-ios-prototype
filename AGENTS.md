# White Noise iOS Prototype

## Mission

Build a production-polished, deterministic iPhone prototype for everyday people and the White Noise team. Product UI stays human and nontechnical; team-only tools may expose precise prototype diagnostics.

## Authority

1. Latest explicit user direction.
2. Official Apple HIG, documentation, WWDC26 guidance, design resources, and sample code indexed in `docs/references/apple.md`.
3. Approved White Noise language and safety decisions in `docs/product-language.md`.
4. Approved screen contract and decision records in this repository.
5. Read-only production implementation evidence from `../whitenoise-ios`.
6. Mobbin and shipped apps as comparative evidence only.

## Non-negotiable boundaries

- Use Xcode 27 beta, Swift 6.4, SwiftUI, public Apple APIs, iOS 27, iPhone only, portrait only.
- Do not add backend, networking, Nostr, Marmot, Rust, authentication, cryptography, Keychain, LocalAuthentication, UserDefaults, databases, or third-party runtime dependencies.
- Keep all prototype state deterministic and in memory; delete temporary imported media on reset.
- Never edit `../whitenoise-ios` or `../wn-ios-agile`.
- Never implement an app-owned screen whose catalog status is below `independentlyApproved`.
- Keep every app-owned screen implementation under `WhiteNoisePrototype/Screens/` and register its exact path in the screen catalog before creating the file.
- Never let team terminology leak into ordinary product UI, screenshots, or accessibility output.
- Use standard SwiftUI/UIKit components and SF Symbols whenever an equivalent exists.

## Required workflow

- Invoke `$white-noise-ios-prototype` for screen, flow, scenario, product-copy, implementation, or review work.
- Run `./scripts/validate-foundation.sh` before and after a screen change.
- Use explicit `DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer` for every build and test.
- Preserve unrelated user changes. Do not publish, push, or configure a Git remote unless explicitly requested.
- Record every material deviation in `docs/decisions.md` and obtain user plus independent approval before implementation.
- Before every independent Claude review, give the user a neutral, copyable prompt that names the review artifacts and authority without asserting that the work is correct or suggesting expected findings. Claude reviews read-only and returns material findings with concrete proposed fixes; Codex applies or dispositions them after the user returns the response. Re-review any materially changed artifact.

## Completion

A screen is complete only at catalog status `accepted`, with its contract, evidence, implementation, automated checks, independent review disposition, and user visual acceptance recorded.
