# Screen contract: Sign In

- ScreenID: `onboarding.sign-in`
- Status: `draft`
- Audience: product
- Approvals: user pending; independent review pending

## Purpose and outcome

Let a person continue with an existing Profile by entering or scanning a Private Key, while keeping the task clear and the sensitive value concealed. This is a deterministic simulation: it performs no authentication, cryptographic validation, key import, networking, or persistence.

## Entry, exit, and navigation

- Entry: **Login** from Welcome, or a direct Sign In scenario launch.
- The native navigation title is **Sign In**.
- Native Back returns to Welcome and clears the ephemeral credential draft.
- **Scan QR Code** pushes `onboarding.qr-scanner`; a valid fictional scan returns a populated masked state without submitting.
- A simulated successful Sign In replaces onboarding with `chats.list` when that destination is approved and available.
- The existing-Profile result uses **Switch Profile** and then follows the same successful handoff; it never creates a duplicate Profile.

## Native component specification

- Use a native `Form` with a credential section and an action section, plus a bottom safe-area primary action where the approved composition requires it.
- Use `SecureField` labeled **Private Key**, one line, without a reveal control. Disable autocorrection and automatic capitalization and use the most appropriate ASCII-capable keyboard.
- Show helper or error text as semantic `Text` adjacent to the field. Invalid and failure feedback includes text and an SF Symbol; color is supplementary.
- Use native Buttons for **Paste**, **Clear**, and **Scan QR Code**. Standard actions use deployment-available SF Symbols such as `doc.on.clipboard`, `xmark.circle.fill`, and `qrcode.viewfinder`, with visible labels or equivalent accessible names.
- Use `FocusState` for initial keyboard focus, Return-key submission, error recovery, and focus restoration after QR return.
- Use native `ProgressView` inside the primary action during submission. Do not add a custom spinner, custom text field chrome, or custom animation.
- The credential draft is ephemeral view state only. Domain models receive only a fictional state classification such as empty, invalid fixture, accepted fixture, or existing-Profile fixture—never the entered string.

## Exact product copy

| Context | Copy |
|---|---|
| Navigation title | **Sign In** |
| Field label | **Private Key** |
| Empty helper | **It starts with `nsec`.** |
| Empty field action | **Paste** |
| Populated field action | **Clear** |
| Scanner route | **Scan QR Code** |
| Primary action | **Sign In** |
| Invalid fixture | **That private key isn't valid. Check it and try again.** |
| Existing Profile | **This profile is already on this device.** |
| Existing-Profile action | **Switch Profile** |
| Progress | **Signing In…** |
| Offline failure | **Couldn't sign in. Check your connection and try again.** |
| Other failure | **Couldn't sign in. Try again.** |

Product UI does not expose the fictional fixture value, its ID, the `wnproto` scheme, parsing language, or a technical error.

## Actions and deterministic states

| State | Behavior and recovery |
|---|---|
| `onboarding.sign-in.empty` | Field is empty and focused. Paste and QR are available; Sign In is disabled. The simulated Paste capability inserts only the cataloged fictional valid fixture and never reads a real credential from the general pasteboard. |
| `onboarding.sign-in.populated` | Fixture `credential.maya.accepted` appears only as secure dots. Clear replaces Paste. Sign In is enabled and its simulated success activates Maya Chen (`profile.maya`). |
| `onboarding.sign-in.invalid` | Fixture `credential.invalid.complete` remains masked and editable; inline feedback appears; Sign In is disabled. Correction or Clear returns to neutral. No checksum or cryptographic work occurs. |
| `onboarding.sign-in.existing-profile` | Fixture `credential.maya.existing` is classified, then the draft is scrubbed. Show the existing-Profile explanation and **Switch Profile**; activating the seeded Maya Chen Profile cannot duplicate it. |
| `onboarding.sign-in.loading` | Replace the primary label with progress, disable editing, repeat submission, QR, Paste/Clear, and unsafe navigation until the fixed simulated delay resolves. |
| `onboarding.sign-in.offline` | After the fixed delay, scrub the draft, show the offline copy near the action, restore Paste and QR, and keep Sign In disabled until a new fictional fixture is entered. |
| `onboarding.sign-in.error` | Same recovery as offline with the general failure copy. |
| `onboarding.sign-in.accessibility-stress` | Long localized labels, RTL, largest accessibility Dynamic Type, Bold Text, Increased Contrast, and Reduce Motion without clipping or loss of actions. |

The three cataloged credential fixtures are exactly 32 characters. Classify on every change without parsing: content shorter than 32 characters remains neutral with helper text and disabled Sign In; exact equality at 32 characters yields accepted or existing-Profile only for the two cataloged fixtures; every other value at or beyond 32 characters is invalid. Editing back below 32 characters or using Clear restores neutral. Hardware Return attempts submission only while the primary action is enabled.

Typing, user-initiated paste, QR return, Clear, Back, dismissal, failure, existing-Profile recovery, reset, and success all scrub the ephemeral string at the defined boundary. Arbitrary manually entered content can only reach the invalid UI state after the completion threshold; it is never interpreted as a real key.

## Accessibility and adaptation

- VoiceOver order: title context, Private Key field, helper/error, Paste or Clear, Scan QR Code, primary/recovery action.
- The field is announced as **Private Key, secure text field** without its value or character count. Errors are announced once after state change and remain available for review.
- Icon actions expose visible names and at least 44-point practical targets. Voice Control can use **Paste**, **Clear**, **Scan QR Code**, **Sign In**, and **Switch Profile**.
- Dynamic Type may move the primary action into the scrollable form when necessary; keyboard avoidance cannot obscure the focused field or recovery text.
- Hardware Return submits only when the fictional state is accepted and the action is enabled. Focus returns to the field after invalid input, QR return, and recoverable failure.
- Light, Dark, Bold Text, Increased Contrast, RTL, and localization expansion use semantic system behavior. Meaning never depends on color or haptics.
- No custom motion or haptic. Native navigation and progress respect Reduce Motion.

## Privacy and prototype safety

- Mark the secure entry region privacy-sensitive. The UI test harness sets fixture state through launch arguments rather than typing or capturing a key-shaped string.
- Do not log, persist, diagnose, copy, share, announce, snapshot, or place entered content in `PrototypeState`.
- The simulated Paste capability returns a fictional fixture owned by the scenario registry. Live pasteboard credential access is out of scope for this prototype.
- No real `nsec` is recognized, validated, or used. The visual helper represents intended product language only.

## Evidence disposition

### Apple authority

- `APPLE-INPUT-001`: [SecureField](https://developer.apple.com/documentation/swiftui/securefield) supplies masked sensitive entry and system screenshot behavior.
- `APPLE-INPUT-002`: [Form](https://developer.apple.com/documentation/swiftui/form) supplies platform-appropriate data-entry grouping.
- `APPLE-INPUT-003`: [FocusState](https://developer.apple.com/documentation/swiftui/focusstate) governs keyboard focus and recovery.
- `APPLE-NAV-001`: [NavigationStack](https://developer.apple.com/documentation/swiftui/navigationstack) governs typed hierarchical navigation.
- `APPLE-A11Y-001`: [SwiftUI accessibility fundamentals](https://developer.apple.com/documentation/swiftui/accessibility-fundamentals) governs labels, values, order, and announcements.

### White Noise direction

- Approved `wn-ios-agile` issue #828 provides the Private Key terminology, action set, exact errors, existing-Profile recovery, and security intent. Prototype boundaries replace its real parsing and import behavior with fictional deterministic classifications.
- [White Noise product language](../product-language.md) fixes **Sign In**, **Private Key**, progress, and recovery language.

### Mobbin comparisons

- [Telegram Logging In](https://mobbin.com/flows/a22ae9bc-acea-47b9-bd76-a110c1b14faa), 6 screens, uploaded 2026-06-01 at 393x852. Accept immediate field focus, disabled-to-enabled primary feedback, explicit confirmation, and visible progress. Reject phone-number identity, marketing copy, and a confirmation sheet for this single secure field.
- [Signal Onboarding](https://mobbin.com/flows/f3ea2f8a-16dd-4933-bb89-f2b6995a3ab2), 27 screens, uploaded 2023-05-09 at 375x812. Accept one task per step, native keyboard behavior, and adjacent permission/error recovery. Reject phone-number registration, early notification/contact permission, PIN setup, and automatic continuation as models for White Noise Sign In.

## Acceptance criteria

1. Every cataloged state renders deterministically from its launch argument and resets without retaining draft content.
2. Paste, Clear, Scan QR Code, Sign In, Switch Profile, Back, keyboard submit, and recovery behave exactly as specified and cannot duplicate routes or Profiles.
3. No real credential is authenticated, parsed cryptographically, persisted, logged, announced, or captured.
4. Invalid, offline, and general failures remain adjacent, textual, recoverable, and distinguishable without color.
5. Sign In success can hand off only to an approved `chats.list`; no placeholder product destination bypasses that gate.
6. Default, Dark, invalid/error, loading, existing-Profile, offline, accessibility-size, long-localization, and RTL previews compile.
7. Unit tests cover the 32-character classification threshold, exact fixture outcomes, longer invalid input, action enablement, scrubbing boundaries, duplicate prevention, fixed delays, routes, and reset. UI tests cover the primary journey, QR return, Back, keyboard, and recovery without entering credential text into test logs.
8. Simulator and manual QA pass on the required iPhones; physical-device keyboard behavior is checked before acceptance.

## Approval gate

- User decision requested: approve or revise the Form-based composition, exact copy, simulated Paste behavior, existing-Profile state, and success handoff.
- After user approval: obtain independent non-authoring contract review and disposition every finding.
- Do not register or create the screen implementation before both approvals.

## Review

- 2026-07-21 Claude contract review: response preserved in `docs/reviews/onboarding-v1-claude-raw.md`; findings and dispositions are tracked in `docs/reviews/onboarding-v1-contract-review.md`.
- CLI version and resolved model were not included in the user-supplied response. The requested review configuration was Fable at medium effort.
- Accepted findings are corrected. Independent approval remains pending until the materially revised onboarding packet is re-reviewed.
