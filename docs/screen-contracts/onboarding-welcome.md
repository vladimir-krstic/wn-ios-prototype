# Screen contract: Welcome

- ScreenID: `onboarding.welcome`
- Status: `draft`
- Audience: product
- Approvals: user pending; independent review pending

## Purpose and outcome

Give an everyday person an unmistakable White Noise entry point and exactly two choices: continue with an existing profile or create a new one. The screen must not explain protocols, privacy technology, keys, relays, or prototype mechanics.

Show the approved adaptive White Noise logomark without a headline, slogan, body copy, page control, legal links, or permission request. Place **Login** above **Sign Up** as native actions in the lower action region.

## Entry, exit, and navigation

- Entry: normal unconfigured launch; scenario `welcome-default`; returning from either child destination.
- **Login** pushes `onboarding.sign-in` on the product `NavigationStack`.
- **Sign Up** pushes `onboarding.sign-up` on the same stack.
- The Welcome destination is the root and has no Back control.
- Both child destinations retain the native Back button and interactive swipe-back behavior.
- No automatic navigation, timer, carousel, deep link, sheet, alert, or destructive exit belongs to this screen.

## Native composition

- One root `NavigationStack` owned by the onboarding flow.
- A layout built from native SwiftUI containers and safe-area-aware spacing.
- The approved adaptive logomark is the only custom visual asset. It keeps its aspect ratio, remains visually prominent without crowding the actions, and never becomes a tappable control.
- **Login** and **Sign Up** are full-width native buttons. **Login** uses the system bordered secondary treatment; **Sign Up** uses the system prominent primary treatment. Their appearance follows iOS 27 and the approved adaptive accent; custom Liquid Glass treatment is not authorized.
- Keep both actions visible without scrolling on supported iPhones at default text sizes. At accessibility text sizes, content may reflow or scroll rather than clip or overlap.

## Exact product copy

Visible strings, in reading order:

1. **Login**
2. **Sign Up**

There is no other authored product copy on this screen. `Login` is the approved Welcome entry term; the following credential destination uses `Sign In`.

## Actions and state

| Control | Availability | Result |
|---|---|---|
| **Login** | Always enabled | Dispatch the typed onboarding route action and push `onboarding.sign-in`. |
| **Sign Up** | Always enabled | Dispatch the typed onboarding route action and push `onboarding.sign-up`. |

The screen has one deterministic state. It does not own loading, empty, offline, permission, success, or error variants. Repeated taps cannot produce duplicate destinations.

## Appearance and accessibility

- Light and Dark appearance use the approved corresponding logomark treatment and semantic system background/foreground colors.
- Buttons use semantic text styles and Dynamic Type. No visible text truncates at supported sizes.
- VoiceOver order is **Login**, then **Sign Up**. Each button exposes its visible name and Button trait; do not add redundant hints such as “button.”
- The logomark exposes the approved VoiceOver label **White Noise** and no Button trait or hint.
- Voice Control can address both controls by their visible names. Each action has at least a 44-point practical hit target.
- Meaning and hierarchy do not depend on color. Increased Contrast and Bold Text preserve legibility.
- There is no custom motion or haptic. Native navigation respects Reduce Motion automatically.
- Layout mirrors safely in RTL while the logomark itself is not mirrored. It tolerates pseudo-localization expansion even though the two approved English labels are short.
- Hardware-keyboard focus order matches reading order when keyboard access is enabled.

## System integrations and privacy

None. Welcome must not request notifications, photos, camera, microphone, files, contacts, or tracking access. It reads and writes no persisted data and exposes no team-only identifiers or diagnostics.

## Required scenarios and previews

- `welcome-default` is the canonical launch scenario.
- Compile previews for default Light, Dark, accessibility Dynamic Type, and localization/RTL stress.
- The catalog-wide error and long-content preview requirements are satisfied here by documenting them as not applicable: this screen has no fallible operation or authored long content. Accessibility-size and localization expansion previews remain mandatory.

## Acceptance criteria

1. An unconfigured normal launch shows only the adaptive White Noise logomark, **Login**, and **Sign Up**.
2. **Login** is visually and semantically before **Sign Up** and opens `onboarding.sign-in` exactly once.
3. **Sign Up** opens `onboarding.sign-up` exactly once.
4. Returning from either destination restores Welcome without state drift.
5. No product-visible or accessibility-visible developer terminology, scenario identifiers, permission language, legal copy, or marketing copy appears.
6. The layout has no clipping, overlap, unsafe-area collision, or forced scrolling at default sizes on iPhone 17e, iPhone 17 Pro, and iPhone 17 Pro Max in portrait.
7. Light, Dark, Bold Text, Increased Contrast, largest accessibility Dynamic Type, VoiceOver, Voice Control, keyboard focus, pseudo-localization, and RTL checks pass.
8. Unit tests cover the two typed route actions and duplicate-tap protection; UI tests cover normal launch, both exits, Back restoration, and accessibility identifiers scoped to tests rather than product output.

## Evidence disposition

### Apple authority

- `APPLE-DESIGN-001`: [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/) governs hierarchy, platform conventions, and feedback.
- `APPLE-BRAND-001`: [Communicate your brand identity on iOS](https://developer.apple.com/videos/play/wwdc2026/251/) supports expressing White Noise identity without replacing native structure.
- `APPLE-NAV-001`: [NavigationStack](https://developer.apple.com/documentation/swiftui/navigationstack) governs hierarchical navigation.
- `APPLE-A11Y-001`: [SwiftUI accessibility fundamentals](https://developer.apple.com/documentation/swiftui/accessibility-fundamentals) governs labels, traits, order, and native-control behavior.
- `APPLE-A11Y-003`: [Dynamic Type](https://developer.apple.com/documentation/swiftui/environmentvalues/dynamictypesize) governs accessibility text stress.

### White Noise direction

- `wn-ios-agile` issues #827 and #830 establish the current sparse Welcome direction and entry terminology.
- [White Noise product language](../product-language.md) fixes **Login** on Welcome and **Sign Up** for new-profile entry.
- Approved Light asset: [black vector logomark](https://github.com/user-attachments/assets/380c4ced-474f-4a54-83a4-169db2164f8c).
- Approved Dark asset: [white vector logomark](https://github.com/user-attachments/assets/1bd78fac-3d62-4bd8-90a5-30e3fbdb6072).

### Mobbin comparisons

- [Signal Onboarding](https://mobbin.com/flows/f3ea2f8a-16dd-4933-bb89-f2b6995a3ab2), 27 screens, uploaded 2023-05-09 at 375x812. Accept the brand-led, low-jargon opening and clear reachable action. Reject its slogan, legal links, and Welcome-adjacent permission setup.
- [Telegram Onboarding](https://mobbin.com/flows/dbaa5bd6-4975-4ae5-ad1f-fe54dff42faf), 12 screens, uploaded 2026-06-01 at 393x852. Accept generous whitespace, brand recognition, and bottom action placement. Reject its feature carousel, promotional copy, page control, and phone-number-first flow.

These comparisons answer focused layout and hierarchy questions only. They do not authorize copied assets, copy, measurements, or styling.

## Approval gate

- User decision requested: approve or revise the proposed outcome, exact copy, action order, and navigation.
- Asset blocker: retrieve the two approved user-supplied vectors above, bundle them without redrawing, and record source URLs, retrieval date, transformation, and intended use in the asset manifest before implementation.
- After user approval: obtain independent non-authoring contract review and disposition every finding.
- Do not implement until both approvals are recorded and the asset blocker is resolved.
