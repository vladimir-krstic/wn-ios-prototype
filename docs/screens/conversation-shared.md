# Shared conversation

## Purpose

Provide one native direct/group conversation surface for every chat row while
retaining the accepted Fiatjaf and White Noise Support stories.

## Timeline

- The principal toolbar item is the single entry point to Chat Info or Group
  Info. It uses a 44-point avatar beside the conversation title and, for a
  group, its member count. The system principal placement centers this combined
  identity control in the navigation bar. Search is not duplicated as a
  trailing conversation-toolbar action; it remains available inside the
  applicable info screen.
- Messages use stable identities in a `ScrollViewReader`, `ScrollView`, and
  `LazyVStack`. Incoming content is leading; outgoing content is trailing.
  Opening a conversation settles on the true newest timeline entry after the
  composer safe-area inset is laid out; older history remains reachable by
  scrolling to the conversation's beginning.
- Two existing chats are the durable conversation reference histories. **Maya
  Chen** is the complete one-to-one catalog and **Weekend Walks** is the
  complete group catalog. Each begins with the conversation's earliest
  activity and proceeds in strict chronological order to the current day.
  Variants form a readable conversation rather than an adjacent checklist of
  unrelated examples.
- Consecutive messages group by author. Group chats show an incoming author's
  name and avatar once per cluster. Locale-aware time appears at the cluster
  end; centered separators cover Today, Yesterday, recent dates, and older full
  dates.
- Deleted messages remain as **You deleted this message.** or **This message
  was deleted.** Failed outgoing messages expose **Retry**; sent messages do not
  show delivery checkmarks.
- Native context menus own Reply, Copy, Share, Delete, and the supported
  reactions: ❤, 😀, 👍, 👎, 🤣, 🔥, and 🦫.
- Search matches text, sender names, file names, and attachment labels. Reply
  quotes scroll to the original or show a stable unavailable state. Search
  results visibly emphasize every matching term without relying on color.
- Inline emphasis uses native attributed text. Links and mentions retain the
  approved adaptive monochrome bubble palette while adding an underline;
  mentions also use semibold type. VoiceOver reads the rendered words rather
  than Markdown punctuation.

## Composer and media

- The shared multiline field uses **Message**. Draft text and the pending reply
  remain with their chat through navigation; queued attachments remain ordered
  in the active composer until sent or removed.
- `PhotosPicker` selects multiple images/videos. `fileImporter` selects files.
  Images are prepared once at a maximum 1024-pixel dimension; selected videos
  and files use temporary app-owned copies only.
- The attachment strip supports removal before sending. Messages may combine
  text, images, videos, and files. Media opens a paged viewer; videos use
  `VideoPlayer`, images use native `UIScrollView` pinch, pan, and double-tap
  zoom, files use Quick Look where supported, and sharing uses the system share
  sheet.
- Pressing and holding the empty-composer waveform replaces the input with a
  visible elapsed timer and cancellation guidance while the waveform animates;
  dragging away cancels; releasing sends the same bundled locally generated
  voice asset. The app never initializes recording or requests microphone
  permission. VoiceOver has an explicit start/stop alternative that does not
  depend on a continuous hold.
- Only one audio or video item plays at once and playback stops on navigation.
- A voice bubble does not impose a fixed outer width. Its progress and duration
  reflow as one adaptive unit so longer localized or accessibility-sized time
  labels never collapse into a one-character column.
- Location, contact, GIF, sticker, and deterministic link preview are polished
  showcase renderers, not composer options.
- In groups, typing `@` offers matching members; inserted mentions are styled
  and open Group Member.

## Availability

- A left/removed profile, blocked direct peer, or chat without Chat Relays keeps
  history visible but replaces the composer with the applicable recovery
  action.
- Leaving or being removed from a group creates a centered, nonactionable
  timeline event at the chronological point where membership ended. The exact
  copy is **You left the group.** or, when the removing member is known,
  **Maya Chen removed you from the group.**
- A left or removed group replaces the composer with a passive native `Label`
  in a system `safeAreaBar`: **You left this group.** or **You were removed
  from this group.** The status uses a semantic SF Symbol and secondary
  styling. It is not a disabled field, alert, toast, full-screen unavailable
  state, or button; no rejoin action is available in this flow.
- The membership-status bar combines `safeAreaBar` with SwiftUI's soft bottom
  scroll-edge effect, allowing timeline content to transition beneath the
  stationary surface without the composer's hard opaque boundary or a custom
  blur implementation. The active composer keeps `safeAreaInset` for its
  keyboard-following layout.
- The composer follows keyboard safe areas. It does not install translucent
  content behind the system keyboard.

## Custom exceptions

Apple does not provide a complete message-bubble, reaction, gallery, or
press-and-hold voice-message component. Those four compositions are custom but
use semantic system colors/type, 44-point interaction targets, interruptible
state-driven motion, Reduce Motion, and complete VoiceOver actions. Standard
navigation, pickers, menus, sharing, playback, alerts, and keyboard layout stay
system-owned.

## Voice asset provenance

The shared voice sample is an original local asset created on 2026-08-08 with
the macOS Samantha text-to-speech voice reading the original phrase **Meet me
by the old bridge.** It was transcoded locally to a short 16 kHz mono MP3 and
embedded in the app. No recording or copyrighted audio was downloaded, and no
speech synthesizer or microphone API is used at runtime.

## Showcase document and video provenance

The four PDF fixtures contain original local prototype notes generated on
2026-08-08 and bundled solely to exercise Quick Look. `ChatTrailClip.mp4` is an
original eight-second local motion treatment generated from the already
documented bundled pebble artwork. The app performs no runtime download, and
every showcased file and video has usable local data rather than a decorative
dead affordance.

## Governing sources

- [TextField](https://developer.apple.com/documentation/swiftui/textfield)
- [ScrollView](https://developer.apple.com/documentation/swiftui/scrollview)
- [LazyVStack](https://developer.apple.com/documentation/swiftui/lazyvstack)
- [Context menus](https://developer.apple.com/documentation/swiftui/view/contextmenu)
- [PhotosPicker](https://developer.apple.com/documentation/photosui/photospicker)
- [fileImporter](https://developer.apple.com/documentation/swiftui/view/fileimporter)
- [VideoPlayer](https://developer.apple.com/documentation/avkit/videoplayer)
- [AVAudioPlayer](https://developer.apple.com/documentation/avfaudio/avaudioplayer)
- [Quick Look](https://developer.apple.com/documentation/swiftui/view/quicklookpreview)
- [ShareLink](https://developer.apple.com/documentation/swiftui/sharelink)
- [Label](https://developer.apple.com/documentation/swiftui/label)
- [safeAreaInset](https://developer.apple.com/documentation/swiftui/view/safeareainset(edge:alignment:spacing:content:))
- [safeAreaBar](https://developer.apple.com/documentation/swiftui/view/safeareabar(edge:alignment:spacing:content:))
- [ScrollEdgeEffectStyle](https://developer.apple.com/documentation/swiftui/scrolledgeffectstyle)

The shipped app supplied bounded comparison evidence for image/video messages,
reply, reactions, deletion, sharing, search, mentions, and media galleries.
This brief records the adopted behaviors locally.

## Acceptance criteria

- Every chat row opens the same conversation architecture.
- Maya Chen covers the complete direct-message catalog; Weekend Walks covers
  the complete group/system-event catalog and gallery sizes one through seven.
- Maya includes short, multiline, and long text in both directions; replies to
  text, photo, and video; every agreed media and reaction state; both deleted
  states; and a failed outgoing message, all in chronological narrative order.
- Weekend Walks starts with **You created the group.** and interleaves every
  agreed membership, role, name, photo, and description event with the
  messages that give it context. Its dates visibly span an older full date, a
  recent weekday, Yesterday, and Today.
- Sending, drafts, replies, reactions, deletion, retry, search, attachments,
  voice playback, and row previews remain coherent through navigation.
- Left and removed groups retain readable history, show the corresponding
  chronological membership event, and replace the composer with the matching
  passive current-state label.
- The chat-row preview and timestamp always derive from the latest visible
  message or typed event, including after deletion and group-management
  mutations.
- Fiatjaf and Support preserve their accepted visible content and special
  presentation where required.
