# Chats — Populated

## Purpose and navigation

Show a deterministic populated Chats destination after either onboarding path. The profile avatar, New Message action, and conversation destinations remain reserved for later screens. Rows remain visually static until conversation navigation is built.

## Copy

- Search prompt: **Search Chats**
- Filter choices: **Chats**, **Unread**, **Archived**
- Empty and no-results copy remains defined by `chats-empty.md`.
- Fixture names and messages are fictional and stable.

## Native components

- A plain SwiftUI `List` owns scrolling, safe-area behavior, row placement, separators, and system background. Its visible scroll indicator is hidden.
- Each conversation row is composed from native `Image`, `Text`, `Circle`, and SF Symbols because SwiftUI does not provide a stock Messages conversation row.
- The approved row avatar is a 56-point circle containing either a bundled photorealistic fictional portrait or a one-letter native monogram. SwiftUI has no stock avatar control or avatar size variants; 56 points is the user-approved custom list metric.
- Titles use semantic headline typography. Previews use semantic subheadline typography and may occupy two lines.
- Every preview uses the same regular secondary style, regardless of unread state.
- Timestamps use semantic caption typography in the title row. The deterministic fixtures cover today’s time, Yesterday, weekday, and calendar-date variants in chronological order.
- Row separators and disclosure chevrons are hidden to keep the dense status list visually quiet.
- The existing native search, menu, Picker, toolbar grouping, Liquid Glass, and prominent New Message action remain unchanged.

## Deterministic data and behavior

- The populated profile has exactly 27 conversations: 23 active and 4 archived.
- Chats contains active conversations only; Archived conversations appear only in the separate Archived scope.
- Unread contains active conversations with an unread count.
- Archived contains archived conversations, including one archived conversation that retains unread state without appearing in Unread.
- Search matches title and preview within the selected scope, ignoring case and diacritics.
- Fixture order, names, previews, timestamps, and status values never use randomness or the current clock.
- Representative rows cover ordinary, unread count, muted, draft, failed, direct-chat, group-chat, and ten distinct attachment-preview treatments.
- Empty fixtures remain available for the future empty profile and for previews.

## Status presentation

- Unread counts use an adaptive monochrome circle for one digit and a capsule for two digits or the capped **99+** value.
- Muted uses `bell.slash.fill` immediately after the chat name.
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

The list mixes 14 locally bundled Unsplash portraits with seven native one-letter monograms. The photos represent fictional fixture identities only; they are not White Noise users. The user approved Unsplash photography for this internal prototype. The app performs no runtime fetching.

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
- [List](https://developer.apple.com/documentation/swiftui/list)
- [Displaying data in lists](https://developer.apple.com/documentation/swiftui/displaying-data-in-lists)
- [badge(_:)](https://developer.apple.com/documentation/swiftui/view/badge(_:))
- [BadgeProminence](https://developer.apple.com/documentation/swiftui/badgeprominence)
- [SF Symbols](https://developer.apple.com/sf-symbols/)
- [Accessibility fundamentals](https://developer.apple.com/documentation/swiftui/accessibility-fundamentals)
- [About iMessage](https://support.apple.com/guide/iphone/about-imessage-iph4e9799206/ios)
- [Use iMessage apps in Messages on iPhone](https://support.apple.com/guide/iphone/use-imessage-apps-iphf9c9c01d3/ios)

## Acceptance

- The populated account displays 23 active and 4 archived conversations.
- Unread and Archived show correct deterministic subsets without adding scope titles.
- Search filters the selected scope and restores the existing native no-results state when empty.
- Rows use 56-point avatars, one-letter monograms, no separators, no chevrons, and support two-line previews while scrolling.
- Every message preview uses the same regular secondary text style.
- Numeric unread, mute, draft, and failed states are visibly distinct.
- Single-digit Unread and Failed appear optically equal in the shared status region.
- The visible fixtures include one-digit, two-digit, and capped **99+** unread values.
- Mute appears beside the chat name; the timestamp shares that top row.
- Fixtures demonstrate time, Yesterday, weekday, and date timestamp variants in chronological order.
- The active list contains all ten documented attachment-preview treatments.
- Both onboarding paths open the populated account.
- Empty profile previews remain directly inspectable.
- No swipe actions, bulk editing, account switching, refresh control, or conversation destination is introduced.
