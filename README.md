# White Noise iOS Prototype

A deterministic, native iPhone prototype for exploring the complete White Noise product experience with fictional data. Product UI is written for everyday people; Scenario Lab, diagnostics, contracts, and review evidence serve the White Noise team.

## Status

Foundation v1 is scaffolded. All product and team screens remain `draft` until their individual user and independent-review gates pass. The current app target intentionally renders no product screen.

## Fixed boundaries

- Xcode 27 beta, Swift 6.4, SwiftUI, iOS 27, iPhone, portrait.
- Public Apple APIs only; no third-party runtime packages.
- No backend, networking, Nostr, Marmot, Rust, authentication, cryptography, or app-owned persistence.
- Never modify `../whitenoise-ios` or `../wn-ios-agile`; both are read-only references.
- Latest explicit user direction outranks every other source.

## Commands

```sh
./scripts/validate-foundation.sh
DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer \
  xcodebuild -project WhiteNoisePrototype.xcodeproj \
  -scheme WhiteNoisePrototype \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=27.0' test
```

Before any screen work, read `AGENTS.md`, invoke `$white-noise-ios-prototype`, and follow that screen's contract gate.
