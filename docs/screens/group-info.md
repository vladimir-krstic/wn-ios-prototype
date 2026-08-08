# Group Info and management

## Purpose and hierarchy

**Group Info** presents the photo, name, description, member count, Search,
notifications, Archive, Chat Relays, members, admin editing, adding people, and
Leave Group. Member rows push **Group Member**.

## Permissions and mutations

- Admins can edit group photo/name/description, add people, make/remove admins,
  and remove other members. Ordinary members receive the same readable info
  without admin commands.
- The active profile never removes itself through a member row. **Leave Group**
  owns self-removal.
- A group always retains an admin. The sole admin cannot leave and sees:
  **You’re the only admin in this group. Make another member an admin before you
  leave.**
- Edits and member/role changes append typed timeline events with human names
  and **You** for the active actor.
- Leaving uses native destructive confirmation, preserves readable history,
  moves the row to Left, and disables sending. Re-invitation is not modeled.

## Chat Relays

Chat Info and Group Info both push **Chat Relays**. The page says **Messages in
this chat use these relays.** It lists the chat's independent `wss://` URLs,
adds normalized nonduplicate values, and removes values after consequence-aware
confirmation. Removing the final relay is allowed after stating that sending
will stop; history remains available and adding a relay restores sending.

## Native components and accessibility

Use `Form`, `Section`, `NavigationLink`, `TextField`, `PhotosPicker`, `Button`,
native disabled states, alerts, and confirmation dialogs. Admin/Member is
visible and spoken. Destructive actions are never gesture-only.

## Governing sources

- [Forms](https://developer.apple.com/documentation/swiftui/form)
- [NavigationStack](https://developer.apple.com/documentation/swiftui/navigationstack)
- [PhotosPicker](https://developer.apple.com/documentation/photosui/photospicker)
- [Alerts](https://developer.apple.com/design/human-interface-guidelines/alerts)
- [Confirmation dialogs](https://developer.apple.com/documentation/swiftui/view/confirmationdialog)

The current White Noise app supplied bounded behavioral comparison evidence for
search, group editing, adding/removing people, role changes, archiving, leaving,
and last-admin protection. This brief is the durable local authority.

## Acceptance criteria

- Weekend Walks exposes the complete admin path. Product Circle demonstrates
  the non-admin path. Existing left/removed groups remain readable only.
- Every mutation updates members, permissions, metadata, list projection, and
  the timeline atomically.
- Chat routing remains independent from profile routing after creation.
