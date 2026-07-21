# Onboarding flow contract

- Status: `draft`
- Audience: product
- ScreenIDs: `onboarding.welcome`, `onboarding.sign-in`, `onboarding.qr-scanner`, `onboarding.sign-up`
- User approval: pending for each screen
- Independent contract review: pending

## Product outcome

Let a person either continue with an existing Profile or create a new Profile, then enter Chats. The prototype must feel like an ordinary product flow while every credential, result, delay, failure, and created Profile remains fictional, deterministic, and in memory.

Normal launch has no stored-profile chooser:

```text
Welcome
├─ Login → Sign In ─┬─ fictional Private Key → simulated result → Chats
│                   └─ Scan QR Code → QR Scanner → Sign In → simulated result → Chats
└─ Sign Up → Profile setup → simulated result → Chats
```

`settings.profiles` owns switching, adding, and removing Profiles later. **Add Profile** may present Welcome as a dismissible sheet, but this reuse does not create another onboarding screen or change normal launch.

## Navigation contract

- Use one typed `NavigationStack` path for the normal onboarding hierarchy.
- Welcome is the nondismissible root on unconfigured launch.
- Sign In and Sign Up are pushed destinations with native Back behavior and interactive swipe-back.
- QR Scanner is pushed from Sign In and returns its fictional result to Sign In; it never signs in automatically.
- Successful Sign In or Sign Up replaces onboarding with `chats.list`; it does not leave onboarding underneath the Chats hierarchy.
- The Settings Add Profile presentation is a separate sheet context. Its Welcome root has native dismissal; child destinations use Back. A completed Add Profile flow dismisses to the signed-in hierarchy.
- During simulated submission, disable repeat actions. Prevent unsafe Back or dismissal only while a state transition would otherwise duplicate or corrupt the in-memory result.

## Prototype boundary

- No authentication, cryptography, key parsing, checksum validation, account creation, networking, or persistence occurs.
- Sign In recognizes only cataloged fictional fixture states. Arbitrary input never authenticates and is never copied into logs, screenshots, accessibility values, diagnostics, or domain models.
- The QR scanner accepts only `wnproto://private-key/<fixture-id>` payloads from the documented fictional universe. A raw `nsec`, URL, contact code, or any other QR payload is invalid.
- Sign Up creates only a deterministic in-memory Profile. Selected photos remain in memory or protected temporary storage and are deleted on removal, reset, dismissal, or process end.
- UI tests and previews use simulated capabilities. Live system integrations are limited to the camera scanner and PhotosPicker on supported devices.

## Cross-screen behavior

- Exact entry terms are **Login** on Welcome, **Sign In** inside the existing-Profile flow, and **Sign Up** for new-Profile creation.
- Product UI never shows `ScreenID`, `ScenarioID`, fixture identifiers, payload schemes, or simulation controls.
- Keyboard focus follows the task, errors remain adjacent to their source, and successful completion is evident from entering Chats rather than a redundant success screen.
- Native navigation, keyboard, picker, scanner, progress, and button feedback supply motion. No onboarding screen adds decorative animation.
- Every route and visible mutation is a typed `PrototypeAction`; repeated taps cannot create duplicate routes or Profiles.

## Scenario coverage

- Welcome: default Light/Dark and adaptation previews.
- Sign In: empty, populated, invalid, existing Profile, loading, general error, offline, and accessibility stress.
- QR Scanner: ready/live, denied, restricted, unsupported/unavailable, camera error, invalid code, and deterministic valid-code return.
- Sign Up: empty, populated/avatar selected, loading, creation error, partial-save recovery, unavailable photo, and accessibility stress.
- Success handoff is verified once `chats.list` reaches the required approval state; onboarding implementation cannot weaken the Chats gate by creating a placeholder product screen.

## Approval boundary

Approval of this flow confirms shared scope and navigation only. Each listed screen contract still requires an explicit user approval and independent non-authoring approval before its implementation path can be registered.
