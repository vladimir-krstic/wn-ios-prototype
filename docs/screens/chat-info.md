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
  a native selection menu and announces its current value. Each action uses the
  same circular system glass control. The actions are icon-only visually and
  retain explicit names for VoiceOver and Voice Control.
- One scrolling `List` replaces the rejected category tabs and pager.
  **Photos**, **Links**, and **Documents** are disclosure rows in one grouped
  container. Each pushes a focused destination derived from nondeleted chat
  attachments. Empty destinations use the native unavailable presentation;
  media opens the shared full-screen viewer and available documents use Quick
  Look.
- **Relays** and **Developer Tools** are disclosure rows in the next grouped
  container. Relays edits the chat's independent relay URLs and preserves the
  existing validation, duplicate prevention, final-relay warning, and sending
  recovery behavior. Developer Tools opens the active profile's established
  developer-tools hierarchy.
- The final group contains **Archive** or **Unarchive** and destructive
  **Leave Chat**. Leaving requires native confirmation, preserves read-only
  history, and stops new messages. Disappearing-message selection remains
  deterministic, profile-scoped, and retained with the chat for the process
  lifetime.
- Search returns to the conversation and scrolls to the selected result.
- Blocking uses native destructive confirmation, preserves history, and
  replaces the composer with an **Unblock** recovery action from User Profile.
- Direct chats never expose group metadata, members, admins, or Leave Group;
  **Leave Chat** is the direct-chat exit action.

## Native components and accessibility

Use `List`, `Section`, `NavigationLink`, `Button`, `Menu`, `Picker`, Quick Look,
`confirmationDialog`, and system media presentation. Quick actions keep native
44-point targets. Disclosure rows and pushed destinations retain the standard
navigation, motion, and accessibility behavior.

## Governing sources

- [List](https://developer.apple.com/documentation/swiftui/list)
- [NavigationLink](https://developer.apple.com/documentation/swiftui/navigationlink)
- [Menus](https://developer.apple.com/design/human-interface-guidelines/menus)
- [Confirmation dialogs](https://developer.apple.com/documentation/swiftui/view/confirmationdialog)
- [Search](https://developer.apple.com/documentation/swiftui/view-search)

## Acceptance criteria

- Every action mutates only the active profile's authoritative people/chat
  state and updates Chats/conversation immediately.
- Chat Info doesn't duplicate person-level details or relationship actions;
  Contact opens the authoritative User Profile.
- Every shared-content destination derives from the authoritative chat
  timeline and updates when chat content changes.
- Chat Info contains no custom category selector or horizontal pager.
- Blocking and unblocking never lose the chat, history, or draft.
