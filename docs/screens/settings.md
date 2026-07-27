# Settings

## Purpose and navigation

Settings is the native in-app hub for the active White Noise profile. Tapping the Chats avatar pushes a SwiftUI `Form` in the existing `NavigationStack`; the system Back action returns to Chats.

All data and outcomes are fictional, deterministic, and process-local. The prototype never performs authentication, cryptography, relay access, notification registration, payment, persistence, or network requests.

## Hub

- No visible category headings or explanatory subtitles.
- The active profile row shows its 56-point avatar, name, shortened public key, QR symbol, and the native disclosure indicator. It opens **Share Profile**.
- The initial **Marmota** profile and deterministic profiles created through Sign In or Sign Up use the bundled, user-supplied marmot photo unless replaced in Profile editing.
- A normal first Sign In or Sign Up session stores exactly one active profile. No inactive profile is preloaded.
- Completing the first **Add Profile** flow also reveals the deterministic pseudonym set used to exercise multi-profile management. The newly added profile becomes active, and Settings immediately presents the compact three-avatar-plus-overflow switcher row.
- Profile management adapts to stored profile count:
  - One profile: **Add Profile**, which opens onboarding directly rather than presenting the switcher.
  - Two profiles: the newly added alternate profile identity.
  - Three or more: **Switch Profile**, up to three overlapping inactive avatars, and an opaque adaptive `+N` overflow badge.
- Main card: **Profile**, **Profile Keys**, **Notifications**, **Appearance**, **Privacy & Security**, **Data & Storage**, **Relays**.
- Support card: **Chat with support**, **Donate**, **Developer Tools**.
- Final isolated destructive row: **Sign Out**.
- Footer: **White Noise · VERSION (BUILD)**.

The switcher is a native medium/large sheet with an inset-grouped `List`, active checkmark, unread badges, row-scoped switching progress, system drag indicator, and a prominent **Add Profile** action. Medium content gestures expand the sheet; the large sheet scrolls when required.

The screenshot-ready pseudonym set is **Quiet Current**, **Silver Fern**, **Night Archive**, **Amber Signal**, and **Tidal Echo**. Each uses a distinct locally bundled abstract nature photograph so the identities feel personal without implying five different people.

Profile avatar provenance:

- Generated with OpenAI's built-in image generation tool on July 27, 2026.
- Subjects: river stones and ripples, a fern canopy, a clouded mountain valley, amber ice, and tidal sand channels.
- Constraints: face-free, text-free, logo-free natural photography composed for circular avatar crops.
- Transformation: downscaled to 512-by-512 JPEG assets and clipped into circles at runtime.
- Intended use: deterministic pseudonym avatars in Settings, the profile switcher, and App Store screenshot source captures.

## Destinations

### Share Profile

- A native segmented `Picker` in the navigation bar switches between **Share**
  and **Scan** without leaving the destination.
- Share uses the accepted onboarding-scale 128-point profile avatar, the
  profile name, a locally generated fictional QR code, and the system
  `ShareLink`.
- Copy: **Let people scan this code to find your profile on White Noise.**
- The full fictional public key appears in an adaptive
  `secondarySystemFill` capsule with an icon-only `doc.on.doc` action. This is
  an intentional read-only composition because SwiftUI has no stock
  read-only filled field with a trailing copy action.
- The copy action changes to `checkmark` after activation and remains a
  44-point native button target.
- Safety: **Your public key is safe to share. Never share your private key.**
- Scan uses VisionKit `DataScannerViewController` with native guidance and
  highlighting on supported iPhones. The simulator uses a deterministic
  camera substitute and returns the fictional **Quiet Current** profile.
- A recognized profile is presented with native
  `ContentUnavailableView` structure and **Done** / **Scan Another** actions.
- Camera permission denial, restricted access, unavailable hardware, and
  unrecognized QR content have explicit native recovery states.

### Profile

- Native `PhotosPicker`, file importer, image-URL sheet, and Remove action for the in-memory avatar.
- Name, About, Nostr Address, and Lightning Address fields in a native `Form`.
- **Generate Name** supplies a deterministic pet name.
- Public notice: **Your name, profile photo, about text, Nostr address, and Lightning address are public.**
- Native toolbar **Save** action with deterministic progress.

### Profile Keys

- Public key Copy action.
- Safety: **Anyone with your private key can use your profile. Keep it private. White Noise can't recover it if you lose it.**
- **Create Encrypted Backup** presents password, confirmation, minimum-length validation, strength progress, deterministic creation progress, and a fictional shareable result.
- **Export Raw Private Key** requires a separate destructive confirmation and exposes only a fictional result through the system share sheet.
- Private-key material is never displayed inline.

### Notifications

- Local Notifications.
- Native Push Notifications.
- Preview mode: **Sender and Message**, **Sender Only**, or **Generic**, with a deterministic example.
- Static prototype delivery status.

### Appearance

- Appearance: **System**, **Light**, **Dark**. No True Black mode.
- Language: **System** or **English**.
- Return key: **New Line** or **Send Message**.
- Message Colors destination with incoming/outgoing semantic presets, preview bubbles, and Reset.

### Privacy & Security

- App Lock and conditional auto-lock interval.
- Block Screenshots.
- Anonymous Telemetry.
- Audit Logging, View Audit Files, and destructive Delete Audit Files confirmation.
- All controls are simulations; LocalAuthentication and real audit storage are out of scope.

### Data & Storage

- Media Quality: **Low**, **Standard**, **High**, **Original**.
- Auto-download destinations for Photos, Audio, Videos, and Files.
- Each media type supports **Never**, **Wi-Fi**, and **Wi-Fi and Cellular**.
- Reset Download Settings.

### Relays

- A native `Form` presents each relay using regular semantic SF Pro typography and `LabeledContent`.
- The main relay-list footer uses production copy: **Relays help White Noise find profiles and exchange messages.**
- Every row places the relay name above its URL and shows one compact trailing simulated connection-state indicator:
  - `checkmark.circle.fill` for **Connected**.
  - A regular, neutrally tinted indeterminate `ProgressView` for **Reconnecting**.
  - `xmark.circle.fill` for **Disconnected**.
- The spinner uses SwiftUI's default regular control size so it isn't artificially smaller than the status symbols. `LabeledContent` owns the shared trailing alignment; no fixed icon frames are used.
- Connected and disconnected use semantic success/error colors. Reconnecting remains neutral because ongoing activity is not a warning. VoiceOver receives the full **Connected**, **Reconnecting**, or **Disconnected** value.
- Representative deterministic fixtures:
  - Primal — `wss://relay.primal.net` — Connected.
  - Damus — `wss://relay.damus.io` — Connected.
  - nos.lol — `wss://nos.lol` — Connected.
  - Nostr.Band — `wss://relay.nostr.band` — Connected.
  - Vertex — `wss://relay.vertexlab.io (Read Only)` — Connected.
  - White Noise Profile — `wss://relay.whitenoise.chat` — Reconnecting.
  - White Noise Inbox — `wss://inbox.whitenoise.chat` — Disconnected.
- `EditButton` owns native Edit and Done states. Native deletion controls and the **Add Relay** row appear only during editing; normal-mode swipe-to-delete is disabled.
- **Add Relay** opens a medium native sheet with Cancel and Add toolbar actions, a URL field, and the helper **Enter a relay URL beginning with wss://.**
- Add remains system-disabled for malformed or duplicate URLs. Once the URL is valid, Add uses the native adaptive monochrome `glassProminent` treatment, appearing black in Light Mode. A newly added relay deterministically changes from **Reconnecting** to **Connected** after 1.5 seconds.
- A standard **Advanced** `NavigationLink` appears at the bottom of the Form.
- **Advanced** is one native scrolling `Form`, without another navigation level. It exposes three direct checkmark-selection sections:
  - **Publishing** — **Sends your profile information.**
  - **Mentions** — **Tells people where to send mentions of your profile.**
  - **Messages** — **Receives your private messages.**
- Advanced section headers are plain native text without decorative symbols. Native `Form` and `Section` own the grouped spacing; no custom section padding or numeric spacing is introduced.
- A relay can serve more than one role. At least one relay must remain selected in every role.
- Read-only relays remain visible with **(Read Only)** beside the URL, and their Advanced selection rows are disabled. User-facing explanations describe this capability generally and never name a fixture relay.
- The public relay fixtures are representative examples rather than a popularity ranking or availability report.
- All statuses and transitions remain deterministic in-memory prototype behavior, but that implementation boundary appears only in this documentation—not in product-surface copy.

Relay operator references verified July 27, 2026:

- [Primal network settings](https://primal.net/settings/network)
- [Nostr.Band relay](https://relay.nostr.band/)
- [Vertex relay documentation](https://vertexlab.io/docs/services/nostr-relay/)

### Chat with support

- Explains that support opens a private White Noise conversation.
- **Start Support Chat** uses deterministic progress and a ready state; no conversation or backend is fabricated.

### Donate

- Lightning and Bitcoin donation methods.
- Locally generated QR codes, exact public-address Copy actions, and copied feedback.
- No wallet, payment, or network integration.

### Developer Tools

- Runtime, local signing state, profile identifier, fictional local hex key, and MarmotKit status.
- Developer Mode and Streaming Debug controls.
- Key Packages list with fictional publish/delete behavior.
- Diagnostics with relay health, runtime facts, deterministic self-check progress, and recent events.

### Sign Out

- **Sign Out and Keep Profile** is reversible and preserves the in-memory profile for switching.
- **Remove Profile from This Device** is destructive and requires a separate named confirmation.
- Both operations use stable progress before returning to another profile or Welcome.

## Native implementation rules

- `Form`, `List`, `Section`, `NavigationLink`, `Picker`, `Toggle`, `TextField`, `SecureField`, `PhotosPicker`, `ShareLink`, `ProgressView`, `confirmationDialog`, alerts, sheets, and system toolbars own their standard geometry and behavior.
- Liquid Glass is limited to approved primary actions. Settings rows and grouped cards remain Form-owned.
- SF Symbols, semantic colors, Dynamic Type styles, native separators, system margins, and system motion are used throughout.
- Explicit avatar dimensions and the compact profile-overflow composition remain the existing user-approved custom exceptions.

## Accessibility

- Native controls retain their labels, values, traits, focus, and Dynamic Type behavior.
- Profile rows combine visible name and shortened public key; decorative avatars are hidden from assistive technologies.
- Progress, validation, selected state, privacy warnings, destructive consequences, and copied state are communicated without color alone.

## Product references

- [Settings hub #850](https://github.com/marmot-protocol/whitenoise-ios/issues/850)
- [Share Profile #851](https://github.com/marmot-protocol/whitenoise-ios/issues/851)
- [Profile Keys #852](https://github.com/marmot-protocol/whitenoise-ios/issues/852)
- [Profile editing #853](https://github.com/marmot-protocol/whitenoise-ios/issues/853)
- [Sign Out and removal #854](https://github.com/marmot-protocol/whitenoise-ios/issues/854)
- [Appearance #833](https://github.com/marmot-protocol/whitenoise-ios/issues/833)
- [Notification privacy #873](https://github.com/marmot-protocol/whitenoise-ios/issues/873)
- [Chat with support #874](https://github.com/marmot-protocol/whitenoise-ios/issues/874)
- [Lightning Address #791](https://github.com/marmot-protocol/whitenoise-ios/issues/791)
- [Public profile notice #792](https://github.com/marmot-protocol/whitenoise-ios/issues/792)
- [Backup password strength #795](https://github.com/marmot-protocol/whitenoise-ios/issues/795)
- [Return Key Sends #784](https://github.com/marmot-protocol/whitenoise-ios/issues/784)
- [Message colors #760](https://github.com/marmot-protocol/whitenoise-ios/issues/760)
- [Relay health #781](https://github.com/marmot-protocol/whitenoise-ios/issues/781)

## Apple references

- [Settings](https://developer.apple.com/design/human-interface-guidelines/settings)
- [Lists and tables](https://developer.apple.com/design/human-interface-guidelines/lists-and-tables)
- [Form](https://developer.apple.com/documentation/swiftui/form)
- [NavigationLink](https://developer.apple.com/documentation/swiftui/navigationlink)
- [Picker](https://developer.apple.com/documentation/swiftui/picker)
- [Toggle](https://developer.apple.com/documentation/swiftui/toggle)
- [PhotosPicker](https://developer.apple.com/documentation/photosui/photospicker)
- [ShareLink](https://developer.apple.com/documentation/swiftui/sharelink)
- [ProgressView](https://developer.apple.com/documentation/swiftui/progressview)
- [EditButton](https://developer.apple.com/documentation/swiftui/editbutton)
- [EditMode](https://developer.apple.com/documentation/swiftui/editmode)
- [LabeledContent](https://developer.apple.com/documentation/swiftui/labeledcontent)
- [Sheets](https://developer.apple.com/design/human-interface-guidelines/sheets)
- [Alerts](https://developer.apple.com/design/human-interface-guidelines/alerts)
- [SF Symbols](https://developer.apple.com/sf-symbols/)

## Acceptance

- Every hub row opens its working destination; no development placeholder remains.
- After the first Sign In or Sign Up, Settings contains one profile and displays **Add Profile** instead of **Switch Profile**.
- Completing Sign In or Sign Up from **Add Profile** appends or reactivates that profile, reveals the deterministic pseudonym set, makes the added profile active, and changes profile management to the multi-profile presentation.
- Profile editing, sharing, switching, adding, signing out, and removing update only deterministic in-memory state.
- Every visible settings control works or presents a deterministic outcome without exposing prototype implementation language.
- Appearance updates the prototype immediately; notification, privacy, storage, relay, and developer choices remain consistent while the process runs.
- Destructive and secret-related actions use distinct native confirmations and exact safety language.
- The complete app builds with Xcode 27 beta and contains no third-party runtime dependency or network/persistence implementation.
