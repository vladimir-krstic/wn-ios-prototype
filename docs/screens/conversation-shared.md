# Shared conversation

## Purpose

Provide one native direct/group conversation surface for every chat row while
retaining the accepted Fiatjaf and White Noise Support stories.

## Timeline

- Messages use stable identities in a `ScrollViewReader`, `ScrollView`, and
  `LazyVStack`. Incoming content is leading; outgoing content is trailing.
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
  quotes scroll to the original or show a stable unavailable state.

## Composer and media

- The shared multiline field uses **Message**. Draft text and the pending reply
  remain with their chat through navigation; queued attachments remain ordered
  in the active composer until sent or removed.
- `PhotosPicker` selects multiple images/videos. `fileImporter` selects files.
  Images are prepared once at a maximum 1024-pixel dimension; selected videos
  and files use temporary app-owned copies only.
- The attachment strip supports removal before sending. Messages may combine
  text, images, videos, and files. Media opens a paged viewer; videos use
  `VideoPlayer`, files use Quick Look where supported, and sharing uses the
  system share sheet.
- Pressing and holding the empty-composer waveform starts a timer and animated
  waveform; dragging away cancels; releasing sends the same bundled locally
  generated voice asset. The app never initializes recording or requests
  microphone permission. VoiceOver has an explicit alternative action.
- Only one audio or video item plays at once and playback stops on navigation.
- Location, contact, GIF, sticker, and deterministic link preview are polished
  showcase renderers, not composer options.
- In groups, typing `@` offers matching members; inserted mentions are styled
  and open Group Member.

## Availability

- A left/removed profile, blocked direct peer, or chat without Chat Relays keeps
  history visible but replaces the composer with the applicable recovery
  action.
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

The shipped app supplied bounded comparison evidence for image/video messages,
reply, reactions, deletion, sharing, search, mentions, and media galleries.
This brief records the adopted behaviors locally.

## Acceptance criteria

- Every chat row opens the same conversation architecture.
- Maya Chen covers the complete direct-message catalog; Weekend Walks covers
  the complete group/system-event catalog and gallery sizes one through seven.
- Sending, drafts, replies, reactions, deletion, retry, search, attachments,
  voice playback, and row previews remain coherent through navigation.
- Fiatjaf and Support preserve their accepted visible content and special
  presentation where required.
