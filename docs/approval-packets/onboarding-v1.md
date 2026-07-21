# Onboarding v1 approval packet

- Prepared: 2026-07-21
- Status: awaiting user approval
- Shared flow: [Onboarding flow contract](../flows/onboarding.md)
- Screens: [Welcome](../screen-contracts/onboarding-welcome.md), [Sign In](../screen-contracts/onboarding-sign-in.md), [QR Scanner](../screen-contracts/onboarding-qr-scanner.md), [Sign Up](../screen-contracts/onboarding-sign-up.md)

## Decisions requested

| Screen | Proposed product decision |
|---|---|
| Welcome | Adaptive White Noise vector mark; no headline/body/legal/permission copy; bordered **Login** above prominent **Sign Up**; normal launch is nondismissible; later Settings Add Profile reuses it in a dismissible sheet. |
| Sign In | Native Form and masked **Private Key** entry; **Paste**, **Clear**, **Scan QR Code**, and **Sign In**; fictional deterministic credential states only; existing-Profile recovery stays inside this screen; simulated success enters Chats. |
| QR Scanner | VisionKit live scanner with native highlighting/guidance plus one app instruction; fictional `wnproto` allowlist only; no custom reticle; complete denied/restricted/unavailable/error/manual-entry recovery. |
| Sign Up | Native Form; optional avatar through PhotosPicker, optional Name and About; visible public-avatar consequence; deterministic creation/partial-save recovery; simulated success enters Chats. |

## Shared constraints

- No stored-profile chooser during onboarding. `settings.profiles` owns switching, adding, and removal.
- No real authentication, keys, QR credentials, cryptography, network operation, account creation, or persistence.
- No team identifiers or simulation terminology in ordinary product output.
- No onboarding success placeholder may bypass the independent `chats.list` screen gate.
- All visible errors are recoverable, all outcomes use fixed fixtures and delays, and all sensitive draft data is scrubbed at documented boundaries.

## Evidence summary

- Apple components: NavigationStack, Form, SecureField, FocusState, PhotosPicker, DataScannerViewController, semantic accessibility and system permission behavior.
- White Noise: approved terminology and issues #827–#832, adapted where real implementation behavior is prohibited in the prototype.
- Mobbin: focused Signal and Telegram comparisons are recorded with upload dates, exact journey links, and accepted/rejected lessons in [the comparison index](../mobbin.md).

## After approval

1. Set each approved catalog entry and contract to `userApproved`.
2. Run one read-only independent review packet covering all four contracts while returning findings per `ScreenID`.
3. Fix or disposition every finding; move passing screens to `independentlyApproved`.
4. Register implementation paths, then implement Welcome → Sign In/QR → Sign Up with previews and tests.
5. Present sanitized simulator evidence for user visual acceptance; physical camera and Photos checks remain required before final acceptance.
