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
- The resting field keeps one stable native interaction height and vertically
  centers its text. Typing never changes the field's width because the trailing
  44-point slot changes in place from waveform to Send. Send is inside the
  field, matching the familiar Messages composition.
- The field grows through ten visible lines, then the native vertical
  `TextField` scrolls. Its glass uses the resting corner radius at every height
  instead of becoming a tall capsule with semicircular sides.
- While the focused field gains visible lines, the timeline keeps its bottom
  anchor on every discrete line-height change so the newest content moves with
  the growing composer and keeps the same bottom spacing at each step. Manual
  timeline scrolling remains available immediately afterward.
- When the Message field gains focus and the software keyboard opens, the
  timeline returns to its true bottom even if the person had been reading older
  history. The keyboard therefore moves the newest content above the composer;
  manual timeline scrolling remains available after the focus transition.
- The attachment control and resting field share the same 44-point interaction
  and visible height. The Send circle is 32 points inside its 44-point trailing
  slot, leaving the user-approved six-point visual inset at the top, bottom, and
  trailing field edge. Voice review mirrors that geometry: its Play circle is
  32 points inside a 44-point leading slot, leaving six points at the top,
  leading, and bottom field edges.
- `PhotosPicker` selects multiple images/videos. `fileImporter` selects files.
  Images are prepared once at a maximum 1024-pixel dimension; selected videos
  and files use temporary app-owned copies only.
- **Camera** in the attachment menu opens an AVFoundation capture surface in a
  native SwiftUI sheet at the large detent. SwiftUI owns the sheet's corners,
  background, bottom attachment, transition, and interactive swipe-down
  dismissal, with the native drag indicator visible; no custom presentation
  mask or transparent sheet background is applied. The camera preview fills
  the sheet's content and safe-area background. The visible Close control
  provides an equivalent explicit exit.
  Tapping the shutter takes a photo; holding it records video until release.
  Captured media returns to the ordered attachment queue and remains in
  temporary app-owned storage. Camera or microphone denial keeps the
  conversation intact and provides system Settings recovery.
- The attachment button uses a native `UIButton` control menu with a compact
  `UIMenu`; UIKit owns its rows, spacing, shape, material, ordering, and
  dismissal. Camera is the first item. The button's native
  `UIContextMenuInteraction` lifecycle disables the composer field as soon as
  menu presentation begins and restores it only after the menu ends or the
  selected Camera, Photos and Videos, or Files destination is dismissed. A menu
  row can therefore never focus or blink the field beneath it.
- The attachment strip supports removal before sending. Messages may combine
  text, images, videos, and files. Media opens a paged viewer; videos use
  `VideoPlayer`, images use native `UIScrollView` pinch, pan, and double-tap
  zoom, files use Quick Look where supported, and sharing uses the system share
  sheet.
- Holding the empty-composer waveform for the native `LongPressGesture`
  threshold of 0.5 seconds, within its ten-point movement allowance, replaces
  the input with an animated red waveform, elapsed timer, and explicit Stop
  control. A tap alone does not start recording. Quiet or not-yet-populated
  waveform bars use a lighter red treatment while active bars use the full
  semantic red, and the waveform expands through the available field width.
  Stopping enters a review state instead of sending: Cancel discards the draft,
  Play or Pause previews it, and Send explicitly confirms it. The app never
  initializes audio recording or requests microphone permission for voice
  messages; microphone access is used only to include sound in captured video.
  VoiceOver exposes explicit start, stop, review playback, cancel, and send
  actions.
- Voice-message bubbles show a playable waveform, elapsed progress, and
  duration. The waveform is generated deterministically for bundled fixtures
  and for the in-memory recording state. Recording and bubble waveforms use
  two-point capsule bars.
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
- The active composer has no opaque `systemBackground` backing. The native soft
  bottom scroll-edge effect remains visible through the composer area, creating
  a progressive blur instead of a hard white cutoff.

## Custom exceptions

Apple does not provide a complete message-bubble, reaction, gallery, waveform,
Messages-style composer, or press-and-hold photo/video shutter. Those bounded
compositions are custom but use semantic system colors/type, 44-point
interaction targets, interruptible state-driven motion, Reduce Motion, and
complete VoiceOver actions. Standard navigation, text entry, capture sessions,
pickers, menus, sharing, playback, permissions, alerts, and keyboard layout stay
system-owned. The 32-point Send and voice-review Play circles inside 44-point
hit targets and the two-point waveform bars are explicit user-approved visual
metrics for this custom composer. Presenting the camera in a native large sheet
instead of Apple's default full-screen camera treatment is an explicit
user-approved presentation choice; the standard sheet still owns all geometry
and dismissal behavior.

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
- [Focus](https://developer.apple.com/documentation/swiftui/focus)
- [LongPressGesture](https://developer.apple.com/documentation/swiftui/longpressgesture)
- [onLongPressGesture](https://developer.apple.com/documentation/swiftui/view/onlongpressgesture(minimumduration:maximumdistance:perform:onpressingchanged:))
- [lineLimit](https://developer.apple.com/documentation/swiftui/view/linelimit(_:reservesspace:))
- [ScrollView](https://developer.apple.com/documentation/swiftui/scrollview)
- [defaultScrollAnchor](https://developer.apple.com/documentation/swiftui/view/defaultscrollanchor(_:for:))
- [onGeometryChange](https://developer.apple.com/documentation/swiftui/view/ongeometrychange(for:of:action:))
- [LazyVStack](https://developer.apple.com/documentation/swiftui/lazyvstack)
- [Context menus](https://developer.apple.com/documentation/swiftui/view/contextmenu)
- [Menu](https://developer.apple.com/documentation/swiftui/menu)
- [menuActionDismissBehavior](https://developer.apple.com/documentation/swiftui/view/menuactiondismissbehavior(_:))
- [UIButton menu](https://developer.apple.com/documentation/uikit/uibutton/menu)
- [UIContextMenuInteraction](https://developer.apple.com/documentation/uikit/uicontextmenuinteraction)
- [UIContextMenuInteractionDelegate](https://developer.apple.com/documentation/uikit/uicontextmenuinteractiondelegate)
- [ControlSize](https://developer.apple.com/documentation/swiftui/controlsize)
- [Sheets](https://developer.apple.com/design/human-interface-guidelines/sheets)
- [sheet](https://developer.apple.com/documentation/swiftui/view/sheet(ispresented:ondismiss:content:))
- [presentationDetents](https://developer.apple.com/documentation/swiftui/view/presentationdetents(_:))
- [presentationDragIndicator](https://developer.apple.com/documentation/swiftui/view/presentationdragindicator(_:))
- [PhotosPicker](https://developer.apple.com/documentation/photosui/photospicker)
- [fileImporter](https://developer.apple.com/documentation/swiftui/view/fileimporter)
- [AVCam: Building a camera app](https://developer.apple.com/documentation/avfoundation/avcam-building-a-camera-app)
- [AVCapturePhotoOutput](https://developer.apple.com/documentation/avfoundation/avcapturephotooutput)
- [AVCaptureMovieFileOutput](https://developer.apple.com/documentation/avfoundation/avcapturemoviefileoutput)
- [Camera authorization](https://developer.apple.com/documentation/avfoundation/requesting-authorization-to-capture-and-save-media)
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
- The resting and one-line typing states have identical composer width and
  height; single-line text is vertically centered; Send replaces waveform
  inside the field; multiline entry preserves the resting corner radius, grows
  to ten visible lines, then scrolls.
- Each new visible composer line keeps the timeline bottom above the field;
  the spacing to the latest content stays constant at every line-height step,
  and the person can still scroll the timeline normally afterward.
- Opening the keyboard always brings the true timeline bottom above the
  composer, including when the person had scrolled to older history first.
- The attachment control matches the resting field height. Send has a
  six-point visual inset at the top, bottom, and trailing edge. Voice-review
  Play mirrors it at the top, leading, and bottom edge.
- Timeline content transitions beneath the composer through the native soft
  progressive blur with no opaque white cutoff.
- Camera is present in the attachment menu as a genuine native sheet at the
  large detent. The system owns its corners and bottom attachment; it dismisses
  by swiping down or using Close, without a custom mask or exposed bottom strip.
  Tap captures a photo, hold captures video, and either result returns to the
  removable attachment queue.
- Camera, Photos and Videos, and Files each open from one menu selection.
- Camera is the first attachment-menu item, and selecting any item cannot also
  focus or activate the composer beneath the menu.
- Recording and voice-message bubbles both present an accessible waveform with
  two-point bars. Recording starts only after the native half-second long press;
  Stop enters review, where the draft can be played, canceled, or explicitly
  sent.
- Left and removed groups retain readable history, show the corresponding
  chronological membership event, and replace the composer with the matching
  passive current-state label.
- The chat-row preview and timestamp always derive from the latest visible
  message or typed event, including after deletion and group-management
  mutations.
- Fiatjaf and Support preserve their accepted visible content and special
  presentation where required.
