# Conversation — Fiatjaf

## Purpose and navigation

Open a polished deterministic one-to-one conversation with **Fiatjaf** from the Marmota Chats list. The native navigation stack owns Back behavior. This is the first implemented conversation destination; other chat rows remain unchanged until their screens are selected.

## Copy and content

- Conversation title: **Fiatjaf**
- Day marker: **Today**
- Marmota: **I’m moving from Feather to White Noise.**
- Fiatjaf: **Let me know how it goes.**
- Marmota, two lines: **Signing in now. / I’ll send a test next.**
- Marmota: **Switched from Feather to White Noise. Same key, same contacts.**
- Fiatjaf reply to Marmota: **Yep, I still see you on Primal. No extra setup on my side.**
- Marmota: **Exactly. Moved apps, kept everything. Didn’t have to re-add anyone.**
- Reaction: **🔥**
- Fiatjaf: **Perfect!**
- Fiatjaf media caption: **Portable identity for the win.**
- Composer prompt: **Message**

The supplied Figma conversation establishes the identity, ordering, reply, reaction, media, and copy. The implementation uses White Noise’s approved adaptive monochrome treatment instead of the legacy blue outgoing bubbles.

## Native components and visual rules

- `NavigationStack` and the system Back button own navigation and interactive swipe-back.
- The title uses a compact circular Fiatjaf avatar and semantic headline typography in the principal toolbar position.
- A native `ScrollView` with `LazyVStack` owns timeline scrolling without a visible scroll indicator. Messages are bottom-aligned when the content is shorter than the viewport.
- Outgoing messages use the adaptive app accent: black with white content in Light Mode and white with black content in Dark Mode.
- Incoming messages use the adaptive semantic `secondarySystemFill`.
- SwiftUI has no stock message-bubble component. The screen uses `UnevenRoundedRectangle` with one tighter lower corner to distinguish direction without drawing a custom tail.
- The reply preview is part of the incoming bubble and uses a semantic overlay, a short vertical capsule, caption typography for the author, and secondary text for the quoted body.
- Reactions use a compact system-background capsule attached below the bubble’s inward edge: leading for outgoing messages and trailing for incoming messages. The capsule is inset symmetrically from that edge, matching the timestamp inset rather than sitting flush with the bubble.
- The five approved Figma images use native SwiftUI stacks with row widths derived from the approved bubble width, clipped rounded rectangles, and no runtime loading. Media never escapes its message bubble.
- The composer is pinned with `safeAreaInset`; the timeline uses the native soft bottom scroll-edge effect instead of a hard bar boundary. A native multiline `TextField` owns keyboard, focus, selection, and text entry inside a system Liquid Glass capsule. Its resting single line is vertically centered at the native minimum interaction height, while multiline content can grow and keep the trailing control at the lower edge. A trailing native waveform control provides the voice-message affordance inside the field; native glass buttons own attachment and send feedback.
- The timeline keeps system spacing between its final message and the stationary composer when first opened and after sending.
- Message metadata shows time only. Timestamps sit outside the bubble: beneath the inward edge of outgoing and incoming messages. Delivery checkmarks aren’t part of the White Noise conversation design.
- Sending nonempty text appends a deterministic outgoing bubble labeled **Now**, clears the composer, and keeps the new message visible.
- The attachment button presents native `PhotosPicker` and file-importer choices. A selected photo or file is appended as a deterministic in-memory outgoing message and is discarded when the process ends.

## Important states and interactions

- Resting conversation with reply, reaction, and media examples.
- Focused composer with the real system keyboard.
- Empty composer: no Send button.
- Empty composer: the trailing waveform control is visible inside the glass text-entry capsule.
- Nonempty composer: Send appears and works.
- Attachment menu opens native photo and file pickers; selected content appears in memory in the timeline.
- Back returns to Chats without resetting the in-memory list.

## Accessibility

- Each message exposes its sender, body, time, reply context, reaction, and media count as a combined readable element.
- Decorative avatars and delivery artwork are hidden from accessibility when their meaning is already present in text.
- The media collage has one concise accessibility label rather than five repeated image announcements.
- Semantic fonts support Dynamic Type. The timeline does not use fixed row heights.

## References

- [White Noise marketing conversation](https://www.figma.com/design/jzWaS92LwoBjqTtOLP6ij7/White-Noise---Web---Marketing?node-id=1273-8364)
- Read-only production evidence: `../whitenoise-ios/whitenoise-ios/Conversation/ConversationView.swift`
- Read-only production evidence: `../whitenoise-ios/whitenoise-ios/Conversation/MessageBubble.swift`
- Read-only production evidence: `../whitenoise-ios/whitenoise-ios/Conversation/ComposerBar.swift`
- [NavigationStack](https://developer.apple.com/documentation/swiftui/navigationstack)
- [Toolbars](https://developer.apple.com/documentation/swiftui/toolbars)
- [ScrollView](https://developer.apple.com/documentation/swiftui/scrollview)
- [LazyVStack](https://developer.apple.com/documentation/swiftui/lazyvstack)
- [TextField](https://developer.apple.com/documentation/swiftui/textfield)
- [safeAreaInset](https://developer.apple.com/documentation/swiftui/view/safeareainset(edge:alignment:spacing:content:))
- [Applying Liquid Glass to custom views](https://developer.apple.com/documentation/SwiftUI/Applying-Liquid-Glass-to-custom-views)
- [GlassButtonStyle](https://developer.apple.com/documentation/swiftui/glassbuttonstyle)
- [SF Symbols](https://developer.apple.com/sf-symbols/)

## Asset provenance

The Fiatjaf avatar and five animal photographs are bundled exports from the approved Figma node above.

- Source node: `1273:8364`
- Retrieval date: 2026-07-28
- Transformations: no content edits; images are decoded and clipped into native runtime shapes
- Intended use: Fiatjaf conversation row and conversation screen
- Rights assumption: artwork already used by White Noise marketing is approved for this prototype and future marketing translation

## Acceptance

- The Marmota Chats list contains Fiatjaf and tapping only that row opens this destination.
- The title, avatar, exact messages, reply, reaction, media collage, external inward-aligned timestamps, and Liquid Glass composer are visible and coherent.
- Outgoing bubbles are black in Light Mode rather than production iOS blue.
- The composer uses the real keyboard, appends a message, and keeps stable geometry.
- The screen builds with Xcode 27 beta and uses no networking, persistence, third-party runtime dependency, or production reference-repository modification.
