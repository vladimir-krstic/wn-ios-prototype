# Conversation composer states

## Purpose

Make every supported unsent-message state directly inspectable in deterministic
example chats. The composer remains the ordinary White Noise product surface;
scenario identifiers live only in the developer catalog timeline and brief.

## Navigation

- Composer examples appear as consecutive **Composer - …** rows in the
  developer chat catalog after **Direct - New Chat & Draft**.
- Opening any example uses the shared conversation destination and returns to
  Chats with the native Back action.
- Sending a draft appends the composed message, clears its text, attachments,
  reply, and link-preview suppression, and updates the chat row.

## Exact draft copy and states

- **Composer - Text:** **Here’s the updated plan.**
- **Composer - Multiline:** **I pulled together the notes:** followed by three
  short checklist lines.
- **Composer - Link:** **https://whitenoise.chat**, with its preview removed.
- **Composer - Link Preview:** **Worth a look:
  https://developer.apple.com/design/human-interface-guidelines**, with a rich
  preview.
- **Composer - Photo:** one captionless photo.
- **Composer - Photo Album:** **A few from today.** with four photos.
- **Composer - Mixed Media:** **Photos and a short clip from the walk.** with
  two photos and one video.
- **Composer - File:** **Here’s the brief.** with **Project Brief.pdf**.
- **Composer - GIF:** one captionless GIF.
- **Composer - Contact:** **Maya can help with this.** with Maya Chen’s contact.
- **Composer - Reply:** **Yes—Thursday afternoon works for me.** above the quote
  **CMP-REPLY: Would Thursday afternoon work?**
- **Composer - Mention:** **@Maya Chen can you take a look?** in a group chat.

The existing empty, focused, multiline growth, attachment-menu, recording,
voice-review, invitation, blocked, ended-membership, missing-relay, and message
selection states remain part of the shared composer flow.

## Native components and behavior

- `safeAreaBar` keeps the composer stationary and lets the transcript preserve
  the system scroll-edge transition.
- One continuous regular-glass composer surface owns every draft artifact:
  ordered attachments, rich link preview, quoted reply, editable text, and the
  trailing Send or waveform control. Supplemental content stacks above the
  field inside that surface; it never appears as a floating sibling card.
- A public TextKit 2 `UITextView`, bridged into SwiftUI, owns keyboard input,
  selection, focus, Return-key behavior, Dynamic Type, and growth up to ten
  visible lines. SwiftUI's ordinary `TextField` remains the default elsewhere,
  but it cannot style a selected range inside editable text.
- The attachment menu continues to open the public camera flow,
  `PhotosPicker`, file importer, and contact picker.
- Selected attachments appear in one horizontally scrolling, ordered,
  removable shelf. Photos, video, files, GIFs, and contacts retain recognizable
  SF Symbol or content previews; multiple photos stay separately removable.
  Complete visual-media drafts use two sizes within the same composer: a
  compact content-height shelf while the keyboard is active and a larger
  view-aligned carousel while the keyboard is closed. The closed composer uses
  approximately the vertical budget of the keyboard plus the ordinary composer,
  keeping the transition between editing and inspecting media spatially stable.
  Compact thumbnails intentionally fill-crop into edge-to-edge squares with no
  inner backing or letterboxing. Expanded pages instead adopt each media item's
  stored aspect ratio, making the photo, video thumbnail, or GIF itself the
  rounded card with no gray wrapper. In expanded mode only, the gallery sits on
  one black canvas inset six points from the 22-point composer surface; its
  16-point corner radius stays concentric with the composer. The horizontal
  pages use eight-point inter-item spacing. Each item receives its final card
  size and view-aligned target slot before scrolling begins. A middle card
  reserves 20 points on both sides: eight points for separation followed by a
  12-point adjacent-media peek. A six-point terminal inset remains at the far
  leading and trailing canvas edges. The first card reserves neighbor room only
  on its trailing side, the last only on its leading side, and a single card
  reserves neither nonexistent neighbor while retaining both terminal insets.
  The target slots encode those leading, center, and trailing resting positions
  directly, so one native slide ends at its final position without a second
  corrective animation. Removing an edge item immediately recomputes the new
  first or last card with the newly available space. Narrower aspect-fitted
  media can naturally leave more canvas visible, but no layout room is held for
  an absent neighbor. Tapping a compact photo,
  video, or GIF records that attachment
  as the selected page, dismisses the keyboard, and reveals the larger carousel
  resting on that same item; it never removes the item or opens a separate
  media experience. The expanded caption remains editable and grows to no more
  than three visible lines.
- The complete focused composer retains the vertical budget of ten body-text
  lines. When a thumbnail shelf is present, its roughly four-line height is
  subtracted from that budget, leaving the caption up to six visible lines before
  it scrolls. The shelf itself has an explicit content height so its horizontal
  `ScrollView` cannot expand into unused transcript space.
- The first eligible `https` URL in a text-only draft produces one deterministic
  compact rich-link preview. Apple’s `LPLinkView` remains the reference for
  metadata semantics, but its public API does not expose the user-approved
  horizontal arrangement. The accepted custom exception uses a native SwiftUI
  `HStack`: square artwork on the leading side, title and domain on the trailing
  side, adaptive system fill, and the shared close control. White Noise does not
  fetch metadata in this prototype. Closing the preview suppresses only that
  URL’s preview and leaves the typed URL intact.
- Sending an unsuppressed link includes the deterministic rich-preview
  attachment. Sending a suppressed link sends only its text.
- A reply quote remains directly above the input, inside the composer surface,
  and has a native close button. SwiftUI has no public quoted-reply component,
  so the accepted custom exception is a compact adaptive-gray rounded panel
  with a deliberately bounded semantic leading capsule; system text and the
  native button still own type and interaction.
- Every removable composer element uses the same circular close control: one
  `xmark`, one black-tinted interactive Liquid Glass surface, one visual size,
  one comfortable visual inset from its rounded top-trailing corner, and a
  separate 44-point hit region. Reduce Transparency retains a high-contrast
  surface. The close region alone removes content. The rest of a link, file,
  contact, quote, photo, video, or GIF never behaves as an implicit remove action.
- Complete group mentions use the same semantic gray rounded inline emphasis
  as mentions in sent message bubbles. The editable field applies UIKit's
  public `textHighlightStyle` through TextKit 2, with adaptive system fill and
  text colors rather than a fixed mention color.
- The editable text container keeps a small symmetric horizontal inset so a
  mention at either text edge retains both rounded highlight corners.
- The Send button appears for text, rich link, or any queued attachment. The
  waveform remains the empty-composer trailing action.

## Signal comparison adopted for this screen

The user requested a bounded Signal reference pass. Adopt only these durable
interaction conclusions:

- A generated link preview is optional and individually removable before send.
- A quoted reply is shown in the compose area and can be cancelled there.
- Media can be drafted with an optional caption and multiple selected items.
- Signal's large media draft establishes only the value of inspecting selected
  media at a useful size. White Noise keeps that inspection inside its existing
  composer, makes it a horizontally scrolling carousel, and preserves the
  normal text/send row rather than adopting Signal's separate editing chrome.

White Noise does not copy Signal’s visual metrics, colors, custom toolbar, or
private implementation. Apple components and the local adaptive monochrome
conversation treatment remain authoritative.

Comparison sources:

- [Signal Link Previews](https://support.signal.org/hc/en-us/articles/360022474332-Link-Previews)
- [Signal Reply to a specific message](https://support.signal.org/hc/en-us/articles/6851465208986-Reply-to-a-specific-message)
- [Signal Broadcast Media](https://support.signal.org/hc/en-us/articles/360044640011-Broadcast-Media)

## Important states

- Empty and nonempty text, single-line and multiline.
- Raw `https` URL with a preview and the same URL with preview suppressed.
- Captionless and captioned attachment drafts.
- Compact focused-media shelf and expanded keyboard-closed media carousel.
- Single photo, multiple photos, mixed photo/video, file, GIF, and contact.
- Reply quote plus text and group mention text.
- Compact reply layout at every available transcript height; its leading accent
  can never claim unbounded vertical space.
- Attachment removal, link-preview removal, reply cancellation, and send.
- Existing recording, voice review, invitation, selection, recovery, and ended
  membership replacements.

## Accessibility

- Every remove control has a content-specific label and a 44-point interaction
  frame.
- The attachment shelf announces its item count; each item retains its concise
  content label.
- The rich link preview is one read-only element whose label includes its title
  and domain; **Remove Link Preview** is a separate button.
- Reply cancellation is labeled **Cancel Reply**.
- Every visible close control keeps its 44-point hit region even though its
  translucent circular surface is visually smaller. VoiceOver names the exact
  item removed.
- Mention emphasis remains supplemental: the complete `@Name` text is still
  exposed by the native editable-text accessibility element.
- Link and attachment meaning never relies on color, and standard controls own
  focus, keyboard, and Dynamic Type behavior.

## Relevant Apple sources

- [safeAreaBar](https://developer.apple.com/documentation/swiftui/view/safeareabar(edge:alignment:spacing:content:))
- [UITextView](https://developer.apple.com/documentation/uikit/uitextview)
- [NSAttributedString.TextHighlightStyle](https://developer.apple.com/documentation/foundation/nsattributedstring/texthighlightstyle)
- [textHighlightAttributes](https://developer.apple.com/documentation/uikit/uitextview/texthighlightattributes)
- [PhotosPicker](https://developer.apple.com/documentation/photosui/photospicker)
- [ScrollView](https://developer.apple.com/documentation/swiftui/scrollview)
- [ViewAlignedScrollTargetBehavior](https://developer.apple.com/documentation/swiftui/viewalignedscrolltargetbehavior)
- [scrollPosition(id:anchor:)](https://developer.apple.com/documentation/SwiftUI/View/scrollPosition%28id%3Aanchor%3A%29)
- [aspectRatio](https://developer.apple.com/documentation/swiftui/view/aspectratio(_:contentmode:)-6j7xz)
- [Buttons](https://developer.apple.com/design/human-interface-guidelines/buttons)
- [fileImporter](https://developer.apple.com/documentation/swiftui/view/fileimporter(ispresented:allowedcontenttypes:allowmultipleselection:oncompletion:))
- [LPLinkView](https://developer.apple.com/documentation/linkpresentation/lplinkview)
- [Applying Liquid Glass to custom views](https://developer.apple.com/documentation/SwiftUI/Applying-Liquid-Glass-to-custom-views)
- [Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)

## Observable acceptance criteria

- Twelve consecutive composer example chats open with the exact drafts above.
- The two link chats prove both rich-preview and intentionally suppressed states.
- The rich-link preview keeps one square artwork preview on the leading side and
  its title and domain on the trailing side instead of stacking artwork above
  text.
- The attachment examples show the right number and type of removable items
  before sending.
- With the keyboard closed, photo, photo-album, mixed-media, and GIF drafts use
  a tall scrollable carousel inside the composer, approximately replacing the
  keyboard’s vertical footprint. A single black gallery canvas is inset six
  points inside the expanded composer with concentric corners; it is absent from
  the compact shelf. Expanded media itself supplies the rounded card at its
  stored aspect ratio, without an individual gray wrapper. A selected middle
  card is centered with equal side space; adjacent items are separated by eight
  points and peek equally on both sides. The first item uses the absent leading
  neighbor's room and aligns to the leading canvas edge; the last does the
  symmetric trailing treatment; both retain a six-point terminal canvas inset.
  A single item reserves no horizontal room for neighbor peeks and keeps that
  inset at both ends. Each slide has one native resting animation, and removing an
  edge item recomputes the new edge card at its larger size. Focusing the
  caption returns media to a content-height
  compact shelf whose thumbnails fill their square bounds edge to edge; tapping
  any compact visual-media thumbnail closes the keyboard and restores the
  carousel resting on that exact attachment.
- Focused media drafts never exceed the ordinary ten-line composer budget: the
  thumbnail shelf consumes about four lines and the caption can use up to six.
- Expanded media captions never exceed three visible lines before scrolling.
- GIF previews show a complete **GIF** stamp in compact and expanded layouts.
- Link, attachment, contact, file, GIF, and reply close controls share the same
  size, corner inset, translucent surface, press feedback, and removal-only hit
  behavior.
- Every draft artifact is visibly contained by the single composer surface;
  previews, attachment shelves, and reply quotes never float above a separate
  text capsule.
- The reply quote remains content-height and its cancel action stays aligned
  with the quote instead of expanding the bottom safe-area bar.
- **@Maya Chen** in the mention example uses the same adaptive gray rounded
  emphasis as the sent-message mention treatment while remaining editable.
- Sending preserves text, attachments, generated link preview, or reply target
  as appropriate and clears all unsent state.
- Removing one attachment leaves the others ordered and sendable.
- Removing a link preview leaves the URL and Send button intact.
- Existing attachment acquisition, voice, recovery, invitation, and selection
  behavior remains available.
- Completion still requires user acceptance after hands-on inspection.
