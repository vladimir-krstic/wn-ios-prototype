# Chats — Populated

## Purpose and navigation

Show a deterministic populated Chats destination after either onboarding path. The profile avatar opens Settings; New Message and conversation destinations remain reserved for later screens. Rows support native swipe actions but do not navigate until the conversation screen is built.

## Copy

- Search prompt: **Search Chats**
- Filter choices: **Chats**, **Unread**, **Archived**, **Left**
- Selected Filter labels: **Unread**, **Archived**, **Left**
- Unread bulk action: **Read All**
- Leading swipe actions: **Read**, **Unread**
- Trailing swipe actions: **Mute**, **Unmute**, **Archive**, **Unarchive**, **Leave**, **Delete**
- Mute dialog title: **Mute Notifications**
- Mute choices: **1 Hour**, **8 Hours**, **1 Day**, **1 Week**, **Always**
- Leave confirmation title: **Leave “Chat Name”?**
- Leave confirmation message: **You’ll stop receiving new messages. This chat will remain on this device as read-only history until you delete it.**
- Leave confirmation action: **Leave Chat**
- Delete confirmation title: **Delete “Chat Name” from this device?**
- Delete confirmation message: **This permanently removes the chat and its messages from this device. Signing in again won’t restore them.**
- Delete confirmation action: **Delete Chat**
- Ended-membership previews: **You left this chat.**, **You were removed from this chat.**
- Empty and no-results copy remains defined by `chats-empty.md`.
- Fixture names and messages are fictional and stable.

## Native components

- A public UIKit list built with `UICollectionLayoutListConfiguration` owns scrolling, safe-area behavior, row placement, swipe geometry, system motion, dimming, and the system background. Its visible scroll indicator and separators are hidden.
- The collection view extends beneath the stationary top toolbar while UIKit’s automatic safe-area inset keeps resting content unobscured. At the exact resting top offset the scroll-edge effect is hidden. Once content moves beneath the controls, UIKit’s native hard top scroll-edge effect becomes visible and creates the more opaque, clearly defined toolbar boundary. Returning fully to the top hides it again. The system owns its material and boundary; the app reads the native adjusted content offset and adds no custom gradient, blur, separator, animation, or fixed top padding.
- The collection view extends its system background beneath the device’s bottom safe area, matching native full-screen lists. UIKit continues to adjust scroll content so the final row remains reachable above the Home indicator; no separate bottom strip is reserved.
- `UIHostingConfiguration` hosts the existing SwiftUI conversation-row composition inside each native list cell.
- Each conversation row is composed from native `Image`, `Text`, `Circle`, and SF Symbols because SwiftUI does not provide a stock Messages conversation row.
- The approved row avatar is a 56-point circle containing either a bundled photorealistic fictional portrait or a one-letter native monogram. SwiftUI has no stock avatar control or avatar size variants; 56 points is the user-approved custom list metric.
- Titles use semantic headline typography. Previews use semantic subheadline typography and may occupy two lines.
- Every preview uses the same regular secondary style, regardless of unread state.
- Timestamps use semantic caption typography in the title row. The deterministic fixtures cover today’s time, Yesterday, weekday, and calendar-date variants in chronological order.
- Row separators and disclosure chevrons are hidden to keep the dense status list visually quiet.
- Public `UIContextualAction` and `UISwipeActionsConfiguration` own the swipe actions. Their completion handler is deliberately deferred while Mute, Leave, or Delete is presented, which keeps the row revealed beneath the system dimming treatment.
- While a row is swiped, public `UICellConfigurationState.isSwiped` applies the adaptive `secondarySystemFill` background as a capsule derived from the current cell height. Contextual actions show system SF Symbols without visible text so UIKit centers each action in the row; their action and image accessibility labels retain the command names.
- Native `UIAlertController` action sheets own the Signal-derived mute duration picker and the destructive Leave and Delete confirmations. The sheet is anchored to the originating contextual action with no popover arrow; no custom modal, pointer, dimming layer, or transition is drawn by the app.
- A native bottom-bar `Button` presents **Read All** at the leading edge only while the Unread scope contains unread chats. Outside that state, the bottom toolbar modifier is not installed at all, so Chats, Archived, and the completed Unread empty state cannot reserve an invisible toolbar strip. The system toolbar owns the button’s Liquid Glass capsule, spacing, safe-area placement, hit target, and feedback.
- The existing native search, menu, and Picker remain unchanged. Filter, Search, and New Message share one system Liquid Glass toolbar group; New Message uses the default toolbar treatment rather than a separate prominent tint.
- The navigation toolbar remains titleless. The Filter Menu is icon-only in Chats and uses the compact adaptive symbol-plus-text selected label defined in `chats-empty.md` for Unread, Archived, and Left. No separate list header or dismissible chip is introduced.
- The leading profile avatar is a native `NavigationLink` to Settings, allowing SwiftUI’s navigation stack to own both the Back button and interactive swipe-back lifecycle. Its avatar-specific button style returns the system link label without transient dimming so the approved monogram remains full contrast throughout the transition.

## Deterministic data and behavior

- The populated profile has exactly 27 conversations: 23 nonarchived and 4 archived.
- Chats contains nonarchived conversations, including retained read-only history after a person leaves or is removed. Archived conversations appear only in the separate Archived scope.
- Unread contains nonarchived conversations with an unread count or a manual unread reminder.
- Archived contains archived conversations, including one archived conversation that retains unread state without appearing in Unread.
- Left contains nonarchived retained history after the person leaves or is removed. Archiving a retained chat moves it from Left to Archived.
- Search matches title and preview within the selected scope, ignoring case and diacritics.
- Swipe mutations update the same in-memory collection used by Chats, Unread, Archived, Left, and Search, so every filtered projection stays consistent.
- **Read All** clears every nonarchived unread count and manual unread marker, including matches outside an active search query. The Unread scope then resolves to its existing **No Unread Chats** state.
- Fixture order, names, previews, timestamps, and status values never use randomness or the current clock.
- Representative rows cover ordinary, unread count, muted, draft, failed, direct-chat, group-chat, and ten distinct attachment-preview treatments.
- Mina Park is the visible recent draft example and shows **Draft: Let’s pick this up after lunch** in the regular secondary preview style.
- Empty fixtures remain available for the future empty profile and for previews.

## Swipe actions

- Leading swipe toggles Read and Unread. Read clears both numeric unread counts and a manually marked unread state. Unread creates the approved empty 22-point monochrome badge with no number.
- An active row in Chats or Unread exposes Mute/Unmute, Archive, and Leave. Leave applies to both named one-to-one chats and groups because both use White Noise membership.
- An inactive retained row in Chats or Left exposes Archive and Delete; it no longer exposes Mute, Unmute, or Leave.
- An active row in Archived exposes Unarchive and Leave. An inactive row in Archived exposes Unarchive and Delete. Archived rows never expose Mute or Unmute.
- Muting opens **Mute Notifications** with Signal’s current duration set: 1 hour, 8 hours, 1 day, 1 week, and Always. Unmute applies immediately.
- Archive and Unarchive apply immediately and move the row between the native filtered projections. Existing mute state is preserved while archived and returns if the chat is restored.
- Leaving clears unread and mute state, replaces the preview with **You left this chat.**, and shows `rectangle.portrait.and.arrow.right` beside the chat name.
- One fixed fixture starts in the removed state and shows **You were removed from this chat.** with the same ended-membership symbol.
- After membership ends, Delete replaces Leave and remains paired with Archive or Unarchive. Delete opens a destructive confirmation dialog, then removes the chat from every projection.
- Archived rows with unread content can be marked Read. Read archived rows cannot be manually marked Unread.
- `allowsFullSwipe` is enabled only for the reversible leading Read/Unread toggle. It is disabled for the multi-action trailing edge.
- Leave and Delete swipe buttons use the system red contextual-action tint without completing the swipe mutation before confirmation. Their confirmation actions use UIKit’s native destructive style.
- Mute, Leave, and Delete dialogs remain anchored to the action that opened them. The revealed swipe state stays visible under the system dimming treatment while the dialog is present; dismissing or cancelling does not require a custom reset animation.
- The revealed row retains the approved adaptive gray capsule, and icon-only contextual actions remain vertically centered against that same dynamic row height.
- The Unread bottom bar offers **Read All** without confirmation. It is fully hidden in Chats and Archived and disappears without retaining space after no unread chats remain.

## Status presentation

- Unread counts use an adaptive monochrome circle for one digit and a capsule for two digits or the capped **99+** value.
- A manually marked unread chat uses the same 22-point monochrome circle without a number.
- Muted uses `bell.slash.fill` immediately after the chat name.
- A left or removed chat uses `rectangle.portrait.and.arrow.right` in the same title-row status position.
- Drafts use a visible **Draft:** preview prefix in the same secondary preview style.
- Failed sending uses the system-red outline `exclamationmark.circle`.
- Unread and Failed share a 22-point status region. The unread badge fills that height; the 20-point outline SF Symbol is centered inside it as an optical correction because equal rendered bounds made the hollow symbol appear larger.
- Unread labels use tabular digits and a system-centered text frame. Counts greater than 99 display as **99+**.
- No Sent, mention, or sending state appears in the Chats list.

## Attachment previews

- Every attachment preview is present in the active Chats scope: Photo, multiple Photos, Video, Voice message, File, Location, Contact, Link, GIF, and Sticker.
- Each uses a baseline-aligned SF Symbol plus concise text in the same regular secondary `subheadline` style as an ordinary message preview.
- These fixtures verify list presentation only. They do not imply that the corresponding composer or sending flow is implemented.

## Avatar provenance

The list mixes 14 locally bundled Unsplash portraits with 13 native one-letter monograms. The photos represent fictional fixture identities only; they are not White Noise users. The user approved Unsplash photography for this internal prototype. The app performs no runtime fetching.

| Asset | Fixture identity | Photographer | Unsplash source |
| --- | --- | --- | --- |
| AvatarMayaChen | Maya Chen | Christina @ wocintechchat.com | [SJvDxw0azqw](https://unsplash.com/photos/SJvDxw0azqw) |
| AvatarEliasMoreno | Elias Moreno | Albert Dera | [ILip77SbmOE](https://unsplash.com/photos/ILip77SbmOE) |
| AvatarMinaPark | Mina Park | Jake Nackos | [IF9TK5Uy-KI](https://unsplash.com/photos/IF9TK5Uy-KI) |
| AvatarLeoMartins | Leo Martins | Jurica Koletić | [7YVZYZeITc8](https://unsplash.com/photos/7YVZYZeITc8) |
| AvatarNoraBennett | Nora Bennett | Good Faces | [xmSWVeGEnJw](https://unsplash.com/photos/xmSWVeGEnJw) |
| AvatarTheoGrant | Theo Grant | Joseph Gonzalez | [iFgRcqHznqg](https://unsplash.com/photos/iFgRcqHznqg) |
| AvatarAishaRahman | Aisha Rahman | Clay Elliot | [mpDV4xaFP8c](https://unsplash.com/photos/mpDV4xaFP8c) |
| AvatarLenaOrtiz | Lena Ortiz | Michael Dam | [mEZ3PoFGs_k](https://unsplash.com/photos/mEZ3PoFGs_k) |
| AvatarJonahReed | Jonah Reed | Ryan Hoffman | [Ft4p5E9HjTQ](https://unsplash.com/photos/Ft4p5E9HjTQ) |
| AvatarTessaMorgan | Tessa Morgan | Christina @ wocintechchat.com | [Zpzf7TLj_gA](https://unsplash.com/photos/Zpzf7TLj_gA) |
| AvatarMarcusBell | Marcus Bell | Alex Suprun | [ZHvM3XIOHoE](https://unsplash.com/photos/ZHvM3XIOHoE) |
| AvatarSofiaAlvarez | Sofia Alvarez | Štefan Štefančík | [QXevDflbl8A](https://unsplash.com/photos/QXevDflbl8A) |
| AvatarDanielKim | Daniel Kim | Ludovic Migneault | [EZ4TYgXPNWk](https://unsplash.com/photos/EZ4TYgXPNWk) |
| AvatarGardenClub | Garden Club member | alex starnes | [WYE2UhXsU1Y](https://unsplash.com/photos/WYE2UhXsU1Y) |

- Retrieval date: 2026-07-24
- Transformation: Unsplash CDN face crop to a 512-by-512 JPEG, then clipped into a circle at runtime
- Intended use: internal fictional prototype conversation avatars only
- License reference: [Unsplash License](https://unsplash.com/license)
- The direct-chat fixture mix is seven women and six men.

## Accessibility

- Avatar initials and decorative artwork do not produce duplicate VoiceOver output.
- Each row combines its visible identity, preview, timestamp, and statuses into one readable element.
- Status meaning is not conveyed by color alone.
- Preview text can grow to two lines without a fixed row height.

## Apple references

- [Lists and tables](https://developer.apple.com/design/human-interface-guidelines/lists-and-tables)
- [UICollectionLayoutListConfiguration](https://developer.apple.com/documentation/uikit/uicollectionlayoutlistconfiguration)
- [UIScrollView topEdgeEffect](https://developer.apple.com/documentation/uikit/uiscrollview/topedgeeffect)
- [UIScrollEdgeEffect.Style.hard](https://developer.apple.com/documentation/uikit/uiscrolledgeeffect/style-swift.class/hard)
- [UIScrollEdgeEffect isHidden](https://developer.apple.com/documentation/uikit/uiscrolledgeeffect/ishidden)
- [UIScrollViewDelegate](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate)
- [UIScrollView contentInsetAdjustmentBehavior](https://developer.apple.com/documentation/uikit/uiscrollview/contentinsetadjustmentbehavior-swift.property)
- [SwiftUI ignoresSafeArea](https://developer.apple.com/documentation/swiftui/view/ignoressafearea(_:edges:))
- [UIHostingConfiguration](https://developer.apple.com/documentation/swiftui/uihostingconfiguration)
- [UIContextualAction](https://developer.apple.com/documentation/uikit/uicontextualaction)
- [UISwipeActionsConfiguration](https://developer.apple.com/documentation/uikit/uiswipeactionsconfiguration)
- [UICellConfigurationState](https://developer.apple.com/documentation/uikit/uicellconfigurationstate)
- [UIAlertController](https://developer.apple.com/documentation/uikit/uialertcontroller)
- [Toolbars](https://developer.apple.com/documentation/swiftui/toolbars)
- [Action sheets](https://developer.apple.com/design/human-interface-guidelines/action-sheets)
- [badge(_:)](https://developer.apple.com/documentation/swiftui/view/badge(_:))
- [BadgeProminence](https://developer.apple.com/documentation/swiftui/badgeprominence)
- [SF Symbols](https://developer.apple.com/sf-symbols/)
- [Accessibility fundamentals](https://developer.apple.com/documentation/swiftui/accessibility-fundamentals)
- [About iMessage](https://support.apple.com/guide/iphone/about-imessage-iph4e9799206/ios)
- [Use iMessage apps in Messages on iPhone](https://support.apple.com/guide/iphone/use-imessage-apps-iphf9c9c01d3/ios)

## Acceptance

- The populated account displays 23 nonarchived and 4 archived conversations.
- Unread, Archived, and Left show correct deterministic subsets and identify their scope inside the Filter Menu label; Chats uses the plain icon-only Filter label.
- Unread shows a native bottom-leading **Read All** action while unread chats remain; activating it clears every active unread state and reveals **No Unread Chats** without an empty bottom-bar strip.
- Search filters the selected scope and restores the existing native no-results state when empty.
- Read/Unread, Mute/Unmute, Archive/Unarchive, Leave, and Delete all mutate the visible deterministic state and remain correct in Chats, Unread, Archived, Left, and Search.
- Mute presents all five durations; choosing one displays the mute symbol, and Unmute removes it.
- Leave and Delete require explicit confirmation and Cancel leaves the chat unchanged.
- Opening Mute, Leave, or Delete keeps the originating swipe actions revealed and dimmed behind the native dialog.
- Leading and trailing swipes retain the rounded adaptive gray row container and vertically centered system action symbols.
- A left or removed chat shows the correct system preview and ended-membership symbol, then exposes Archive/Unarchive and Delete instead of Mute or Leave.
- Rows use 56-point avatars, one-letter monograms, no separators, no chevrons, and support two-line previews while scrolling.
- At rest the top toolbar has no hard container boundary. Scrolling rows beneath it reveals Apple’s native hard glass container, and returning fully to the top removes it again.
- Returning from Settings by either the Back button or the interactive swipe gesture restores the profile avatar at full contrast without retaining a pressed or disabled state.
- The list fills the viewport through the bottom device safe area without leaving a separate white strip beneath its final visible row.
- Every message preview uses the same regular secondary text style.
- Numeric unread, mute, draft, and failed states are visibly distinct.
- Single-digit Unread and Failed appear optically equal in the shared status region.
- The visible fixtures include one-digit, two-digit, and capped **99+** unread values.
- Mute appears beside the chat name; the timestamp shares that top row.
- Fixtures demonstrate time, Yesterday, weekday, and date timestamp variants in chronological order.
- The active list contains all ten documented attachment-preview treatments.
- Both onboarding paths open the populated account.
- Empty profile previews remain directly inspectable.
- No bulk editing, account switching, refresh control, or conversation destination is introduced.
