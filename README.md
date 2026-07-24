# White Noise iOS Prototype

A fast, native iPhone prototype workspace for building and inspecting one screen at a time.

## Current state

The app contains only a development placeholder. No product screen, flow, fixture, scenario, or feature permission is implemented yet.

## Requirements

- Xcode 27 beta at `/Applications/Xcode-beta.app`
- iOS 27 simulator
- SwiftUI and public Apple APIs only

## Build

```sh
DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer \
xcodebuild \
  -project WhiteNoisePrototype.xcodeproj \
  -scheme WhiteNoisePrototype \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=27.0' \
  build
```

Open `WhiteNoisePrototype.xcodeproj`, select the shared `WhiteNoisePrototype` scheme and an iPhone 17 simulator, then press Run to inspect the app.

Normal prototype launches use Light Mode. In the Xcode 27 beta, Device Hub's appearance control may not propagate to the debugged app. For a requested Dark Mode inspection, use Xcode's Environment Overrides, set Appearance to Dark, and disable the override afterward. The prototype does not include an in-app appearance switch.

## Screen workflow

1. Agree on one screen or tightly related flow.
2. Add a concise brief under `docs/screens/`.
3. Build it with native Apple components and only the state it actually needs.
4. Compile its previews, build, and launch it for direct inspection.
5. Iterate until the user accepts it, then move to the next screen.

Tests are added only for meaningful nonvisual behavior or a real regression. Claude is never invoked automatically.
