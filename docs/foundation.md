# Foundation v1

Status: **locked for scaffolding**
Approved plan date: 2026-07-21
Target: Xcode 27 beta / Swift 6.4 / iOS 27 / iPhone portrait

## Audiences

Product surfaces serve everyday people. They use familiar language, direct recovery, and no unnecessary implementation terms. Team surfaces serve White Noise product, design, engineering, and QA. They may expose fixture controls and diagnostics, but remain outside ordinary product navigation and accessibility output.

## Authority

1. Latest explicit user direction.
2. Indexed official Apple sources.
3. Approved White Noise language and safety decisions.
4. Approved local screen contracts and decision records.
5. Read-only current iOS implementation evidence.
6. Mobbin and shipped apps as comparison only.

## Runtime boundary

All people, profiles, chats, messages, permissions, errors, delays, and timestamps are fictional and deterministic. The app contains no network client, remote URL loading, sign-in mechanism, cryptographic operation, key storage, database, UserDefaults, or state restoration. Live Apple capabilities may supply ephemeral camera, photo, file, audio, sharing, notification, clipboard, and haptic interactions. Tests and previews replace them with fixed simulated results.

## Change control

Changing scope, navigation, data-loss behavior, product language, system-component choice, visual identity, or a custom interaction requires a decision record, user approval, and independent review. Current implementation never silently becomes product authority.

All app-owned screen implementations live under `WhiteNoisePrototype/Screens/` and must be registered by exact path in `docs/catalogs/screens.json`. The validator rejects unregistered files, implementation declarations before independent approval, and implemented catalog states without a corresponding file.
