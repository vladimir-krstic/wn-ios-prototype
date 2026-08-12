# Chat Info

## Purpose and navigation

The conversation title/avatar pushes **Chat Info**. The destination owns only
conversation information and settings; person-level identity and relationship
management remain in **User Profile**.

## Behavior

- The top identity area shows the person's avatar and name without duplicating
  their bio, `npub`, addresses, contact state, shared groups, or block state.
- Four equal quick actions follow the identity as one centered group:
  **Contact**, **Mute** or **Unmute**, **Disappearing Messages**, and
  **Search**. Contact pushes the existing **User Profile**.
  Mute opens the established duration menu; it is the single notification
  control and isn't duplicated as a settings row. Disappearing Messages opens
  a native selection menu and announces its current value. The actions form a
  compact centered group and use non-glass circular secondary controls on an
  adaptive white surface, with enough separation for each circle to read
  clearly. Each circle has a concise centered caption beneath it: **Contact**,
  **Mute** or **Unmute**, **Disappearing**, and **Search**. The control retains
  the full explicit accessibility name; the visual caption is hidden from
  VoiceOver to prevent duplicate announcements. This white surface is the
  approved local exception to the system bordered style's gray accent-derived
  fill; standard `Button` and `Menu` controls continue to own interaction and
  accessibility semantics.
- One scrolling `List` replaces the rejected category tabs and pager.
  **Photos & Videos**, **Links**, and **Documents** are disclosure rows in one
  grouped container titled **Shared in Chat**. The gap above this heading
  matches the gap between the identity and quick actions. Each row pushes a
  focused destination derived from nondeleted chat attachments. Empty
  destinations use the native unavailable presentation; available documents
  use Quick Look.
- **Photos & Videos** uses a plain scrolling, edge-to-edge three-column grid
  rather than a grouped `List` row. Photos and videos occupy square cells with
  no rounded outer container corners regardless of their source aspect ratio;
  GIFs do not appear in this category. Opening a cell presents
  that selected item and permits horizontal swiping through the other photos
  and videos in the chat. The viewer does not expose page dots or a page
  counter because the collection can be large. Each grid occurrence owns a
  stable message-scoped identity even when a fixture reuses the same underlying
  attachment, so no duplicate cell is dropped or rendered blank. Videos begin
  playing when opened and keep a compact, always-visible play/pause control,
  progress indicator, and remaining duration over the media.
- The full-screen preview shows only the media plus the sender and
  locale-formatted sent date. Media sent by the active profile identifies its
  sender as **You** rather than repeating the profile name. It does not repeat
  the source message text. Back and More are native navigation-toolbar items.
  Share and Forward sit in a
  `safeAreaBar` at the matching iPhone navigation margin. SwiftUI gives bottom
  toolbars a smaller compact metric and gives styled buttons in a safe-area bar
  a different intrinsic padding, so these two controls use Apple's interactive
  `glassEffect` directly on a 44-point circular surface centered on the same
  horizontal axes as the native navigation controls on the iPhone Air.
  This is the approved exception required to match navigation control geometry
  without a nested or expanding glass container. All four controls use the same semantic
  icon-only label component and Apple's large image scale. More contains exactly **Save** and **Go
  to Message**. Save uses the system file destination picker. Go to Message
  closes the complete Chat Info navigation subtree through the conversation's
  authoritative presentation state, returns to the conversation, scrolls to
  the source message, and briefly highlights it.
- Forward presents a large native sheet with a native Search field and compact
  chat rows. It omits unsupported Stories, permits multiple chat selections,
  and retains selected chats while filtering. Close uses the modal cancellation
  placement at the leading edge. **Forward** is the trailing confirmation action
  and remains disabled until at least one chat is selected. Selected chats use
  the same uncontained, horizontally scrolling avatar-and-remove presentation as
  New Group; its stable ordered selection does not move or disappear while the
  chat list is filtered. The bottom safe-area bar contains only the optional
  **Add a message** field. Its rounded-rectangle corner radius stays constant as
  the field grows from one to four lines, producing straight sides rather than
  expanding into a large capsule. The list never installs a competing parent tap
  gesture or animates the safe-area bar into place: native row buttons own
  selection, and interactive scrolling owns keyboard dismissal. The bar uses
  the system scroll-edge treatment rather than a custom opaque footer or a
  floating action over the list. There is no separate keyboard-dismiss control.
  The search keyboard retains its native **Search** return key.
  The enabled trailing **Forward** confirmation uses the system prominent
  primary treatment; its disabled appearance remains system-owned.
  Completion appends a separate outgoing copy of the media, together
  with the optional message, to every selected chat. Conversation message
  galleries remain independently pageable when a single message itself contains
  multiple media attachments.
- **Relays** and **Developer Tools** are disclosure rows in the next grouped
  container titled **Advanced**. Relays edits the chat's independent relay URLs
  and mirrors the established Settings relay list, detail, add, remove, and
  restore-default patterns without per-role toggles. Its explanation is a
  native section footer on the grouped surface rather than a contained row:
  **These relays are used only to deliver messages in this chat.** Add Relay
  starts at the medium detent and expands to the large detent when its URL field
  receives keyboard focus. Developer Tools opens **Chat Developer Tools**, a
  read-only inspector scoped to this conversation. The profile-wide Developer
  Tools and Debug Mode switches gate its contents. When either switch is off,
  the destination uses a full-surface `ContentUnavailableView` rather than a
  grouped form card, explains why inspection is unavailable, and presents a
  system prominent button to open the established profile-wide Developer Tools
  screen. A missing chat uses the same full-surface unavailable-state pattern.
- **Chat Developer Tools** uses a native `Form` and stays intentionally brief.
  **Conversation** shows lifecycle and epoch. Groups additionally show MLS
  member count, admin count, and the active profile's role. **Event Kinds**
  opens a separate native list containing the raw Nostr event kinds required by
  this conversation. The copyable MLS and Nostr group identifiers remain
  directly visible as ordinary `LabeledContent` rows instead of being hidden
  behind a disclosure control. **Delivery & Notifications** distinguishes the
  profile's notification setting from this chat's Push registration and shows
  the Chat Relay count. Stale push tokens, missing relay hints, or zero Chat
  Relays appear only as contextual warning rows; healthy token internals are
  not listed. Protocol activity is intentionally not exposed in this iteration.
- **Diagnostics** pushes the existing profile-wide diagnostics console. When
  opened from a chat, its native trailing ellipsis menu additionally contains
  **Copy Diagnostic Summary**. The copied text contains only sanitized chat
  metadata without message content, complete tokens, keys, or unrelated chats.
  There is no transcript export. Relay editing stays exclusively in **Relays**.

The bounded comparison of the current White Noise app's Chat Raw Debug screen
on 2026-08-11 found four useful domains: group/session identity, send and stream
health, push health, and ratchet state. This prototype adopts only the parts
that help diagnose the current conversation quickly: lifecycle and epoch,
copyable group identifiers, notification, relay, and push health, and
sanitized support actions. It intentionally rejects raw send/stream logs, raw
message cards, push-token and member-leaf listings, ratchet-tree size and hash,
credential and key material, protocol-activity history, repair or event
injection, and a second relay editor. Raw required event-kind numbers remain
available only through their dedicated drill-down. Source reviewed:
[White Noise](https://github.com/marmot-protocol/whitenoise) (`master`).
- The final group contains **Archive** or **Unarchive** and destructive
  **Leave Chat** without a redundant section title. Leave Chat uses red text
  and a red symbol. Leaving uses a native alert with Cancel and a destructive
  confirmation, preserves read-only history, and stops new messages.
  Disappearing-message selection remains deterministic, profile-scoped, and
  retained with the chat for the process lifetime.
- Search returns to the conversation and scrolls to the selected result.
- Blocking uses native destructive confirmation, preserves history, and
  replaces the composer with an **Unblock** recovery action from User Profile.
- Direct chats never expose group metadata, members, admins, or Leave Group;
  **Leave Chat** is the direct-chat exit action.

## Native components and accessibility

Use `List`, `Section`, `NavigationLink`, `Button`, `Menu`, `Picker`, Quick Look,
`LazyVGrid`, `ShareLink`, `safeAreaBar`, `glassEffect`, `fileExporter`, `confirmationDialog`, and system media
presentation. Quick actions keep native 44-point targets. Disclosure rows and
pushed destinations retain the standard navigation, motion, and accessibility
behavior. Chat Developer Tools uses `Form`, `LabeledContent`,
`NavigationLink`, `Menu`, and monospaced semantic detail without inventing a
diagnostic dashboard. Media-grid accessibility values include the item
position and total.

## Governing sources

- [List](https://developer.apple.com/documentation/swiftui/list)
- [NavigationLink](https://developer.apple.com/documentation/swiftui/navigationlink)
- [ContentUnavailableView](https://developer.apple.com/documentation/swiftui/contentunavailableview)
- [Menus](https://developer.apple.com/design/human-interface-guidelines/menus)
- [ButtonStyle](https://developer.apple.com/documentation/swiftui/buttonstyle)
- [Section](https://developer.apple.com/documentation/swiftui/section)
- [listSectionSpacing](https://developer.apple.com/documentation/swiftui/view/listsectionspacing(_:))
- [presentationDetents](https://developer.apple.com/documentation/swiftui/view/presentationdetents(_:selection:))
- [Focus](https://developer.apple.com/documentation/swiftui/focus)
- [Alert](https://developer.apple.com/documentation/swiftui/view/alert(_:ispresented:actions:message:))
- [Confirmation dialogs](https://developer.apple.com/documentation/swiftui/view/confirmationdialog)
- [Search](https://developer.apple.com/documentation/swiftui/view-search)
- [LazyVGrid](https://developer.apple.com/documentation/swiftui/lazyvgrid)
- [ShareLink](https://developer.apple.com/documentation/swiftui/sharelink)
- [Form](https://developer.apple.com/documentation/swiftui/form)
- [LabeledContent](https://developer.apple.com/documentation/swiftui/labeledcontent)
- [safeAreaBar](https://developer.apple.com/documentation/swiftui/view/safeareabar(edge:alignment:spacing:content:))
- [glassEffect](https://developer.apple.com/documentation/swiftui/view/glasseffect(_:in:))
- [Icons](https://developer.apple.com/design/human-interface-guidelines/icons)

## Acceptance criteria

- Every action mutates only the active profile's authoritative people/chat
  state and updates Chats/conversation immediately.
- Chat Info doesn't duplicate person-level details or relationship actions;
  Contact opens the authoritative User Profile.
- Every shared-content destination derives from the authoritative chat
  timeline and updates when chat content changes.
- The direct-message showcase supplies multiple valid HTTPS link previews and
  PDF, DOCX, XLSX, ZIP, and TXT document examples to exercise both shared
  content destinations. Link cards use deterministic bundled Open Graph-style
  title, domain, summary, and artwork rather than fetching remote metadata.
  Document rows and message surfaces use the outline document symbol.
- Chat Info contains no custom category selector or horizontal pager.
- Photos and videos render as consistent square grid cells.
  Opening one item does not create pagination across the full chat history;
  sender, sent date, Share, Forward, Save, and Go to Message remain available.
- Share and Forward retain equal regular glass controls and no longer read
  optically larger than Back and More.
- Forward search filters eligible chats by title, multiple selections survive
  filtering, and one completion action forwards to every selected chat.
- Relay edits remain isolated to this chat; Restore Default Relays restores the
  relay set captured for this chat rather than changing profile defaults.
- Chat Developer Tools reflects current authoritative chat state, remains gated
  by the active profile's Developer Tools and Debug Mode switches, and never
  exposes complete tokens, keys, credentials, message content in its copied
  summary, or data from another profile or chat. It does not export a
  conversation transcript.
- When conversation debugging is unavailable, its icon, title, description,
  and recovery button sit directly on the grouped screen surface without a
  containing list row, disclosure chevron, or oversized white card.
- Blocking and unblocking never lose the chat, history, or draft.
