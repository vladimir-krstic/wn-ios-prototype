# Screen contract: Sign Up

- ScreenID: `onboarding.sign-up`
- Status: `draft`
- Audience: product
- Approvals: user pending; independent review pending

## Purpose and outcome

Let a person set up a new Profile with an optional avatar, name, and short About before entering Chats. Creation and saving are deterministic in-memory simulations; no account, key, network record, or durable photo is created.

## Entry, exit, and navigation

- Entry: **Sign Up** from Welcome, or a direct Sign Up scenario launch.
- Native navigation title: **Sign Up**.
- Native Back returns to Welcome and discards the in-memory draft after the person leaves the screen. No destructive warning is necessary because nothing has been created or persisted.
- The system PhotosPicker is presented from **Choose Avatar** or **Change Avatar** and returns to the same draft.
- Simulated success replaces onboarding with `chats.list` when that destination is approved and available.
- Partial-save recovery never creates a second Profile: **Retry** saves only remaining simulated details; **Continue** enters Chats and leaves those optional details absent.

## Native component specification

- Use a native `Form` with Profile Photo and Profile sections, plus the primary action in a bottom safe-area region where it remains reachable.
- Use a circular avatar preview. With no image, render a semantic initial monogram from the current Name or the deterministic default Profile fixture. With a selected photo, render the locally loaded image with native `Image`, aspect fill, and the same circular frame.
- Use `PhotosPicker` limited to one image. Do not request full Photos-library authorization and do not add a custom media browser.
- Keep the public-avatar consequence visible as section footer text before selection. PhotosPicker remains the system-owned selection experience.
- Use native `TextField` labeled **Name** and a labeled multiline `TextEditor` for **About (Optional)**. The label remains visible; a placeholder is never the only label.
- Use native buttons or menu actions for **Choose Avatar**, **Change Avatar**, and **Remove Avatar**. `person.crop.circle`, `photo`, and `trash` may be used when deployment-available and semantically appropriate.
- Use `FocusState` for Name/About keyboard flow and Return behavior. Use native `ProgressView` during creation.
- The circular selected-photo preview is the only approved custom composition; no native control provides the product avatar representation. It must reuse the project avatar component rather than invent a Sign Up-only size or style.

## Exact product copy

| Context | Copy |
|---|---|
| Navigation title | **Sign Up** |
| Avatar action, no image | **Choose Avatar** |
| Avatar actions, selected | **Change Avatar**, **Remove Avatar** |
| Avatar disclosure | **Your avatar is public. The photo is uploaded to a public service, and removing it from your profile may not delete the uploaded copy.** |
| Name label | **Name** |
| About label | **About (Optional)** |
| Primary action | **Sign Up** |
| Progress | **Creating Profile…** |
| Creation failure | **Couldn't create your profile. Try again.** |
| Creation recovery | **Retry**, **Back** |
| Partial-save failure | **Your profile was created, but some details couldn't be saved.** |
| Partial-save recovery | **Retry**, **Continue** |
| Photo too large | **That photo is too large. Choose a different photo.** |
| Photo unavailable | **That photo can't be used. Choose a different photo.** |

No product copy mentions uploads as a completed real network operation, fixture IDs, temporary paths, image metadata, scenario state, or implementation details. The public-avatar disclosure represents the intended product consequence while the prototype capability returns only a simulated outcome.

## Actions and deterministic states

| State | Behavior and recovery |
|---|---|
| `onboarding.sign-up.empty` | Initial monogram, empty Name and About, and enabled Sign Up. Empty Name is allowed; the success fixture receives its documented deterministic default name. |
| `onboarding.sign-up.populated` | Fixed fictional Name and About plus a bundled local selected-avatar preview. Change and Remove work without Photos access in previews/tests. |
| Live photo selection | PhotosPicker returns at most one image. Load and orient off the main actor, strip source metadata when materializing a temporary derivative, replace the previous selection atomically, and retain it only for this in-memory draft. |
| Picker cancellation | Preserve the prior avatar selection and draft without feedback; cancellation is not an error. |
| `onboarding.sign-up.photo-unavailable` | Preserve Name/About and the previous avatar, show the appropriate photo error adjacent to the avatar action, and keep selection available. No custom Photos-permission prompt or Settings route appears. |
| `onboarding.sign-up.loading` | Keep layout stable; disable editing, picker actions, repeat submission, and unsafe Back; show progress for the fixed simulated delay. |
| `onboarding.sign-up.error` | Preserve the complete draft and selected photo. Show creation failure with **Retry** and **Back**. Retry cannot duplicate a Profile. |
| `onboarding.sign-up.partial-error` | The Profile fixture exists exactly once. Preserve unsaved details, show partial-save copy, and offer **Retry** or **Continue**. |
| Success | Enter Chats once with no redundant success alert. The created Profile exists only in current process memory. |
| `onboarding.sign-up.accessibility-stress` | Long fictional Name/About, selected avatar, largest accessibility Dynamic Type, Bold Text, Increased Contrast, Reduce Motion, localization expansion, and RTL. |

Removing or replacing an avatar deletes any prior temporary derivative. Back, reset, dismissal, success, and process end delete remaining temporary media according to the capability lifecycle.

## Accessibility and adaptation

- VoiceOver order: title context, avatar preview, avatar disclosure, avatar actions, Name, About, primary or recovery actions.
- The initial preview is labeled **Profile avatar, initials [initials]**; a selected fictional photo is **Profile avatar, selected photo**. Do not announce temporary filenames or metadata.
- Avatar actions have visible names and at least 44-point practical targets. Voice Control can address every action by its visible name.
- Dynamic Type can move the bottom action into the scrolling Form; the avatar, disclosure, fields, errors, and action never overlap or clip.
- Name advances focus to About. About supports multiline editing and keyboard dismissal without losing the draft. Hardware-keyboard focus follows reading order.
- Light/Dark, Bold Text, Increased Contrast, localization expansion, and RTL use semantic system behavior. The avatar crop remains circular and the photo itself is not mirrored.
- Native PhotosPicker, navigation, progress, and form feedback own motion. No custom avatar transition or haptic is required; Reduce Motion remains effective.

## System, privacy, and lifecycle

- PhotosPicker is the only live system integration. It gives access only to the selected item; the app does not request broad Photos-library permission for this flow.
- Previews and UI tests use bundled fictional images through the simulated Photos capability and never open the system picker.
- Imported media remains in memory when possible. Any temporary derivative uses an app-scoped temporary location and is removed on replacement, removal, reset, dismissal, success, or process end.
- Strip location and source metadata from the temporary derivative. Do not log filenames, paths, image bytes, or load diagnostics into product-visible surfaces.
- Physical-device verification is mandatory for PhotosPicker presentation, cancellation, cloud-backed selection, replacement, memory behavior, and cleanup.

## Evidence disposition

### Apple authority

- `APPLE-PHOTOS-001`: [PhotosPicker](https://developer.apple.com/documentation/photosui/photospicker) provides single-image system selection and transferable loading.
- `APPLE-PHOTOS-002`: [Improve access to Photos in your app](https://developer.apple.com/videos/play/wwdc2021/10046/) supports the privacy-preserving picker instead of broad library permission.
- `APPLE-INPUT-002`: [Form](https://developer.apple.com/documentation/swiftui/form) provides native data-entry grouping.
- `APPLE-INPUT-003`: [FocusState](https://developer.apple.com/documentation/swiftui/focusstate) governs keyboard progression and recovery.
- `APPLE-A11Y-001`: [SwiftUI accessibility fundamentals](https://developer.apple.com/documentation/swiftui/accessibility-fundamentals) governs avatar labels, order, and action semantics.

### White Noise direction

- Approved `wn-ios-agile` issues #831 and #832 supply avatar consequence language, avatar actions, Name/About terminology, progress, partial-save recovery, and the no-duplicate rule. Real upload and profile publication are explicitly replaced by simulated capability results.
- [White Noise product language](../product-language.md) fixes **Sign Up**, **Profile**, **About**, progress, and failure language.

### Mobbin comparisons

- [Telegram: Uploading a profile picture](https://mobbin.com/flows/9e7e89e6-9f9f-43cc-a544-8986fad03a3c), 4 screens, uploaded 2026-06-01 at 393x852. Accept a prominent optional photo action, immediate local preview, system media selection, and keeping the primary action reachable above the keyboard. Reject first/last-name splitting, Terms copy, custom editing controls, and a required image.
- [Signal Onboarding](https://mobbin.com/flows/f3ea2f8a-16dd-4933-bb89-f2b6995a3ab2), 27 screens, uploaded 2023-05-09 at 375x812. Accept a dedicated profile-setup step, visible avatar result, and native keyboard progression. Reject the custom illustrated-avatar grid, camera route, required first/last fields, explanatory privacy marketing, and unrelated onboarding permissions.

## Acceptance criteria

1. Every cataloged Sign Up state launches deterministically and Reset restores its exact draft, media, delay, and outcome.
2. Choose, cancel, replace, remove, Sign Up, Retry, Continue, Back, keyboard focus, and reset work without duplicate Profiles or stale photo results.
3. PhotosPicker is used in live mode without broad Photos-library authorization; previews/tests use bundled fictional assets.
4. No network upload, account creation, authentication, cryptography, persistence, or real profile publication occurs.
5. Temporary media and source metadata are removed at every specified lifecycle boundary.
6. Default/empty, populated, photo-error, loading, creation-error, partial-error, Dark, large-text, localization, long-content, and RTL previews compile.
7. Unit tests cover draft mutation, empty-name defaulting, media replacement/cleanup, fixed delays, partial recovery, duplicate prevention, success route, and reset. UI tests cover form entry, keyboard, avatar actions, failures, and recovery.
8. Accessibility Inspector, VoiceOver, Voice Control, target size, contrast, Dynamic Type, keyboard, and required physical-device Photos checks pass.

## Approval gate

- User decision requested: approve or revise the Form composition, optional fields, public-avatar disclosure, PhotosPicker-only selection, exact copy, partial-save recovery, and success handoff.
- After user approval: obtain independent non-authoring contract review and disposition every finding.
- Do not register or create the screen implementation before both approvals.
