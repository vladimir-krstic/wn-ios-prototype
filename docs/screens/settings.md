# Settings

## Purpose and navigation

Settings is the native in-app hub for the active White Noise profile. Tapping the Chats avatar pushes a SwiftUI `Form` in the existing `NavigationStack`; the system Back action returns to Chats.

All data and outcomes are fictional, deterministic, and process-local. The prototype never performs authentication, cryptography, relay access, notification registration, payment, persistence, or network requests.

## Hub

- No visible category headings or explanatory subtitles.
- The active profile row shows its 56-point avatar, name, shortened public key, QR symbol, and the native disclosure indicator. It pushes **Share & Connect** inside the existing Settings navigation stack.
- The initial **Marmota** profile alone uses the bundled, user-supplied marmot photo. **Pebble** uses a distinct stone photograph, and Sign In creates **Open Circuit** with its own communications-history artwork.
- A normal first Sign In or Sign Up session stores exactly one active profile. No inactive profile is preloaded.
- Completing the first **Add Profile** flow also reveals the deterministic pseudonym set used to exercise multi-profile management. The newly added profile becomes active, and Settings immediately presents the compact three-avatar-plus-overflow switcher row.
- Profile management adapts to stored profile count:
  - One profile: **Add Profile**, which opens onboarding directly rather than presenting the switcher.
  - Two profiles: the newly added alternate profile identity.
  - Three or more: **Switch Profile**, up to three overlapping inactive avatars, and an opaque adaptive `+N` overflow badge.
- Main card: **Profile**, **Profile Keys**, **Notifications**, **Appearance**, **Privacy & Security**, **Data Usage**, **Relays**.
- Support card: **Chat with support**, **Donate**, **Developer Tools**.
- Final isolated destructive row: **Sign Out**.
- Footer: **White Noise · VERSION (BUILD)**.

The switcher is a native medium/large sheet with an inset-grouped `List`, active checkmark, unread badges, row-scoped switching progress, system drag indicator, and a prominent **Add Profile** action. Medium content gestures expand the sheet; the large sheet scrolls when required.

The screenshot-ready pseudonym set is **Open Quill**, **Cipher Wheel**, **Free Signal**, **Public Voice**, and **Liberty Relay**. Their names and avatars connect each identity to publishing, privacy, free expression, or open communications without presenting unrelated real people as the profile owner.

Profile avatar provenance:

- **Pebble:** locally bundled stone image generated for the prototype on July 27, 2026.
- **Open Circuit:** 1888 drawing of Heinrich Hertz's spark transmitter and parabolic antenna, public domain.
- **Open Quill:** modern printing press photograph published under CC0.
- **Cipher Wheel:** Jefferson disk cipher photograph created by the U.S. National Security Agency, public domain as a U.S. Government work.
- **Free Signal:** 1926 photograph of Marconi's first radio transmitter, public domain.
- **Public Voice:** First Amendment creamware plate photograph published under CC0.
- **Liberty Relay:** Library of Congress photograph of a White House telegraph key, with no known copyright restrictions and marked public domain in the United States.
- Retrieved July 28, 2026 from the linked Wikimedia Commons file pages. Profile imagery is bundled at a maximum 512-pixel dimension and clipped into a circle at runtime; original aspect ratios and visual content are preserved.
- Intended use: deterministic pseudonym avatars in Settings, the profile switcher, and App Store screenshot source captures.

Source pages:

These links preserve asset provenance only. The local asset descriptions,
transformations, intended uses, and acceptance criteria are complete and do
not require the source pages during normal work.

- [Hertz spark transmitter drawing](https://commons.wikimedia.org/wiki/File:Drawing_of_Heinrich_Hertz_spark_radio_transmitter_and_parabolic_antenna_1888.jpg)
- [Modern printing press](https://commons.wikimedia.org/wiki/File:Modern_printing_press_(Unsplash).jpg)
- [Jefferson disk cipher](https://commons.wikimedia.org/wiki/File:Jefferson%27s_disk_cipher.jpg)
- [Marconi's first radio transmitter](https://commons.wikimedia.org/wiki/File:Marconi%27s_first_radio_transmitter.jpg)
- [First Amendment creamware plate](https://commons.wikimedia.org/wiki/File:Creamware_plate_with_First_Amendment_to_the_US_Constitution,_c._1838_(NMAH_227739.1838.I01).jpg)
- [White House telegraph key](https://commons.wikimedia.org/wiki/File:White_House_(Telegraph_key)_LCCN2016870915.jpg)

## Destinations

### Share & Connect

- The Settings profile row uses a native `NavigationLink`. Share & Connect
  slides in from the trailing edge, uses the system Back chevron and
  interactive swipe-back gesture, and returns to Settings without modal
  dismissal.
- Share uses a native grouped `Form`, allowing the system to provide the
  adaptive Settings background, inset sections, margins, Light/Dark
  appearance, and scrolling behavior.
- The native top toolbar keeps a centered SwiftUI `Picker` using the palette
  style for **Share / Connect** and the system Share action on the right while
  Share is selected. The picker remains one stable toolbar control at the
  native extra-large control size while its selection changes. The toolbar
  allocates the control the wider footprint shown in the supplied Apple
  Messages reference while the native picker continues to own its internal
  segment widths and label insets. It applies no custom font, background,
  tint, corner radius, glass, or custom selection animation. SwiftUI and the
  toolbar own intrinsic size, label insets, the Liquid Glass selection island,
  interaction motion, and accessibility.
- **Share** is selected initially; the trailing toolbar uses the system
  `ShareLink` to share the profile name and full fictional public key.
- Share uses the same one-third-of-available-width avatar sizing rule as Sign
  Up, followed by the profile name and locally generated fictional QR code.
- A quiet semantic-gray npub button appears directly beneath the profile name.
  Its adaptive `secondarySystemFill` capsule uses secondary-colored monospaced
  subheadline text, a compact visual height, and a shorter middle-truncated key
  presentation without glass, a border, shadow, or custom motion. The avatar,
  name, and visible capsule use matching eight-point intervals.
- The button copies the full key while preserving a trailing Copy symbol and
  the final four visible key characters. The displayed key keeps its first 14
  characters, six fewer than the previous treatment.
- Copy replaces `doc.on.doc` with `checkmark` without changing control geometry,
  because both medium-weight, secondary-colored caption symbols occupy the
  same 14-point frame. It provides visible, haptic, and VoiceOver confirmation
  and returns to Copy after two seconds. Another activation restarts the
  cancelable reset interval.
- The black QR matrix occupies 81 percent of the available width, making the
  matrix 15 percent larger than the supplied comparison screenshot.
- Its continuous 16-point white container hugs the matrix with four points of
  equal padding on every side; the generated bitmap adds no second white
  wrapper.
- Centered **Scan to connect.** sits outside the white container, six points
  below it.
- Share presents the profile identity and npub action first, followed by the QR
  card and its attached caption.
- The Form uses its default native section spacing between the profile and QR
  sections, without asymmetric padding, custom spacer rows, or a bottom
  scroll-edge mask.
- **Connect** keeps the palette control visible while scanner content extends
  edge to edge behind the system toolbar. The navigation-bar background is
  hidden so the toolbar’s native controls remain over the camera rather than
  on a separate surface. The system Back action stays available and the Share
  toolbar action is hidden in this mode.
- Scan uses VisionKit `DataScannerViewController` with native guidance and
  highlighting on supported iPhones. The simulator uses a deterministic
  camera substitute and returns the fictional **Open Quill** profile.
- A recognized profile is presented with native
  `ContentUnavailableView` structure and **Done** / **Scan Another** actions.
- Camera permission denial, restricted access, unavailable hardware, and
  unrecognized QR content have explicit native recovery states.

### Profile

- Profile is a native pushed Settings destination with the centered **Profile**
  title, system Back behavior, and a trailing **Edit** action. Edit changes to
  a prominent trailing **Done** action while a draft is active and temporarily
  replaces Back with the
  native leading **Cancel** action. Cancel discards the complete draft and
  returns to read-only presentation without navigating away. Done commits the
  in-memory draft when it changed, otherwise simply exits editing, returns to
  read-only presentation, and does not dismiss the destination.
- The avatar, one-third-of-available-width sizing, monogram treatment, photo
  action, source menu, Name card, and About card reuse the same local components
  and native Form structure as Sign Up.
- The photo action appears only while editing and reads **Add Photo** or
  **Change Photo**. Its native menu provides **Choose from Photos**, **Choose
  from Files**, and **Remove Photo** when applicable.
- `PhotosPicker` and `fileImporter` retain their system presentation. Selected
  photos are normalized to a maximum 512-pixel dimension before being held in
  memory.
- Name and About are read-only until Edit is chosen. While editing, they use
  separate native grouped Form cards with the same prompts, semantic fill,
  focus order, multiline behavior, and Dynamic Type behavior as Sign Up.
- Profile contains no generated-name action, dice symbol, Nostr Address field,
  Lightning Address field, or email-shaped placeholder.
- Done remains available when the unchanged draft is valid so it can exit edit
  mode. It is disabled only when the required Name is empty.

### Profile Keys

- **Public Key** shows the profile's complete public identifier in a
  single-line, middle-truncated monospaced field with a trailing Copy/checkmark
  control. Its help text reads **Share this key so people can find and connect
  with you.**
- **Private Key** is hidden by default and uses the native eye/eye-slash action
  to reveal or hide the deterministic key-shaped value. The value is marked
  privacy-sensitive, uses normal enabled-text contrast while concealed, and
  remains hidden from accessibility speech even while it is visible onscreen.
- **Copy Private Key** copies the complete value without requiring it to be
  revealed. Public and private copy actions provide a checkmark, success
  haptic, and a concise VoiceOver announcement, then reset after two seconds.
- Private-key help reads **Keep this key private. Anyone with it can use your
  profile, and White Noise can’t recover it.**
- **Export Encrypted Private Key** is the first export action. It presents a native
  sheet with Password, Confirm Password, password guidance, mismatch feedback,
  and a native strength indicator. Mismatch feedback replaces the field help
  in that section's footer instead of appearing as a separate Form row. The
  strength bar retains the visible **Low**, **Fair**, or **Strong** label and
  supplements it with the system red, yellow, or green color. Its prominent
  **Export** action becomes
  available when both nonempty values match, then
  dismisses the sheet and opens the system Files save interface.
- **Export Private Key** presents a destructive confirmation advising the
  person to keep the file secure and prefer the encrypted export or a trusted
  password manager, then opens the same system Files save interface.
- Both exports use SwiftUI `FileDocument` and `fileExporter` with deterministic
  process-local key-shaped content. They add no real cryptography, credentials,
  persistence, or custom file browser.

### Notifications

- **Local Notifications** creates the visible message notification from details
  processed on the iPhone. Without Native Push, delivery may wait until White
  Noise is active.
- **Native Push** sends a generic APNs wake-up so White Noise can check for new
  messages in the background; message details remain on the iPhone. It
  supplements Local Notifications rather than creating a second alert, so both
  can be enabled together and Native Push becomes unavailable when Local
  Notifications is off.
- The two delivery options use separate native Form sections with their own
  concise descriptions.
- The screen reads the live `UNNotificationSettings.authorizationStatus`.
  Delivery toggles and preview controls are disabled without iOS authorization.
  An undetermined state offers **Allow Notifications** and invokes the native
  permission prompt; a denied state explains the dependency and offers **Open
  Settings**, deep-linked to this app's notification settings. The denied state
  stays informational: **Notifications are off** uses primary text, its concise
  explanation and `bell.slash` symbol use secondary styling, and no warning
  color or custom surface is added.
- Preview mode: **Sender and Message**, **Sender Only**, or **Generic**, with a deterministic example.
- No static permission or push-service status is shown.

### Appearance

- Appearance: **System**, **Light**, **Dark**. No True Black mode.
- **Language** uses the native navigation-link `Picker` style. The Appearance
  row pushes Apple's system-owned single-selection list with checkmarks rather
  than opening an increasingly crowded menu.
- The intended language choices are **System**, **English**, **German**,
  **Spanish**, **French**, **Italian**, **Portuguese**, and **Serbian**.
  **System** follows the iPhone's preferred supported language.
- English remains the only authored localization in the current prototype.
  Shipping another selectable language requires adding and completing that
  localization in an Xcode string catalog; the selector does not stand in for
  translated product copy.
- Appearance contains no Return Key or Message Colors preferences.
- Governing Apple sources: [Settings](https://developer.apple.com/design/human-interface-guidelines/settings),
  [Picker](https://developer.apple.com/documentation/swiftui/picker),
  [Supporting multiple languages in your app](https://developer.apple.com/documentation/xcode/supporting-multiple-languages-in-your-app),
  and [Localizing and varying text with a string catalog](https://developer.apple.com/documentation/xcode/localizing-and-varying-text-with-a-string-catalog).

### Privacy & Security

- Privacy & Security uses two separate native Form sections so each independent
  preference has its own explanation. There is no redundant section header,
  and no icons or custom control styling are added.
- **Hide Screen in App Switcher** replaces sensitive content before UIKit
  captures the app-switcher snapshot. Its footer reads **Hides your
  conversations and profile details in the app switcher.** It does not claim
  to block screenshots or screen recording.
- **Require Face ID** uses device-owner authentication. Its normal footer reads
  **Locks White Noise when you leave. Your iPhone passcode can be used if Face
  ID isn't available.** If Face ID is not enrolled, the iPhone passcode
  remains the system fallback and the footer names that state directly.
- No separate White Noise PIN is offered. If the iPhone has no passcode,
  Require Face ID is disabled with **Set an iPhone passcode to require Face
  ID.**
- Enabling Require Face ID reveals the native **Auto-Lock** picker.
- The Signal App Security structure was accepted as optional comparison
  evidence. The local requirements above are complete and do not depend on
  Signal's repository or continued access to it.
- App-switcher privacy and Face ID locking are deterministic simulations;
  LocalAuthentication and real snapshot replacement remain out of scope.
- Governing Apple sources: [Local Authentication](https://developer.apple.com/documentation/localauthentication),
  [device-owner authentication](https://developer.apple.com/documentation/localauthentication/lapolicy/deviceownerauthentication),
  [canEvaluatePolicy](https://developer.apple.com/documentation/localauthentication/lacontext/canevaluatepolicy(_:error:)),
  and [Preparing your UI to run in the background](https://developer.apple.com/documentation/uikit/preparing-your-ui-to-run-in-the-background).

### Data Usage

- **Auto-Download** is the first native Form section, with disclosure rows in
  this order: **Photos**, **Videos**, **Audio**, and **Files**.
- Each media type supports **Never**, **Wi-Fi**, and **Wi-Fi and Cellular**.
- **Reset Auto-Download Settings** restores the local defaults and is disabled
  when those defaults are already selected.
- **Sent Media** contains one **Sent Media Quality** disclosure. Its native
  single-selection destination has a **Photos and Videos** section with plain
  **Standard** and **High** rows.
- The quality selection footer reads **High sends uncompressed photos and
  videos for better quality, but uses more data. Standard compresses media to
  use less data.**
- The main-page Sent Media footer reads **Choose the quality for photos and
  videos you send.** There is no Calls section because calls are not part of
  this prototype.
- Signal's hierarchy was accepted as optional comparison evidence. The local
  requirements above are complete and don't require continued access to
  Signal or another project.
- Governing Apple sources: [Settings](https://developer.apple.com/design/human-interface-guidelines/settings),
  [Form](https://developer.apple.com/documentation/swiftui/form),
  [NavigationLink](https://developer.apple.com/documentation/swiftui/navigationlink),
  [List](https://developer.apple.com/documentation/swiftui/list),
  and [Button](https://developer.apple.com/documentation/swiftui/button).

### Relays

- Relay configuration belongs to the active profile. Switching profiles shows
  an independent relay list and role selection; application-wide preferences
  remain in the separate Settings state.
- A native `Form` presents one union list of configured relay endpoints. The
  main list is the complete overview; there is no Advanced Relays destination.
- The main relay-list footer reads **Relays let your profile publish
  information, receive chat invitations, and deliver messages.**
- Every collapsed relay row uses the same restrained two-line hierarchy: relay
  name, URL, and trailing connection status. Role symbols are omitted from the
  overview. Read-only relays retain **(Read Only)** beside the URL.
- VoiceOver combines the relay name, complete URL, connection status, and
  read-only capability when applicable. Role controls remain individually
  accessible in Relay Details.
- Connection status uses:
  - `checkmark.circle.fill` for **Connected**.
  - A regular, neutrally tinted indeterminate `ProgressView` for **Reconnecting**.
  - `xmark.circle.fill` for **Disconnected**.
- The spinner uses SwiftUI's default regular control size so it isn't
  artificially smaller than the status symbols. No fixed icon frames are used.
- Connected uses system green, Reconnecting remains neutral active progress,
  and Disconnected uses system red as the user-approved concrete
  endpoint-failure status. Aggregate recovery callouts and links remain system
  orange so they read as recoverable guidance rather than destructive actions.
  VoiceOver continues to receive the full **Connected**, **Reconnecting**, or
  **Disconnected** value, so color is never the only signal.
- Representative deterministic fixtures:
  - Primal — `wss://relay.primal.net` — Connected.
  - Damus — `wss://relay.damus.io` — Connected.
  - nos.lol — `wss://nos.lol` — Connected.
  - Nostr.Band — `wss://relay.nostr.band` — Connected.
  - Vertex — `wss://relay.vertexlab.io (Read Only)` — Connected.
  - White Noise Profile — `wss://relay.whitenoise.chat` — Reconnecting.
  - White Noise Inbox — `wss://inbox.whitenoise.chat` — Disconnected.
- Every relay row uses a native `NavigationLink`. Relay Details contains Name,
  URL, Status, the three **Use For** toggles, and a destructive **Remove Relay**
  action at the bottom. The main list has no Edit mode, inline role controls,
  or swipe-to-delete behavior.
- **Add Relay** remains a visible standard row on the main list.
- Remove Relay opens a native alert titled **Remove [relay name]?** with
  **This profile will stop using this relay.**, destructive **Remove Relay**,
  and **Cancel**. Cancel preserves the relay. Confirmation first dismisses the
  alert and returns to Relays, then removes the endpoint from the parent list;
  Relay Details never invalidates its own active navigation destination.
- If removal would empty one or more roles, the same confirmation names the
  affected roles, states that this profile needs at least one relay for them,
  and names the unavailable capabilities. Confirmation is still allowed; the
  inline Relays recovery callout updates immediately afterward.
- A role is operational only while at least one assigned read/write relay is
  connected. Its state is **Available**, **Reconnecting**, **Disconnected**,
  or **Unassigned**; read-only relays never provide operational coverage. A
  connected sibling keeps the role available when another assigned relay is
  reconnecting or disconnected.
- Relays shows an orange inline callout titled **Profile relays need
  attention** whenever any role is unavailable. The detail groups roles by
  cause in this order: unassigned, disconnected, then reconnecting. It uses
  **Choose a relay for…**, **No … relay is connected**, and **…relays are
  reconnecting**, followed by one combined impact sentence using
  **publishing**, **invitations**, and **new chats**. **Temporarily
  unavailable** appears only when every affected role is reconnecting. When no
  assignable relay exists, the detail is **Add a relay to publish your profile,
  receive invitations, and start new chats.**
- **Add Relay** opens a medium native sheet with Cancel and Add toolbar actions,
  a URL field, the helper **Enter a relay URL beginning with wss://.**, and a
  native **Use For** Toggle for every role.
- Every new relay role starts selected. Add remains system-disabled for a
  malformed or duplicate URL or when every role is deselected. The endpoint is
  not appended or activated until Add is pressed. A newly added relay then
  changes deterministically from **Reconnecting** to **Connected** after 1.5
  seconds.
- The three independent roles are:
  - **Profile** — **Publishes your profile and connection information.**
  - **Inbox** — **Receives invitations to new chats and groups.**
  - **Chat Messages** — **Used for messages in chats you create. Existing chats
    keep their current relays.**
- Relay-detail role changes apply immediately and use standard native Toggles;
  there is no secondary Edit, Save, or Cancel mode. Turning off a role that is
  still assigned elsewhere is immediate. Turning off its final assignment
  first presents **Turn off [role]?**, states that this profile needs at least
  one relay for that role, explains the exact lost capability, and offers
  destructive **Turn Off** and **Cancel**. Confirmation permits the degraded
  state.
- A relay can serve more than one role. Relay Details is the sole role-editing
  surface, and changes update the shared configuration immediately.
- Read-only relays remain visible with **(Read Only)** beside the URL, and their
  Relay Details Toggles are disabled. The explanation reads
  **This relay is read only, so this profile can’t use it to send data.**
- Deterministic role fixtures are:
  - Primal — Profile, Inbox, Chat Messages.
  - Damus — Profile, Chat Messages.
  - nos.lol — Profile, Inbox, Chat Messages.
  - Nostr.Band — Profile.
  - Vertex — no assignable role; Read Only.
  - White Noise Profile — Profile, Chat Messages.
  - White Noise Inbox — Inbox.
- Chat Messages is a per-profile default for chats created afterward. It does
  not rewrite existing or incoming chat routing. Per-chat relay editing is
  deferred to a future chat or group-details flow.
- Production translation requires the transport layer to accept a per-profile
  default chat-routing input or public setter; the current process-construction
  default is not sufficient. Initial relay choice before first publication is
  likewise deferred to future onboarding work.
- A separate destructive **Restore Default Relays** action performs a confirmed
  full reset for the active profile. Its footer and confirmation state that the
  default relays and role assignments will replace this profile’s current
  configuration. It removes custom relays and restores the original seven
  endpoints and assignments; it is disabled while the configuration already
  matches those defaults.
- Unavailable roles affect only their dependent capabilities:
  - Without an available **Profile** relay, Profile remains readable but
    **Edit** is disabled.
  - Without an available **Inbox** relay, new chat and group invitations cannot
    arrive.
  - Without an available **Chat Messages** relay, **New Message**, **Start
    Chat**, and future chat/group creation actions are disabled.
  - Existing chat history, Share & Connect, Profile Keys, appearance, local
    settings, profile switching, and relay recovery remain available with every
    role missing. In the Fiatjaf prototype, the empty composer becomes the
    direct recovery route until relay setup is complete.
- Relays is the only destination that shows the complete recovery explanation.
  While a role is unavailable, Chats replaces New Message with a compact orange
  `exclamationmark.triangle` recovery link in the same system Liquid Glass
  toolbar slot. An open conversation makes its complete empty composer—with
  **Check your profile relays** and the same outlined symbol—the recovery link
  instead of adding a toolbar button. Both native `NavigationLink` actions push this profile's Relays
  destination, and the system Back action returns to the originating screen.
  No app-wide banner, custom warning surface, or launch alert is used. Other
  Settings destinations don't repeat the warning.
- The public relay fixtures are representative examples rather than a popularity ranking or availability report.
- All statuses and transitions remain deterministic in-memory prototype behavior, but that implementation boundary appears only in this documentation—not in product-surface copy.
- Governing Apple sources: [Lists and tables](https://developer.apple.com/design/human-interface-guidelines/lists-and-tables),
  [Form](https://developer.apple.com/documentation/swiftui/form),
  [NavigationLink](https://developer.apple.com/documentation/swiftui/navigationlink),
  [Toggle](https://developer.apple.com/documentation/swiftui/toggle),
  [Alerts](https://developer.apple.com/design/human-interface-guidelines/alerts),
  [Feedback](https://developer.apple.com/design/human-interface-guidelines/feedback),
  [systemOrange](https://developer.apple.com/documentation/uikit/uicolor/systemorange),
  [systemRed](https://developer.apple.com/documentation/uikit/uicolor/systemred),
  [Standard colors](https://developer.apple.com/documentation/uikit/standard-colors),
  [Buttons](https://developer.apple.com/design/human-interface-guidelines/buttons),
  [Toolbars](https://developer.apple.com/documentation/swiftui/toolbars),
  and [SF Symbols](https://developer.apple.com/sf-symbols/).

Optional relay-operator references verified July 27, 2026. They preserve the
fixture research context only; the local relay behavior above is authoritative
and does not require these sites during normal work.

- [Primal network settings](https://primal.net/settings/network)
- [Nostr.Band relay](https://relay.nostr.band/)
- [Vertex relay documentation](https://vertexlab.io/docs/services/nostr-relay/)

### Chat with support

- A native Form card presents the local White Noise Support identity with a
  question-mark speech-bubble avatar and the summary **Questions, problems,
  and suggestions**.
- Supporting copy says **Ask how something works, report a problem, or share a
  suggestion.**
- The centered full-width **Start Chat** action uses the same `plus.bubble`
  symbol as New Message. The button removes only the Form row's content inset
  so its system-rendered prominent surface spans the complete section width;
  the native `Label` centers the symbol and title together as one action. It
  creates the profile's single deterministic support conversation or returns
  to the existing one without creating a duplicate.
- Starting a new support conversation requires an available Chat Messages
  relay. An existing support conversation remains available because it retains
  its own routing.
- The conversation is also listed directly below Fiatjaf in Chats and follows
  the behavior in `conversation-support.md`.
- Governing Apple sources: [Form](https://developer.apple.com/documentation/swiftui/form),
  [Button](https://developer.apple.com/documentation/swiftui/button),
  [NavigationLink](https://developer.apple.com/documentation/swiftui/navigationlink),
  and [SF Symbols](https://developer.apple.com/sf-symbols/).

### Donate

- Lightning and Bitcoin donation methods.
- Locally generated QR codes, exact public-address Copy actions, and copied feedback.
- No wallet, payment, or network integration.

### Developer Tools

- Runtime, local signing state, profile identifier, fictional local hex key, and MarmotKit status.
- Developer Mode and Streaming Debug controls.
- Anonymous Telemetry.
- Audit Logging, local audit-file details, and destructive Delete All Audit
  Logs confirmation.
- Key Packages list with fictional publish/delete behavior.
- Diagnostics with relay health, runtime facts, deterministic self-check progress, and recent events.

### Sign Out

- **Sign Out** is reversible and preserves the in-memory profile for switching.
- **Sign Out and Remove Data** is destructive and requires a separate named confirmation.
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

## Optional historical product citations

The local decisions and acceptance criteria above are authoritative and
complete. These GitHub links preserve historical context only; agents do not
need to open them to implement or evaluate Settings.

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
- [Buttons](https://developer.apple.com/design/human-interface-guidelines/buttons)
- [Text fields](https://developer.apple.com/design/human-interface-guidelines/text-fields)
- [Toolbars](https://developer.apple.com/documentation/swiftui/toolbars)
- [primaryAction](https://developer.apple.com/documentation/swiftui/toolbaritemplacement/primaryaction)
- [navigationBarBackButtonHidden](https://developer.apple.com/documentation/swiftui/view/navigationbarbackbuttonhidden(_:))
- [Menus](https://developer.apple.com/design/human-interface-guidelines/menus)
- [NavigationLink](https://developer.apple.com/documentation/swiftui/navigationlink)
- [Picker](https://developer.apple.com/documentation/swiftui/picker)
- [Toggle](https://developer.apple.com/documentation/swiftui/toggle)
- [PhotosPicker](https://developer.apple.com/documentation/photosui/photospicker)
- [Bringing Photos picker to your SwiftUI app](https://developer.apple.com/documentation/photokit/bringing-photos-picker-to-your-swiftui-app)
- [fileImporter](https://developer.apple.com/documentation/swiftui/view/fileimporter(ispresented:allowedcontenttypes:allowmultipleselection:oncompletion:))
- [fileExporter](https://developer.apple.com/documentation/swiftui/view/fileexporter(ispresented:document:contenttype:defaultfilename:oncompletion:))
- [FileDocument](https://developer.apple.com/documentation/swiftui/filedocument)
- [File management](https://developer.apple.com/design/human-interface-guidelines/file-management)
- [ShareLink](https://developer.apple.com/documentation/swiftui/sharelink)
- [Feedback](https://developer.apple.com/design/human-interface-guidelines/feedback)
- [SensoryFeedback](https://developer.apple.com/documentation/swiftui/sensoryfeedback)
- [User Notifications](https://developer.apple.com/documentation/usernotifications)
- [UNNotificationSettings](https://developer.apple.com/documentation/usernotifications/unnotificationsettings)
- [Asking permission to use notifications](https://developer.apple.com/documentation/usernotifications/asking-permission-to-use-notifications)
- [Open notification settings](https://developer.apple.com/documentation/uikit/uiapplication/opennotificationsettingsurlstring)
- [Pushing background updates to your app](https://developer.apple.com/documentation/usernotifications/pushing-background-updates-to-your-app)
- [Palette picker style](https://developer.apple.com/documentation/swiftui/pickerstyle/palette)
- [System-provided glass in toolbars](https://developer.apple.com/documentation/swiftui/landmarks-refining-the-system-provided-glass-effect-in-toolbars)
- [ProgressView](https://developer.apple.com/documentation/swiftui/progressview)
- [tint(_:)](https://developer.apple.com/documentation/swiftui/view/tint(_:))
- [EditButton](https://developer.apple.com/documentation/swiftui/editbutton)
- [EditMode](https://developer.apple.com/documentation/swiftui/editmode)
- [LabeledContent](https://developer.apple.com/documentation/swiftui/labeledcontent)
- [Sheets](https://developer.apple.com/design/human-interface-guidelines/sheets)
- [Alerts](https://developer.apple.com/design/human-interface-guidelines/alerts)
- [SF Symbols](https://developer.apple.com/sf-symbols/)

## Acceptance

- Every hub row opens its working destination; no development placeholder remains.
- Profile initially presents its existing avatar, Name, and About as read-only
  content. Its avatar and field cards match Sign Up in size, geometry, semantic
  fill, typography, and spacing.
- Profile shows **Edit** in the trailing toolbar. Edit reveals the matching
  photo action and editable Name/About fields, replaces Edit with a prominent
  trailing **Done**, and replaces Back with the leading **Cancel** action.
- Cancel restores the stored avatar, Name, and About even when the draft has
  changes, and exits editing without navigating away.
- Done exits edit mode even when nothing changed. For a changed valid draft it
  commits the avatar, Name, and About without dismissing Profile. It remains
  disabled only while Name is empty and never exposes a dice action or
  address/email fields.
- Profile Keys shows one public-key field and one private-key field. Public copy
  is available inline; the private key starts hidden, reveals and hides without
  being spoken by assistive technology, and can be copied independently.
- Raw export uses the `arrow.down.document` SF Symbol and requires its explicit
  destructive confirmation. Encrypted export
  requires matching nonempty passwords. Both continue to the native Files
  destination picker and never use a custom save surface.
- Share & Connect pushes from Settings with the native side transition, Back
  chevron, interactive swipe-back gesture, and adaptive grouped background.
- Its npub button shows a checkmark for two seconds, resets without a second
  success haptic, and remains usable when tapped repeatedly. Its semantic-gray
  capsule stays visually subordinate to the QR in Light and Dark appearances.
- Share mode reads in this order: profile identity and npub action, then the QR
  card and caption.
- Its QR remains scannable while the supporting sentence reads as part of the
  same grouped content.
- The QR explanation sits visibly close to the last row of QR modules, and the
  QR card remains the dominant first action below the profile identity.
- The white QR container uses matching four-point padding on every side around
  the matrix. Its centered caption remains outside with a six-point gap.
- The toolbar reads **Share / Connect**, and native Form section spacing
  separates the profile identity from the QR.
- The public key remains compact, copies in full, and keeps its final four
  characters visible.
- After the first Sign In or Sign Up, Settings contains one profile and displays **Add Profile** instead of **Switch Profile**.
- Completing Sign In or Sign Up from **Add Profile** appends or reactivates that profile, reveals the deterministic pseudonym set, makes the added profile active, and changes profile management to the multi-profile presentation.
- Profile editing, sharing, switching, adding, signing out, and removing update only deterministic in-memory state.
- Every visible settings control works or presents a deterministic outcome without exposing prototype implementation language.
- Relay configuration is independent per profile. The Relays overview stays
  limited to name, URL, and status; role assignment and removal live in Relay
  Details.
- Read-only relays cannot be assigned. Final-role Toggle changes and relay removals explain the
  lost capability, then permit the degraded state after confirmation. Relays'
  inline recovery callout tells the person to turn on at least one relay for
  every missing role and combines every missing-role consequence. Chats uses
  the New Message slot for its compact recovery link, while an open
  conversation places recovery inside its empty composer. Re-enabling every
  role restores the normal New Message and waveform actions immediately.
  Changing Chat Messages does not alter existing chats.
- Restore Default Relays removes custom endpoints, restores the complete
  per-profile default list, clears every missing role, and re-enables affected
  actions. The eight complete/degraded fixtures cover every role combination.
- Relay Details uses the native consequence-aware removal confirmation. The
  main list has no Edit mode or swipe deletion.
- Appearance, message colors, and Return-key behavior update the implemented product surfaces immediately; notification, privacy, storage, relay, and developer choices remain consistent while the process runs.
- Destructive and secret-related actions use distinct native confirmations and exact safety language.
- The complete app builds with Xcode 27 beta and contains no third-party runtime dependency or network/persistence implementation.
