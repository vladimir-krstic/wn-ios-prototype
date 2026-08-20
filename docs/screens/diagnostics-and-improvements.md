# Diagnostics & Improvements

## Purpose and navigation

Let a person make two optional, independent Profile choices after reaching the
main Chats experience. Sign Up and Sign In stay focused on account entry. The
first successful entry to Chats for a Profile with no recorded choice presents
one compact native card sheet with both choices directly available. Privacy &
Security owns the same choices afterward so consent can be changed or withdrawn
at any time.

## Copy

- Sheet title: **Help Improve White Noise**
- Sheet introduction: **Help us make messaging without a central point of
  control more reliable. Anonymous analytics and diagnostic logs are optional
  and can be changed in Settings.**
- Sheet privacy detail: **Analytics never include messages, media, contacts,
  profile details, or keys. Diagnostic logs obscure identifiers and are
  securely sent to White Noise for troubleshooting.**
- Dismissal accessibility label: **Close**
- Settings navigation title: **Diagnostics & Improvements**
- Privacy & Security section title: **Diagnostics**
- Summary values: **Off**, **Analytics**, **Logs**, **On**
- Analytics Toggle: **Share Anonymous Analytics**
- Analytics detail: **Shares anonymous reliability, performance, and
  feature-use data to help improve White Noise. Messages, media, contacts,
  profile details, and keys are never included.**
- Logging Toggle: **Share Diagnostic Logs**
- Logging detail: **Sends sanitized technical activity to White Noise to help
  troubleshoot problems. Message content is excluded and identifiers are
  obscured.**
- Clear action: **Clear Diagnostic Logs**
- Retained logs section title: **Stored Diagnostic Logs**
- Retained logs summary label: **On This iPhone**
- Empty retained logs value: **None**
- Clear confirmation title: **Clear diagnostic logs?**
- Clear confirmation detail: **This permanently removes all recorded
  diagnostic activity from this iPhone. Your logging preference won’t
  change.**
- Clear confirmation action: **Clear Logs**

## Native components

- A native medium-height `sheet` presents over Chats with the system card
  geometry, dimming, drag indicator, and interactive dismissal.
- A native `NavigationStack` and grouped `Form` contain two independent
  `Toggle` controls with supporting section footers. The introduction appears
  as concise, primary body copy above the grouped Toggle card, on the sheet
  background rather than inside a settings row. A system bottom inset keeps it
  visually separate from the controls.
- A native leading Close toolbar button provides an obvious dismissal route;
  the sheet has no Save or Continue action because changes apply immediately.
- Privacy & Security uses a native disclosure row with the current summary
  value in a **Diagnostics** section directly before **Device Data**. Its
  destination uses native `LabeledContent` to show the aggregate
  retained log size without exposing filenames or paths, and owns a
  destructive native alert for clearing retained local logs.
- Developer Tools may inspect and explicitly export the same sanitized files
  but does not own either preference or duplicate the clear action. It shows
  **There are no logs.** instead of file rows or an export action when no
  retained file contains data.

## Important behavior

- Both choices start off for a Profile with no locally stored choice.
- Sign Up and Sign In contain no diagnostics controls and remain unaffected by
  either choice.
- After successful Sign Up, Sign In, or Add Profile, the sheet presents only
  after the account sheet has dismissed and Chats is visible.
- Toggle changes apply immediately to the active Profile. Closing or swiping
  down keeps the visible choices and marks the one-time sheet as seen. Leaving
  both off is a valid choice.
- A locally stored Profile that has already seen the sheet is not prompted
  again. A Profile with no recorded choice sees it after its next successful
  entry. Add Profile never inherits another Profile’s choices.
- Analytics and diagnostic-log sharing remain independent and Profile-scoped. Switching the
  active Profile immediately switches the effective choices.
- Turning analytics off stops collection. The prototype models only the
  preference and adds no telemetry transport, queue, identifier, backend, or
  third-party SDK.
- Turning diagnostic-log sharing off stops new recording and automatic sharing
  while retaining existing sanitized local files. Clear Diagnostic Logs clears
  every retained file’s contents without changing the sharing preference.
- When retained file records exist, Privacy & Security shows their combined
  local size, or **None** after their contents are cleared. Developer Tools
  shows only nonempty file records. It shows **There are no logs.** and omits
  Export Diagnostic Logs when every record is empty. When data exists, it may
  show and export the per-file technical inventory without a cleanup action,
  but it is not the only indication that local logs exist.
- Enabling logging creates deterministic sanitized in-memory file records for
  the selected Profile so Developer Tools can inspect the accepted state.
- In the production architecture, enabling this choice records sanitized local
  files and automatically sends them to White Noise's diagnostic service after
  relevant app activity. Developer Tools can also explicitly export a sanitized
  report to a person-chosen Files destination. This prototype models the choice
  and retained files in memory; it adds no persistence, networking, automatic
  transfer, or sensitive-data logging.
- This production behavior was confirmed through the user-requested bounded
  review of `marmot-protocol/whitenoise-ios` and its pinned MarmotKit `0.9.14`:
  the app supplies a separate Goggles credential and the runtime schedules
  audit-tracker uploads after relevant activity when logging is enabled.

## Accessibility

- Native sheet, toolbar, Form, and Toggle semantics expose the task, dismissal,
  and current values without custom traits.
- Supporting copy follows the control in reading order and remains available
  at accessibility text sizes.
- Clearing logs uses a named destructive action and a safe Cancel action; color
  is not the only indication of the consequence.

## Apple references

- [Privacy](https://developer.apple.com/design/human-interface-guidelines/privacy)
- [Sheets](https://developer.apple.com/design/human-interface-guidelines/sheets)
- [presentationDetents](https://developer.apple.com/documentation/swiftui/view/presentationdetents(_:))
- [Settings](https://developer.apple.com/design/human-interface-guidelines/settings)
- [Form](https://developer.apple.com/documentation/swiftui/form)
- [Toggle](https://developer.apple.com/documentation/swiftui/toggle)
- [Alerts](https://developer.apple.com/design/human-interface-guidelines/alerts)
- [App Review Guidelines: Privacy](https://developer.apple.com/app-store/review/guidelines/#privacy)

## Acceptance

- Sign Up, initial Sign In, and both Add Profile paths contain no diagnostics
  disclosure or controls.
- After one of those flows succeeds, Chats becomes visible before the native
  medium card sheet presents.
- The first sheet for a new or unknown Profile shows both choices off and both
  Toggles are directly reachable without another navigation step. Its
  introduction appears above the grouped controls without a surrounding
  settings-row card.
- Toggle changes take effect immediately. Close and swipe-down dismissal keep
  the current values, and the sheet does not automatically repeat for that
  Profile.
- A locally stored Profile that has already made or declined the choices keeps
  them and is not prompted again.
- Privacy & Security exposes the same choices for the active Profile and can
  show the retained local amount and clear retained logs even after logging is
  turned off.
- Disabling Developer Tools never changes analytics or logging.
- Developer Tools shows **There are no logs.** with no file rows or Export
  action when retained diagnostic data is empty. With data present, Export
  Diagnostic Logs opens the native Files destination picker.
- Every state remains deterministic and in memory; no telemetry or log data is
  transmitted.
