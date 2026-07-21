# Screen contract: QR Scanner

- ScreenID: `onboarding.qr-scanner`
- Status: `draft`
- Audience: product
- Approvals: user pending; independent review pending

## Purpose and outcome

Let a person populate Sign In by scanning a fictional prototype QR code, using Apple’s native camera-scanning experience and clear recovery when the camera or scanned content is unavailable. The scanner never accepts a real Private Key or performs authentication or cryptography.

## Entry, exit, and navigation

- Entry: **Scan QR Code** from `onboarding.sign-in`, or a direct scanner scenario launch.
- Native navigation title: **Scan QR Code**.
- Native Back returns to Sign In without changing its previous draft.
- A valid fictional scan stops capture, returns one accepted fixture classification to Sign In, restores focus to its masked field, announces the result, and waits for explicit **Sign In**.
- Invalid content keeps the scanner open. Denied, restricted, unsupported, and camera-error states retain a visible manual-entry route.
- Backgrounding, Back, deallocation, permission changes, and success stop scanning and release the camera exactly once.

## Native component specification

- On a supported physical device in live mode, wrap `DataScannerViewController` for QR barcode recognition only.
- Enable Apple’s native guidance, pinch-to-zoom, tap-to-focus, and item highlighting. Recognize one item at a time. Do not draw a custom reticle, animated scan line, camera shutter, or custom recognition highlight.
- Overlay only the private-key-specific instruction that VisionKit cannot provide. Place semantic `Text` on a native material within safe areas; it is noninteractive and adapts to Dynamic Type.
- Use the native navigation bar and Back button. A deployment-available SF Symbol may accompany manual entry or Settings recovery but never replace its text.
- Use the system permission prompt after the person deliberately opens the scanner. The target camera-purpose string is **Scan QR codes and take photos to share in chats.**
- In previews, UI tests, and simulated mode, replace camera capture with a deterministic test surface that can emit valid, invalid, denied, restricted, unavailable, or camera-error capability outcomes. Simulation controls are not present in normal live product output.

## Exact product copy

| Context | Copy |
|---|---|
| Navigation title | **Scan QR Code** |
| Live guidance | **Scan a QR code that contains your private key.** |
| Valid announcement | **Private key scanned.** |
| Denied | **Camera access is off. Allow it in Settings to scan a QR code.** |
| Denied action | **Open Settings** |
| Restricted | **Camera access is restricted on this device. Enter your private key instead.** |
| Unsupported/unavailable | **QR scanning isn't available on this device. Enter your private key instead.** |
| Camera failure | **Couldn't start the camera. Try again or enter your private key instead.** |
| Recovery actions | **Retry**, **Enter Private Key** |
| Invalid content | **That QR code doesn't contain a valid private key. Try another code or enter your key manually.** |

The raw QR payload, fixture ID, payload scheme, and any camera diagnostic remain absent from product UI and accessibility output.

## Actions and deterministic states

| State | Behavior and recovery |
|---|---|
| `onboarding.qr.ready` | Check `isSupported` and `isAvailable`, request camera access contextually when needed, then start native scanning. A fictional valid code returns once to Sign In. |
| `onboarding.qr.permission-denied` | Do not show a camera preview. Show denied copy with **Open Settings** and **Enter Private Key**. Returning from Settings rechecks capability state. |
| `onboarding.qr.permission-restricted` | Show restricted copy and **Enter Private Key**; do not offer Settings as false recovery. |
| `onboarding.qr.unavailable` | Cover unsupported hardware, no camera, and scanner unavailable with the approved unavailable copy and manual-entry route. Team Diagnostics may retain the precise fixture reason. |
| `onboarding.qr.camera-error` | Show camera-failure copy with **Retry** and **Enter Private Key**. Retry uses a fixed simulated outcome and cannot start duplicate scanner sessions. |
| `onboarding.qr.invalid-code` | Keep scanning, show inline material-backed error, and throttle repeated visual, VoiceOver, and error haptic feedback. Never display the decoded payload. |
| Simulated valid result | A test-only capability action emits a cataloged fixture, produces one selection haptic, announces success, dismisses once, and populates Sign In without automatic submission. |

Only payloads matching `wnproto://private-key/<fixture-id>` and resolving to an approved fictional fixture are valid. Raw `nsec` values, profile QR codes, URLs, arbitrary text, and unknown fixture IDs are invalid.

## Accessibility and adaptation

- VoiceOver reads the native title, guidance, current recovery/error text, and actions; it never reads live camera contents or payload data.
- Invalid feedback announces once per throttled event. The valid result announces once after Sign In regains focus.
- Voice Control can address **Back**, **Open Settings**, **Retry**, and **Enter Private Key** by visible name. Every app-owned action has a 44-point practical target.
- Guidance and recovery content reflow for accessibility Dynamic Type, localization expansion, and RTL without obscuring native scanner controls or the camera safe area.
- Light/Dark and Increased Contrast use semantic native materials and text colors over the camera preview. Meaning never depends only on tint, highlighting, or haptics.
- Use one selection haptic for a valid result and one throttled error haptic for invalid content. Visible and spoken feedback remain complete without haptics.
- Native scanner and navigation motion own transitions; no custom motion is added. Reduce Motion remains effective.

## System, privacy, and lifecycle

- Live camera use is the only protected-resource access. No Photos, microphone, contacts, location, notification, or tracking permission belongs here.
- Check VisionKit support and availability before construction and again after relevant lifecycle changes.
- Stop scanning on Back, valid result, disappearance, backgrounding, unavailability, and deallocation. Release the scanner/camera even when callbacks race.
- Do not save frames, photos, payloads, or scan history. No scanned content enters diagnostics or screenshots.
- Physical-device verification is mandatory for permission, recognition, backgrounding, Settings recovery, haptics, and camera release.

## Evidence disposition

### Apple authority

- `APPLE-VISION-002`: [DataScannerViewController](https://developer.apple.com/documentation/visionkit/datascannerviewcontroller) provides the live scanner, recognition configuration, support, and availability checks.
- `APPLE-VISION-003`: [Scanning data with the camera](https://developer.apple.com/documentation/visionkit/scanning-data-with-the-camera) governs permission, native guidance, highlighting, scanning lifecycle, and unavailable recovery.
- `APPLE-A11Y-001`: [SwiftUI accessibility fundamentals](https://developer.apple.com/documentation/swiftui/accessibility-fundamentals) governs labels, order, and announcements.
- `APPLE-A11Y-004`: [Reduce Motion](https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityreducemotion) governs any app-owned state transition.

### White Noise direction

- Approved `wn-ios-agile` issue #829 supplies the navigation, guidance, permission/error copy, capture-release intent, and manual-entry recovery. The prototype replaces real `nsec` recognition with fictional `wnproto` fixture payloads.

### Mobbin comparisons

- [Signal: Link a new device](https://mobbin.com/flows/d0f6c440-14bc-4654-9d30-9b4ce59e8d5b), 3 screens, uploaded 2023-05-09 at 375x812. Accept a full camera surface, a clear task title, brief guidance, and native Back. Reject the device-linking illustration and any assumption that a recognized code should complete a broader account action automatically.
- [Telegram: Linking to a desktop device](https://mobbin.com/flows/16b7a729-ac06-451f-914e-0e6a76fda5f9), 3 screens, uploaded 2026-06-01 at 393x852. Accept full-screen camera focus and concise context. Reject its custom corner reticle, branded instruction, persistent torch control, and device-session consequences; VisionKit owns recognition UI here.

## Acceptance criteria

1. Live mode uses VisionKit only on supported physical devices and accepts only documented fictional payloads.
2. Valid scan, invalid scan, denied, restricted, unavailable, camera error, retry, Settings recovery, manual entry, Back, backgrounding, and reset behave deterministically and release capture.
3. No real credential or QR payload is rendered, announced, logged, diagnosed, persisted, or retained.
4. A valid result returns to Sign In exactly once, restores focus, populates only a masked fictional state, and never submits automatically.
5. No custom reticle, scanner highlight, capture control, or decorative scanner animation is introduced.
6. Default/live, denied, restricted, unavailable, camera-error, invalid-code, Dark, large-text, localization, and RTL previews or simulated representations compile.
7. Unit tests cover payload allowlisting, unknown payload rejection, throttling, lifecycle idempotence, capability mapping, routes, and reset. UI tests cover every simulated state without camera dependence.
8. Accessibility Inspector, VoiceOver, Voice Control, contrast, target size, and physical-device camera/haptic checks pass.

## Approval gate

- User decision requested: approve or revise VisionKit-native scanning, exact copy, fictional `wnproto` allowlist, haptics, and recovery behavior.
- After user approval: obtain independent non-authoring contract review and disposition every finding.
- Do not register or create the screen implementation before both approvals.
