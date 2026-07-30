# White Noise iOS Prototype

A fast, native iPhone workspace for building and refining the White Noise
product one screen or bounded flow at a time.

## Current state

The prototype currently includes:

- Welcome, Sign In, private-key QR scanning, and Sign Up.
- Populated, empty, unread, archived, and left-chat list states.
- A polished Fiatjaf direct conversation with text, media, reactions, replies,
  attachments, and voice-message affordance.
- Settings, profile editing and switching, Profile Keys, appearance,
  notifications, privacy, storage, relays, support, donations, Developer Tools,
  sign out, and profile removal.
- Share & Connect with local QR generation and native VisionKit scanning.

All product state is deterministic and process-local. There is no backend,
networking, persistence, authentication, or cryptography.

## Requirements

- Xcode 27 beta at `/Applications/Xcode-beta.app`
- iOS 27 simulator
- SwiftUI and public Apple APIs only
- iPhone Air for requested simulator inspection

## Build

```sh
DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer \
xcodebuild \
  -project WhiteNoisePrototype.xcodeproj \
  -scheme WhiteNoisePrototype \
  -destination 'generic/platform=iOS Simulator' \
  build
```

Open `WhiteNoisePrototype.xcodeproj`, select the shared
`WhiteNoisePrototype` scheme and the iPhone Air running iOS 27, then press Run
only when hands-on inspection is requested.

The app follows the system appearance by default and also provides a
process-local Appearance setting.

## Device Hub and screenshots

- Reuse the booted iPhone Air in Device Hub. Do not boot a second simulator
  unless another device is explicitly requested.
- Check `xcrun simctl list devices | rg Booted` before launching.
- For consistent screenshot time:

```sh
xcrun simctl status_bar booted override --time 18:15
```

- Clear the override after screenshot work:

```sh
xcrun simctl status_bar booted clear
```

## Screen workflow

1. Agree on one screen or tightly related flow.
2. Create or update its concise brief under `docs/screens/`.
3. Build it with native Apple components and only the state it actually needs.
4. Use static checks during small iterations and build once at the end of a
   meaningful batch.
5. Open Device Hub only when the user requests inspection or approves it after
   Codex explains why it is needed.
6. Iterate until the user accepts the screen, then move to the next batch.

Tests are added only for meaningful nonvisual behavior or a confirmed
regression. The current UI test protects chat pin-reordering behavior. Claude
and Fable are never invoked automatically.
