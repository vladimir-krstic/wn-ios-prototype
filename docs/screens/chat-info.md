# Chat Info

## Purpose and navigation

The conversation title/avatar pushes **Chat Info**. A native Form presents the
person, Search, Follow/Unfollow, Add to Group, notifications, Archive/Unarchive,
Chat Relays, and Block/Unblock.

## Behavior

- The person card shows name, avatar, Public Key copy, about text, and available
  addresses.
- Follow uses `person.badge.plus`; the visible Unfollow state uses the matching
  `person.badge.minus` symbol so its icon and label express the same action.
- Search returns to the conversation and scrolls to the selected result.
- Blocking uses native destructive confirmation, preserves history, and
  replaces the composer with an **Unblock** recovery action.
- Direct chats never expose group metadata, members, admins, or Leave Group.

## Native components and accessibility

Use `Form`, `Section`, `NavigationLink`, `Button`, `Menu`, `confirmationDialog`,
and the system share/copy affordances. Relationship and blocked states have
visible text and spoken values; destructive controls name their exact result.

## Governing sources

- [Forms](https://developer.apple.com/documentation/swiftui/form)
- [NavigationLink](https://developer.apple.com/documentation/swiftui/navigationlink)
- [Confirmation dialogs](https://developer.apple.com/documentation/swiftui/view/confirmationdialog)
- [Search](https://developer.apple.com/documentation/swiftui/view-search)

## Acceptance criteria

- Every action mutates only the active profile's authoritative people/chat
  state and updates Chats/conversation immediately.
- Blocking and unblocking never lose the chat, history, or draft.
