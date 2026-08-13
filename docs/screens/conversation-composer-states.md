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
- The first eligible `https` URL in a text-only draft produces one deterministic
  `LPLinkView`. White Noise does not fetch metadata in this prototype. The close
  button suppresses only that URL’s preview and leaves the typed URL intact.
- Sending an unsuppressed link includes the deterministic rich-preview
  attachment. Sending a suppressed link sends only its text.
- A reply quote remains directly above the input, inside the composer surface,
  and has a native close button. SwiftUI has no public quoted-reply component,
  so the accepted custom exception is a compact adaptive-gray rounded panel
  with a deliberately bounded semantic leading capsule; system text and the
  native button still own type and interaction.
- Complete group mentions use the same semantic gray rounded inline emphasis
  as mentions in sent message bubbles. The editable field applies UIKit's
  public `textHighlightStyle` through TextKit 2, with adaptive system fill and
  text colors rather than a fixed mention color.
- The Send button appears for text, rich link, or any queued attachment. The
  waveform remains the empty-composer trailing action.

## Signal comparison adopted for this screen

The user requested a bounded Signal reference pass. Adopt only these durable
interaction conclusions:

- A generated link preview is optional and individually removable before send.
- A quoted reply is shown in the compose area and can be cancelled there.
- Media can be drafted with an optional caption and multiple selected items.

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
- [fileImporter](https://developer.apple.com/documentation/swiftui/view/fileimporter(ispresented:allowedcontenttypes:allowmultipleselection:oncompletion:))
- [LPLinkView](https://developer.apple.com/documentation/linkpresentation/lplinkview)
- [Applying Liquid Glass to custom views](https://developer.apple.com/documentation/SwiftUI/Applying-Liquid-Glass-to-custom-views)
- [Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)

## Observable acceptance criteria

- Twelve consecutive composer example chats open with the exact drafts above.
- The two link chats prove both rich-preview and intentionally suppressed states.
- The attachment examples show the right number and type of removable items
  before sending.
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
