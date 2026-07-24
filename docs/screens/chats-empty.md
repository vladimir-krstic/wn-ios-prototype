# Chats — Empty

## Purpose and navigation

Show the main Chats destination when the current profile has no chats. The profile avatar reserves the future Settings entry point. New Message reserves the future chat-creation flow; neither destination is implemented in this batch.

## Copy

- Default navigation title: none
- Chats empty title: **No Chats**
- Chats description: **Start a new chat to send a message.**
- Unread empty title: **No Unread Chats**
- Unread description: **You’re all caught up.**
- Archived empty title: **No Archived Chats**
- Archived description: **Chats you archive will appear here.**
- Search prompt: **Search Chats**
- Search empty title: **No Results**
- Search empty description: **Check the spelling or try a different search.**
- Filter choices: **Chats**, **Unread**, **Archived**
- Actions: **Profile**, **Search Chats**, **Filter Chats**, **New Message**

## Native components

- `NavigationStack` without a visible navigation title.
- `ContentUnavailableView` with the current scope’s SF Symbol: `bubble.left.and.bubble.right`, `message.badge`, or `archivebox`.
- Native `.searchable` presentation triggered by the Search toolbar button.
- `ToolbarItemGroup` containing Filter first and Search second.
- A native `Picker` inside the menu with SF Symbols for every scope and the system checkmark on the selected scope.
- The Filter label always occupies one stable 34-point layout region. Its 36-point artwork receives a seven-point leading optical offset so the selected circle has visually even top, bottom, and leading insets. Unread and Archived place the plain `line.3.horizontal.decrease` symbol over the adaptive `AccentColor` circle.
- The Filter menu’s disclosure indicator is hidden so SwiftUI does not reserve unused trailing space beside the icon-only label.
- `ToolbarSpacer(.fixed)` to separate the grouped utilities from New Message.
- A `glassProminent` New Message button using `plus.bubble`.
- System-provided toolbar Liquid Glass, spacing, hit regions, menus, search motion, typography, and materials.
- One approved custom profile element: the 44-point **M** monogram avatar. `sharedBackgroundVisibility(.hidden)` keeps it outside Liquid Glass while matching the native controls’ row size. Its future Settings destination is out of scope.

## Important behavior

- Search mounts the native searchable presenter on demand, then activates it on the following UI update so pressing the toolbar action focuses the field and opens the keyboard.
- Populated fixtures demonstrate the Signal-style compact recency sequence: **Now**, **1m–59m**, a clock time for older messages today, **Yesterday**, weekday, then date. Labels remain fixed and deterministic rather than using the current clock.
- In populated rows, the avatar is vertically centered against the complete text block; title and timestamp share the top row; unread and failure indicators align to the top of the preview row so they track its first line even when the preview wraps.
- Group senders and **You:** use the emphasized variant of Apple’s semantic `subheadline` while the message remains Regular. The entire preview retains the same secondary color and Dynamic Type behavior.
- Attachment previews use one baseline-aligned SF Symbol plus concise text, all inheriting the same semantic `subheadline`, secondary color, and Dynamic Type behavior. The deterministic active list covers Photo, multiple Photos, Video, Voice message, File, Location, Contact, Link, GIF, and Sticker. No icon receives a custom frame or point size.
- Chats, Unread, and Archived update the empty-state copy.
- Each scope’s empty state uses the same SF Symbol as its filter-menu choice.
- Filter and Search remain inside one shared Liquid Glass capsule in every scope, with no capsule resizing between states. Filtered scope is communicated by the selected Filter artwork, the menu checkmark, and the empty-state copy rather than a navigation title.
- Filter menu icons are `bubble.left.and.bubble.right` for Chats, `message.badge` for Unread, and `archivebox` for Archived.
- A nonempty search query shows the search-specific empty state.
- The profile avatar is intentionally noninteractive until Settings is built. New Message exposes a callback whose destination is deferred.
- The toolbar contains one utility glass group and one visually separated prominent action.

## Accessibility

- Every icon-only toolbar action has a concise accessibility label.
- The Filter menu exposes the selected scope as its accessibility value.
- `ContentUnavailableView`, `Menu`, `Picker`, toolbar buttons, and search retain their native semantics and Dynamic Type behavior.
- The Filter’s custom artwork remains inside the native Menu’s system-owned 44-point interaction target.

## Apple references

- [ContentUnavailableView](https://developer.apple.com/documentation/swiftui/contentunavailableview)
- [Refining Liquid Glass in toolbars](https://developer.apple.com/documentation/swiftui/landmarks-refining-the-system-provided-glass-effect-in-toolbars)
- [ToolbarSpacer](https://developer.apple.com/documentation/swiftui/toolbarspacer)
- [sharedBackgroundVisibility](https://developer.apple.com/documentation/swiftui/toolbarcontent/sharedbackgroundvisibility(_:))
- [Search modifiers](https://developer.apple.com/documentation/swiftui/view-search)
- [Adding a search interface](https://developer.apple.com/documentation/swiftui/adding-a-search-interface-to-your-app)
- [Menus and commands](https://developer.apple.com/documentation/swiftui/menus-and-commands)
- [SF Symbols](https://developer.apple.com/sf-symbols/)
- [Typography](https://developer.apple.com/design/human-interface-guidelines/typography)
- [Send and reply to messages on iPhone](https://support.apple.com/en-ca/guide/iphone/-iph82fb73ba3/ios)
- [About iMessage](https://support.apple.com/guide/iphone/about-imessage-iph4e9799206/ios)
- [Use iMessage apps in Messages on iPhone](https://support.apple.com/guide/iphone/use-imessage-apps-iphf9c9c01d3/ios)

## Comparative reference

- [Signal iOS `DateUtil`](https://github.com/signalapp/Signal-iOS/blob/main/SignalServiceKit/Util/DateUtil.swift) — comparative evidence for compact chat-list recency labels and their transition points.
- [Signal iOS `ChatListCell`](https://github.com/signalapp/Signal-iOS/blob/main/Signal/src/ViewControllers/HomeView/Chat%20List/ChatListCell.swift) — comparative evidence that the conversation-list timestamp refreshes dynamically while recent.

## Acceptance

- The empty state is centered and entirely system laid out.
- Search and Filter appear in one system Liquid Glass group with visually consistent leading, inter-item, and trailing insets.
- The active Filter circle nearly fills its control region and never separates into its own toolbar item.
- New Message is a separate prominent glass action at the trailing edge.
- The profile avatar appears independently at the leading edge, without Liquid Glass, and matches the controls’ 44-point row size.
- The top row remains title-free in every scope.
- Search presents and focuses the native field, opens the keyboard, and filters the current scope; Filter shows icons and a checked native menu choice.
- No custom toolbar capsule, glass material, empty-state layout, menu, search field, or motion is implemented.
- The stable 34-point label region, 36-point selected artwork, and optical leading offset are the approved custom exception required to reproduce the grouped selected-control treatment.
