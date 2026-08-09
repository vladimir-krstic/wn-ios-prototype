# Person profile

## Purpose

Present another person's identity consistently with the active profile and make
the common relationship and conversation actions clear.

## Navigation and copy

- A person profile is pushed from New Chat, member lists, and other chat entry
  points. Its navigation title is the person's name.
- The identity header is the same shared presentation used on **Share &
  Connect**: a circular avatar occupying one third of the available width, the
  person's name beneath it, and a compact copyable `npub` capsule.
- Copying the public key replaces the copy symbol with a checkmark briefly,
  produces native success feedback, and announces the result to VoiceOver.
- The person's bio follows their name and precedes the public-key capsule
  inside the identity header, using secondary text. A small approved optical
  correction below the bio balances its font metrics against the capsule so
  the two visible gaps read evenly.
  It has no heading or grouped container. Address rows are omitted because the
  public profile's primary identifier is already available in the header.
- A compact **Groups in Common** navigation row appears beneath the identity
  header. It uses the approved overlapping-avatar stack: up to three 32-point
  group avatars and a `+N` circle for overflow. With no shared groups, a neutral
  two-person symbol occupies the stack position. The row remains available in
  every state so the related add action is never hidden. It shares the same
  grouped action container as the contact and block rows. Monogram and fallback
  avatars use an opaque adaptive gray surface so overlapping imagery never
  shows through them.
- The row pushes **Groups in Common**. That page shows every shared group using
  group avatar, headline name, and secondary member count. Group rows contain
  no message preview, timestamp, unread state, mute, delivery, membership, or
  other status treatment. Tapping a row explicitly opens that conversation.
- **Add to Another Group** moves from the main profile actions into the Groups
  in Common page as the final row in the same grouped container as the shared
  groups. It is secondary relationship management, not a prominent primary
  action. With no shared groups, **No groups in common.** precedes the action in
  that container. It uses the native system-image Button initializer with the
  established `person.2.badge.plus` relationship symbol, allowing SwiftUI's
  `Label` to own its text-matched scale, spacing, baseline, and list inset. It
  has no disclosure chevron because it starts the scoped add-to-group sheet
  rather than navigating deeper in the current hierarchy. The resulting
  selection sheet uses the same explicit title.
- Deterministic fixture coverage keeps Radia Perlman in three shared groups,
  David Chaum in one, and Maya Chen in enough groups to exercise the `+N`
  overflow state.
- **Add Contact** and **Remove Contact** toggle immediately in place. This
  reversible relationship action does not present a confirmation dialog.
- **Add to Another Group** opens the existing grouped-list sheet. Each available group
  uses the chat-list row hierarchy: group avatar, headline name, and secondary
  member count. It deliberately omits last-message content, timestamps, unread
  state, delivery state, mute state, and other chat-list status indicators.
  Selecting a group presents one standard alert: **Add [person] to [group]?**,
  **They’ll be added as a member of this group.**, **Cancel**, and **Add**.
  Confirming adds the member, provides native success feedback and a VoiceOver
  announcement, dismisses the sheet, and returns to the screen that presented
  it. It does not open the conversation automatically.
- **Block** sits in the same secondary-action group as Groups in Common and the
  contact action. Its person-removal symbol and label are both destructive red. A
  standard alert confirms blocking. After blocking, the same row becomes the
  neutral **Unblock** action and unblocks immediately.
- **Message** follows the secondary actions as the final full-width prominent
  primary action. It uses the same `plus.bubble` symbol as other chat-starting
  actions. When required profile Chat Messages relays are unavailable, the
  existing relay-recovery destination replaces it.

## Native components

`NavigationStack`, `List`, `Section`, `Button`, `NavigationLink`, the prominent
glass button style, system typography, semantic colors, SF Symbols, a native
alert, clipboard feedback, and accessibility announcements own the presentation
and behavior.

The profile identity header is a single shared SwiftUI component used by both
the active profile and person profiles. The app does not maintain visually
similar duplicate implementations.

## States and accessibility

- The contact label and symbol always describe the next action.
- The primary action remains a minimum system-sized, full-width target and uses
  adaptive foreground/background colors in light and dark appearances.
- Avatar, name, public-key copy action, bio, and actions remain separate,
  understandable VoiceOver elements.
- Blocking never removes history. Relay recovery remains available when a new
  direct chat cannot yet be created.

## Governing sources

- [Form](https://developer.apple.com/documentation/swiftui/form)
- [Lists and tables](https://developer.apple.com/design/human-interface-guidelines/lists-and-tables)
- [Sheets](https://developer.apple.com/design/human-interface-guidelines/sheets)
- [Buttons](https://developer.apple.com/design/human-interface-guidelines/buttons)
- [GlassProminentButtonStyle](https://developer.apple.com/documentation/swiftui/glassprominentbuttonstyle)
- [Alerts](https://developer.apple.com/documentation/swiftui/view/alert(_:ispresented:actions:message:))
- [Sensory feedback](https://developer.apple.com/documentation/swiftui/view/sensoryfeedback(_:trigger:))

## Acceptance criteria

- The active profile and person profile use identical avatar sizing, name
  typography, npub capsule, truncation, copy transition, feedback, and spacing.
- A person's bio appears between their name and npub without a heading or
  grouped background.
- The profile represents shared groups with one compact avatar-stack row in all
  states; the complete list and secondary Add to Another Group action live on
  its destination page.
- Message is the final, visually dominant primary action and uses the shared
  new-chat symbol.
- Add/Remove Contact changes state without a modal.
- Contact and Block share one secondary-action container; Block remains visibly
  destructive, confirms in an alert, and changes to Unblock.
