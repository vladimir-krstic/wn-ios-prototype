# Group Info and management

## Purpose and hierarchy

**Group Info** presents the photo, name, description, member count, quick
notification and Search actions, shared-content categories, group management,
and Leave Group. Member rows push **Group Member**.

- **Mute** or **Unmute**, **Disappearing Messages**, and **Search** appear as
  one centered quick-action group directly below the group identity. They are
  icon-only visually, retain explicit accessibility names, and the
  disappearing-message menu announces its current value.
- One scrolling `List` replaces the rejected category tabs and pager.
  **Photos**, **Links**, and **Documents** appear as disclosure rows in one
  grouped container and push focused shared-content destinations.
- **Relays** and **Developer Tools** appear in the next grouped container.
  Members and permitted management actions follow. The final group contains
  **Archive** or **Unarchive** and destructive **Leave Group**.
- Media, links, documents, relays, members, and settings derive from and mutate
  the same authoritative group chat as the conversation and chat row.

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
- Edit Group uses explicit **Cancel** and **Save** actions. Cancel discards the
  working copy. **Remove Photo** appears only for a replaceable custom photo;
  a default monogram or symbol offers **Add Photo** without a false removal
  action.
- Leaving uses native destructive confirmation, preserves readable history,
  moves the row to Left, and disables sending. Re-invitation is not modeled.

## Chat Relays

Chat Info and Group Info both expose **Relays** as a disclosure destination. It says
**Messages in this chat use these relays.**, lists the chat's independent
`wss://` URLs, adds normalized nonduplicate values, and removes values after
consequence-aware confirmation. Removing the final relay is allowed after
stating that sending will stop; history remains available and adding a relay
restores sending.

## Native components and accessibility

Use `Form`, `Section`, `NavigationLink`, `TextField`, `PhotosPicker`, `Button`,
native disabled states, alerts, and confirmation dialogs. Admin/Member is
visible and spoken. Destructive actions are never gesture-only.

## Governing sources

- [Forms](https://developer.apple.com/documentation/swiftui/form)
- [NavigationStack](https://developer.apple.com/documentation/swiftui/navigationstack)
- [List](https://developer.apple.com/documentation/swiftui/list)
- [NavigationLink](https://developer.apple.com/documentation/swiftui/navigationlink)
- [Menus](https://developer.apple.com/design/human-interface-guidelines/menus)
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
