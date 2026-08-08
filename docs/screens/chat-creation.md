# Chat creation

## Purpose

Start a direct chat through a person's profile or create a named group without
leaving deterministic in-memory prototype state.

## Navigation and copy

- **New Chat** is pushed from Chats. It uses native search with **Name or
  npub**, shows **New Group** first, and then the profile's People directory.
- Choosing a person pushes their profile. **Message** opens the existing direct
  chat or creates one; duplicate direct chats are never created.
- **New Group** pushes a searchable multi-selection list. **Continue** requires
  at least one other person.
- **Set Up Group** owns the optional photo, required **Group Name**, optional
  **Description**, member review, and **Create Group**.
- A new group makes the active profile an admin, copies that profile's available
  Chat Messages relays, appends **You created the group.**, and opens the chat.

## Native components

`NavigationStack`, `NavigationLink`, `.searchable`, `List`, `Form`, `TextField`,
`PhotosPicker`, `ContentUnavailableView`, toolbar buttons, and native disabled
states own presentation and interaction.

## States and accessibility

- Search covers names and public keys; no results use the native search-empty
  presentation.
- Back or Cancel before creation makes no mutation.
- The active profile never appears as a selectable person.
- White Noise Support is a service destination, not a person. It never appears
  in New Chat, New Group, or Add People results and cannot be added to a group.
- Selection state is visible, spoken, and not color-only. Avatar-only actions
  have explicit labels.
- Without an available profile Chat Messages relay, Chats keeps the accepted
  relay-recovery toolbar action and does not enter creation.

## Governing sources

- [NavigationStack](https://developer.apple.com/documentation/swiftui/navigationstack)
- [Search](https://developer.apple.com/documentation/swiftui/view-search)
- [Lists](https://developer.apple.com/design/human-interface-guidelines/lists-and-tables)
- [PhotosPicker](https://developer.apple.com/documentation/photosui/photospicker)
- [ContentUnavailableView](https://developer.apple.com/documentation/swiftui/contentunavailableview)

The current White Noise app supplied bounded behavioral comparison evidence for
the person-profile step and two-stage group creation. This brief is the durable
local authority; implementation does not depend on that external source.

## Acceptance criteria

- Direct creation deduplicates and opens the correct chat.
- Group selection, setup, relay copying, membership, initial admin role, system
  event, list insertion, and navigation occur as one successful mutation.
- All creation state is profile-scoped and survives navigation until process
  exit.
