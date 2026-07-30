# Official Apple references

Last verified: 2026-07-30.

Agents must use official Apple sources for platform claims. Add feature-specific references only when the selected screen needs them.

## Design

- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/) — interaction, hierarchy, navigation, feedback, privacy, and platform conventions.
- [Apple Design Resources](https://developer.apple.com/design/resources/) — current iOS UI kits, templates, fonts, symbols, and icon resources.
- [Accessibility HIG](https://developer.apple.com/design/human-interface-guidelines/accessibility) — inclusive visual, motor, hearing, and cognitive design.
- [SF Symbols](https://developer.apple.com/sf-symbols/) — system icon selection, rendering, localization, and effects.
- [Writing for interfaces](https://developer.apple.com/videos/play/wwdc2022/10037/) — clear and useful interface language.

## SwiftUI and iOS 27

- [Xcode 27 release notes](https://developer.apple.com/documentation/xcode-release-notes/xcode-27-release-notes) — toolchain, SDK, compiler, and beta changes.
- [SwiftUI documentation](https://developer.apple.com/documentation/swiftui/) — primary implementation reference.
- [SwiftUI updates](https://developer.apple.com/documentation/updates/swiftui) — current framework changes.
- [WWDC26 SwiftUI guide](https://developer.apple.com/wwdc26/guides/swiftui/) — current sessions and documentation.
- [What’s new in SwiftUI](https://developer.apple.com/videos/play/wwdc2026/269/) — current SwiftUI capabilities and visual-system changes.
- [Adopting Liquid Glass](https://developer.apple.com/documentation/TechnologyOverviews/adopting-liquid-glass) — system-first adoption guidance.
- [NavigationStack](https://developer.apple.com/documentation/swiftui/navigationstack) — native stack navigation.
- [NavigationLink](https://developer.apple.com/documentation/swiftui/navigationlink) — native value-driven destination navigation.
- [Form](https://developer.apple.com/documentation/swiftui/form) — native grouped settings and data-entry container.
- [Settings HIG](https://developer.apple.com/design/human-interface-guidelines/settings) — settings hierarchy, system preference respect, and app-specific configuration guidance.
- [ShareLink](https://developer.apple.com/documentation/swiftui/sharelink) — native system sharing from Share & Connect.
- [Sheets HIG](https://developer.apple.com/design/human-interface-guidelines/sheets) — scoped modal tasks and resizable iPhone sheet behavior.
- [Segmented controls HIG](https://developer.apple.com/design/human-interface-guidelines/segmented-controls) — compact switching between closely related, mutually exclusive views.
- [Palette picker style](https://developer.apple.com/documentation/swiftui/pickerstyle/palette) — native mutually exclusive palette selection used by the Share/Scan toolbar control.
- [Refining the system-provided glass effect in toolbars](https://developer.apple.com/documentation/swiftui/landmarks-refining-the-system-provided-glass-effect-in-toolbars) — toolbar placement and grouping let the system provide Liquid Glass structure and interaction.
- [Activity views HIG](https://developer.apple.com/design/human-interface-guidelines/activity-views) — system presentation of sharing and related activities.
- [Feedback HIG](https://developer.apple.com/design/human-interface-guidelines/feedback) — accessible, proportional confirmation close to the action it describes.
- [SensoryFeedback](https://developer.apple.com/documentation/swiftui/sensoryfeedback) — system success feedback for the public-key Copy action.
- [presentationDetents](https://developer.apple.com/documentation/swiftui/view/presentationdetents(_:)) — native medium and large sheet heights.
- [PresentationContentInteraction](https://developer.apple.com/documentation/swiftui/presentationcontentinteraction) — native control over whether sheet gestures prioritize scrolling or resizing.
- [Presentation modifiers](https://developer.apple.com/documentation/swiftui/view-presentation) — sheet backgrounds, sizing, detents, and interaction configuration.
- [safeAreaBar](https://developer.apple.com/documentation/swiftui/view/safeareabar(edge:alignment:spacing:content:)) — places a stationary action beside scrollable content and extends the system scroll-edge effect to match.
- [ScrollEdgeEffectStyle](https://developer.apple.com/documentation/swiftui/scrolledgeeffectstyle) — native hard, soft, or automatic transitions between scrolling content and stationary controls.
- [systemGray5](https://developer.apple.com/documentation/uikit/uicolor/systemgray5) — opaque adaptive gray for the profile-stack overflow indicator.
- [GlassButtonStyle](https://developer.apple.com/documentation/swiftui/glassbuttonstyle) — native secondary Liquid Glass button presentation and interaction.
- [GlassProminentButtonStyle](https://developer.apple.com/documentation/swiftui/glassprominentbuttonstyle) — native prominent Liquid Glass action presentation and interaction.
- [Button](https://developer.apple.com/documentation/swiftui/button) — native activation, feedback, accessibility, and keyboard behavior.
- [ButtonBorderShape](https://developer.apple.com/documentation/swiftui/buttonbordershape) — system-owned capsule and rounded button geometry.
- [PlainButtonStyle](https://developer.apple.com/documentation/swiftui/plainbuttonstyle) — borderless native button interaction used by the subdued public-key Copy action.
- [secondarySystemFill](https://developer.apple.com/documentation/uikit/uicolor/secondarysystemfill) — adaptive semantic fill for the subdued public-key Copy capsule.
- [Core Image QR code generator](https://developer.apple.com/documentation/coreimage/cifilter/qrcodegenerator()) — deterministic local QR image generation.
- [DataScannerViewController](https://developer.apple.com/documentation/visionkit/datascannerviewcontroller) — native live camera scanning for QR codes.
- [Scanning data with the camera](https://developer.apple.com/documentation/visionkit/scanning-data-with-the-camera) — VisionKit guidance, highlighting, availability, and recognized-item handling.
- [Camera authorization](https://developer.apple.com/documentation/avfoundation/requesting-authorization-to-capture-and-save-media) — system camera permission state and request behavior.
- [Open Settings](https://developer.apple.com/documentation/uikit/uiapplication/opensettingsurlstring) — recovery after a person denies camera access.
- [Privacy HIG](https://developer.apple.com/design/human-interface-guidelines/privacy) — contextual permission requests and recovery language.
- [ContentUnavailableView](https://developer.apple.com/documentation/swiftui/contentunavailableview) — native empty, unavailable, and no-results presentation.
- [Refining Liquid Glass in toolbars](https://developer.apple.com/documentation/swiftui/landmarks-refining-the-system-provided-glass-effect-in-toolbars) — native toolbar grouping and system-provided Liquid Glass.
- [What’s new in SwiftUI](https://developer.apple.com/videos/play/wwdc2025/256/) — system toolbar grouping, separation, and prominent tinted toolbar controls.
- [ToolbarSpacer](https://developer.apple.com/documentation/swiftui/toolbarspacer) — logical separation between toolbar groups.
- [sharedBackgroundVisibility](https://developer.apple.com/documentation/swiftui/toolbarcontent/sharedbackgroundvisibility(_:)) — suppressing an individual toolbar item’s automatic shared Liquid Glass background.
- [Search modifiers](https://developer.apple.com/documentation/swiftui/view-search) — native search presentation and programmatic activation.
- [Menus and commands](https://developer.apple.com/documentation/swiftui/menus-and-commands) — native compact command and selection menus.
- [Populating SwiftUI menus with adaptive controls](https://developer.apple.com/documentation/SwiftUI/Populating-SwiftUI-menus-with-adaptive-controls) — native menu labels, symbols, selection state, and destructive roles.
- [Lists and tables HIG](https://developer.apple.com/design/human-interface-guidelines/lists-and-tables) — native list hierarchy, row content, disclosure, and interaction guidance.
- [List](https://developer.apple.com/documentation/swiftui/list) — native single-column row presentation, scrolling, separators, and selection behavior.
- [Displaying data in lists](https://developer.apple.com/documentation/swiftui/displaying-data-in-lists) — SwiftUI list composition and hierarchical navigation patterns.
- [EditButton](https://developer.apple.com/documentation/swiftui/editbutton) — native list editing control that enters and exits the environment edit mode.
- [EditMode](https://developer.apple.com/documentation/swiftui/editmode) — environment state for native list deletion and editing behavior.
- [LabeledContent](https://developer.apple.com/documentation/swiftui/labeledcontent) — native alignment for descriptive labels and trailing values or statuses.
- [ControlSize](https://developer.apple.com/documentation/swiftui/controlsize) — semantic control sizing; regular is the default and small is reserved for space-constrained controls.
- [Picker](https://developer.apple.com/documentation/swiftui/picker) — native single-choice settings and selection presentation.
- [Toggle](https://developer.apple.com/documentation/swiftui/toggle) — native binary preference controls and accessibility behavior.
- [TextField](https://developer.apple.com/documentation/swiftui/textfield) — native editable text entry.
- [SecureField](https://developer.apple.com/documentation/swiftui/securefield) — native obscured text entry for backup-password prototypes.
- [PhotosPicker](https://developer.apple.com/documentation/photosui/photospicker) — privacy-preserving system photo selection.
- [UIGraphicsImageRenderer](https://developer.apple.com/documentation/uikit/uigraphicsimagerenderer) — bounded local preparation of a selected profile image before it is held in memory.
- [fileImporter](https://developer.apple.com/documentation/swiftui/view/fileimporter(ispresented:allowedcontenttypes:allowmultipleselection:oncompletion:)) — system file selection in the conversation composer.
- [ProgressView](https://developer.apple.com/documentation/swiftui/progressview) — determinate and indeterminate progress feedback.
- [Alerts HIG](https://developer.apple.com/design/human-interface-guidelines/alerts) — concise warnings, confirmations, and destructive consequences.
- [confirmationDialog](https://developer.apple.com/documentation/swiftui/view/confirmationdialog(_:ispresented:titlevisibility:presenting:actions:message:)) — native action-sheet confirmation behavior.

## Accessibility

- [SwiftUI accessibility fundamentals](https://developer.apple.com/documentation/swiftui/accessibility-fundamentals) — labels, values, grouping, actions, and standard-control behavior.
- [Performing accessibility audits](https://developer.apple.com/documentation/accessibility/performing-accessibility-audits-for-your-app) — automated and manual accessibility review.
- [Dynamic Type](https://developer.apple.com/documentation/swiftui/environmentvalues/dynamictypesize) — content-size behavior.
- [Reduce Motion](https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityreducemotion) — motion adaptation.
