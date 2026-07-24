# Sign In

## Purpose and navigation

Use an existing White Noise profile by entering its private key. **Sign In** on Welcome pushes this screen. The QR action pushes a native camera scanner and returns the scanned value to Sign In.

## Copy

- Navigation title: **Sign In**
- Field label: **Private Key**
- Field prompt: **Enter private key**
- Format help: **It starts with nsec.**
- Invalid key: **That private key isn't valid. Check it and try again.**
- Primary action: **Sign In**
- Progress: **Signing In…**
- Scanner title: **Scan QR Code**
- Scanner guidance: **Position the private key QR code in view.**
- Unavailable scanner title: **QR Scanning Unavailable**
- Unavailable scanner explanation: **Use a physical iPhone to scan a code, or use the sample code in this prototype.**
- Simulator action: **Use Sample Code**

## Native components

- `NavigationStack` push navigation and native Back behavior.
- Native `SecureField` so the private key is never shown as plain text.
- User-approved Login-specific SwiftUI composition using `secondarySystemFill`, native `Capsule`, system horizontal padding, and a 50-point height matching the accepted Sign Up field and large circular glass action.
- SF Symbol buttons for Paste, Clear, and Scan QR Code.
- Paste or Clear occupies a reserved 44-point trailing field-accessory region.
- The separate circular `glass` action uses the large system control size. It displays Scan QR Code while an empty field is idle and Close while the field has keyboard focus.
- Native `glassProminent` primary action.
- Native small `ProgressView` centered inside the primary action while signing in.
- The shared primary-action content follows the adaptive monochrome tint: white title or spinner on the black Light Mode button, and black title or spinner on the white Dark Mode button. Native `glassProminent` continues to own enabled and disabled styling.
- VisionKit `DataScannerViewController` for QR scanning on supported iPhones.
- Native `ContentUnavailableView` with a deterministic sample-code action when scanning is unavailable.

## Important behavior

- The label and guidance or validation text align with the editable text inset inside the capsule, following the accepted Sign Up field hierarchy.
- Tapping the filled field gives the native `SecureField` focus and presents the keyboard.
- An empty, unfocused field shows Paste and Scan QR Code.
- While the field has focus, the outside action becomes Close and dismisses the keyboard without changing the entered value.
- Any entered value replaces Paste with Clear. After the keyboard is dismissed, the outside action disappears and the capsule expands.
- Clear empties the field without dismissing the keyboard.
- The keyboard also uses its native Go key and dismisses when the scanner or Sign In flow is opened.
- Paste inserts one fixed fictional `nsec` value with the normal 63-character length, so the pasted state is always usable.
- Manual and scanned values are trimmed, then accepted when they begin with lowercase `nsec`. Other values are invalid.
- The prototype performs no length check, decoding, authentication, or cryptography.
- The filled capsule is an intentional custom composition because SwiftUI has no stock filled secure field with a configurable trailing accessory. All constituent controls, colors, shapes, symbols, spacing, and motion use public Apple APIs.
- The iOS 27 bordered text-field style is explicitly rejected here because its outlined appearance conflicts with the accepted filled onboarding fields and rounded actions.
- The primary action remains disabled until the prototype check passes.
- Invalid input shows the recovery message below the field.
- Paste and Clear use the system SF Symbol replacement transition. Scan QR Code fades as the field crosses between empty and nonempty.
- Guidance and validation use native footnote typography with semantic secondary and error colors.
- Sign In preserves its normal dimensions, replaces its visible title with a centered spinner, prevents repeat activation, and exposes **Signing In** and **In progress** to assistive technologies before invoking its callback.
- While Sign In is processing, the entire field enters SwiftUI's native disabled environment so its native `SecureField` receives the system disabled appearance and interaction behavior; both its internal Paste or Clear action and its external Close or Scan action disappear.
- The deterministic prototype processing state lasts four seconds so its stable spinner and disabled-field treatment are easy to inspect.
- A scanned QR payload returns to Sign In and is checked by the same prototype validator.

## Accessibility

- The private key value is marked sensitive and is never included in accessibility labels.
- Paste, Clear, and Scan QR Code use explicit action labels.
- Native controls retain system focus, keyboard, hit-target, disabled, progress, and navigation behavior.

## Apple references

- [SecureField](https://developer.apple.com/documentation/swiftui/securefield)
- [SwiftUI Focus](https://developer.apple.com/documentation/swiftui/focus)
- [SwiftUI disabled](https://developer.apple.com/documentation/swiftui/view/disabled%28_%3A%29)
- [SwiftUI isEnabled](https://developer.apple.com/documentation/swiftui/environmentvalues/isenabled)
- [Text fields HIG](https://developer.apple.com/design/human-interface-guidelines/text-fields)
- [secondarySystemFill](https://developer.apple.com/documentation/uikit/uicolor/secondarysystemfill)
- [Capsule](https://developer.apple.com/documentation/swiftui/capsule)
- [GlassButtonStyle](https://developer.apple.com/documentation/swiftui/glassbuttonstyle)
- [ButtonBorderShape](https://developer.apple.com/documentation/swiftui/buttonbordershape)
- [ControlSize](https://developer.apple.com/documentation/swiftui/controlsize)
- [Rejected bordered TextFieldStyle](https://developer.apple.com/documentation/swiftui/textfieldstyle)
- [Rejected textInputBorderShape](https://developer.apple.com/documentation/swiftui/view/textinputbordershape%28_%3A%29)
- [Menus and actions](https://developer.apple.com/design/human-interface-guidelines/menus)
- [Progress indicators](https://developer.apple.com/design/human-interface-guidelines/progress-indicators)
- [DataScannerViewController](https://developer.apple.com/documentation/visionkit/datascannerviewcontroller)
- [SF Symbols](https://developer.apple.com/sf-symbols/)

## Acceptance

- **Sign In** on Welcome pushes this screen and native Back returns to Welcome.
- The field label and helper or error copy align with the editable text inset.
- Tapping the field focuses the native SecureField and opens the keyboard.
- Empty and unfocused shows Paste and Scan QR Code; focused shows the outside Close action; populated and unfocused shows Clear without an outside action.
- Close dismisses the keyboard without clearing the field.
- The primary action is disabled for empty values and values that do not begin with `nsec`.
- Invalid input displays the approved recovery copy.
- A prototype-valid value enables Sign In.
- The field is a 50-point filled capsule that visually belongs with the accepted Name/About fields and aligns with the circular QR action.
- The trailing action never overlaps or obscures the secure value.
- Sign In replaces its visible label with a centered native spinner without changing button dimensions or losing contrast.
- In Light Mode the prominent action has white content on black; in Dark Mode it has black content on white, including normal, disabled, and loading states.
- During the four-second processing state, the field uses SwiftUI's system disabled treatment, accepts no input, and shows no internal or external accessory actions.
- Scan QR Code pushes the scanner screen and a scanned or sample payload returns to Sign In.
- The screen uses the same white onboarding canvas as Sign Up.
