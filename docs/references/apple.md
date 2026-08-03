# Official Apple reference index

Last full verification: **2026-07-31**.

This is the routing index for material platform decisions. Open the relevant
live Apple source before choosing or recreating a component, interaction,
system integration, motion treatment, or accessibility behavior. Apply the
evaluation process in `docs/references/native-ui.md`, then record the governing
links and resulting decision in the selected screen brief.

All links below are official Apple sources. The user’s latest direction remains
the highest authority; document any approved exception from Apple’s default
pattern in the screen brief.

## Contents

1. [Design foundations and resources](#1-design-foundations-and-resources)
2. [Interface writing, feedback, and privacy](#2-interface-writing-feedback-and-privacy)
3. [Navigation and presentation](#3-navigation-and-presentation)
4. [Lists, forms, settings, search, and menus](#4-lists-forms-settings-search-and-menus)
5. [Buttons, selection, fields, and standard controls](#5-buttons-selection-fields-and-standard-controls)
6. [Toolbars, Liquid Glass, symbols, and motion](#6-toolbars-liquid-glass-symbols-and-motion)
7. [Photos, files, sharing, camera, and permissions](#7-photos-files-sharing-camera-and-permissions)
8. [Accessibility, text adaptation, and localization](#8-accessibility-text-adaptation-and-localization)
9. [Testing, responsiveness, and performance](#9-testing-responsiveness-and-performance)
10. [Xcode 27 and current SwiftUI](#10-xcode-27-and-current-swiftui)

## 1. Design foundations and resources

| Source | Governs | Open when | Current areas | Verified |
| --- | --- | --- | --- | --- |
| [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/) | Platform hierarchy, harmony, consistency, patterns, and components | Starting any material UI or interaction decision | All screens | 2026-07-31 |
| [Design principles](https://developer.apple.com/design/human-interface-guidelines/design-principles) | Purpose, familiarity, feedback, recovery, responsibility, and inclusive design | Evaluating product quality or competing design directions | All flows | 2026-07-31 |
| [Apple Design Resources](https://developer.apple.com/design/resources/) | Official templates, fonts, symbols, and production resources | Preparing platform-accurate visual or icon work | Brand and visual foundations | 2026-07-31 |
| [Principles of great design](https://developer.apple.com/videos/play/wwdc2026/250/) | Current Apple product-design evaluation | Reviewing whether a flow feels intentional and coherent | Milestone reviews | 2026-07-31 |
| [Communicate your brand identity on iOS](https://developer.apple.com/videos/play/wwdc2026/251/) | Brand expression within native iOS structure | Applying White Noise identity without replacing platform conventions | Brand elements, onboarding | 2026-07-31 |
| [Create UI prototypes using agents in Xcode](https://developer.apple.com/videos/play/wwdc2026/227/) | Realistic content, interaction iteration, and tuning key moments | Planning or refining prototype work | Prototype workflow | 2026-07-31 |

## 2. Interface writing, feedback, and privacy

| Source | Governs | Open when | Current areas | Verified |
| --- | --- | --- | --- | --- |
| [Writing for interfaces](https://developer.apple.com/videos/play/wwdc2022/10037/) | Purposeful, contextual, empathetic interface language | Writing titles, actions, help, empty states, or recovery | All product copy | 2026-07-31 |
| [Alerts](https://developer.apple.com/design/human-interface-guidelines/alerts) | Alert necessity, titles, messages, actions, and tone | Adding interruption, warning, or destructive confirmation | Settings, Chats, onboarding | 2026-07-31 |
| [Feedback](https://developer.apple.com/design/human-interface-guidelines/feedback) | Proportional, accessible status and result feedback | Confirming progress, success, failure, or correction | Copy actions, sending, settings | 2026-07-31 |
| [Privacy](https://developer.apple.com/design/human-interface-guidelines/privacy) | Contextual permission requests, transparency, and recovery | Requesting camera, photos, files, or other protected access | QR scanning, profile media | 2026-07-31 |

## 3. Navigation and presentation

| Source | Governs | Open when | Current areas | Verified |
| --- | --- | --- | --- | --- |
| [Navigation and search](https://developer.apple.com/design/human-interface-guidelines/navigation-and-search) | Hierarchy, context preservation, predictable movement, and search | Choosing push, modal, search, or top-level structure | All flows | 2026-07-31 |
| [NavigationStack](https://developer.apple.com/documentation/swiftui/navigationstack) | SwiftUI stack navigation and route ownership | Implementing hierarchical destinations | Chats, conversation, Settings | 2026-07-31 |
| [NavigationLink](https://developer.apple.com/documentation/swiftui/navigationlink) | Native disclosure and value-driven navigation | Making a row or control reveal a destination | Chats, Settings | 2026-07-31 |
| [ToolbarItemPlacement.primaryAction](https://developer.apple.com/documentation/swiftui/toolbaritemplacement/primaryaction) | Primary toolbar action placement in a pushed destination | Placing Profile's Edit and Done actions without modal confirmation semantics | Profile editing | 2026-08-03 |
| [navigationBarBackButtonHidden](https://developer.apple.com/documentation/swiftui/view/navigationbarbackbuttonhidden(_:)) | Replacing the system Back action during a bounded edit state | Temporarily providing Cancel instead of leaving with an active draft | Profile editing | 2026-08-03 |
| [Sheets](https://developer.apple.com/design/human-interface-guidelines/sheets) | Scoped modal tasks, dismissal, and button placement | Deciding whether work belongs in a sheet | Sign In, Sign Up, switcher | 2026-07-31 |
| [presentationDetents](https://developer.apple.com/documentation/swiftui/view/presentationdetents(_:)) | Native medium and large sheet heights | Supporting content-appropriate sheet sizing | Onboarding, profile switcher | 2026-07-31 |
| [PresentationContentInteraction](https://developer.apple.com/documentation/swiftui/presentationcontentinteraction) | Sheet resizing versus scrolling priority | Resolving nested sheet/content gestures | Onboarding, profile switcher | 2026-07-31 |
| [Presentation modifiers](https://developer.apple.com/documentation/swiftui/view-presentation) | SwiftUI sheet, cover, detent, background, and interaction APIs | Selecting a presentation API or behavior | Modal flows | 2026-07-31 |
| [confirmationDialog](https://developer.apple.com/documentation/swiftui/view/confirmationdialog(_:ispresented:titlevisibility:presenting:actions:message:)) | Native action-choice and confirmation presentation | Presenting intentional choices without a custom action sheet | Chats, Settings | 2026-07-31 |
| [Action sheets](https://developer.apple.com/design/human-interface-guidelines/action-sheets) | Compact choices related to a deliberate action | Choosing between a confirmation dialog, menu, or alert | Chats | 2026-07-31 |
| [UIAlertController](https://developer.apple.com/documentation/uikit/uialertcontroller) | UIKit alert and action-sheet presentation | Implementing a native confirmation from UIKit | Native Chats | 2026-07-31 |

## 4. Lists, forms, settings, search, and menus

| Source | Governs | Open when | Current areas | Verified |
| --- | --- | --- | --- | --- |
| [Settings](https://developer.apple.com/design/human-interface-guidelines/settings) | Settings hierarchy, restraint, and system preference respect | Adding or reorganizing a preference | Settings | 2026-07-31 |
| [Lists and tables](https://developer.apple.com/design/human-interface-guidelines/lists-and-tables) | Row hierarchy, selection, editing, disclosure, and scanning | Designing list content or row interactions | Chats, relays, profiles | 2026-07-31 |
| [Form](https://developer.apple.com/documentation/swiftui/form) | Native grouped data entry and settings structure | Building editable fields or preference groups | Sign Up, Settings | 2026-07-31 |
| [List](https://developer.apple.com/documentation/swiftui/list) | Native rows, scrolling, separators, selection, and deletion | Implementing standard single-column collections | Settings, switcher | 2026-07-31 |
| [Displaying data in lists](https://developer.apple.com/documentation/swiftui/displaying-data-in-lists) | SwiftUI identity, hierarchy, and list composition | Structuring dynamic or hierarchical data | Settings, relay lists | 2026-07-31 |
| [Search modifiers](https://developer.apple.com/documentation/swiftui/view-search) | Native search presentation and activation | Adding searchable content | Chats | 2026-07-31 |
| [Adding a search interface](https://developer.apple.com/documentation/swiftui/adding-a-search-interface-to-your-app) | Search placement, suggestions, scopes, and programmatic state | Implementing a complete SwiftUI search experience | Chats | 2026-07-31 |
| [Design intuitive search experiences](https://developer.apple.com/videos/play/wwdc2026/292/) | Search entry, result hierarchy, scope, and recovery | Evaluating search behavior beyond API mechanics | Chats and future people search | 2026-07-31 |
| [Menus HIG](https://developer.apple.com/design/human-interface-guidelines/menus) | Menu purpose, organization, labels, and destructive roles | Deciding whether secondary commands belong in a menu | Chats, onboarding | 2026-07-31 |
| [Menus and commands](https://developer.apple.com/documentation/swiftui/menus-and-commands) | Native compact command and option groups | Exposing secondary actions or filters | Chats, profile actions | 2026-07-31 |
| [Populating SwiftUI menus with adaptive controls](https://developer.apple.com/documentation/SwiftUI/Populating-SwiftUI-menus-with-adaptive-controls) | Labels, symbols, selection, and destructive menu roles | Building nontrivial menus | Chats filters, avatar actions | 2026-07-31 |
| [EditButton](https://developer.apple.com/documentation/swiftui/editbutton) | Native entry and exit for edit mode | Allowing list deletion or reordering | Relays | 2026-07-31 |
| [EditMode](https://developer.apple.com/documentation/swiftui/editmode) | Environment-owned list editing state | Coordinating content with native editing | Relays | 2026-07-31 |
| [LabeledContent](https://developer.apple.com/documentation/swiftui/labeledcontent) | Semantic label/value alignment | Presenting settings values or compact statuses | Settings, relays | 2026-07-31 |

### UIKit list implementation

Open these only when a selected screen genuinely needs UIKit list behavior that
SwiftUI cannot provide cleanly. They do not authorize a parallel component
system.

| Source | Governs | Open when | Current areas | Verified |
| --- | --- | --- | --- | --- |
| [UICollectionLayoutListConfiguration](https://developer.apple.com/documentation/uikit/uicollectionlayoutlistconfiguration) | Native collection-view list appearance and behavior | Configuring the native Chats collection layout | Native Chats | 2026-07-31 |
| [Updating collection views using diffable data sources](https://developer.apple.com/documentation/uikit/updating-collection-views-using-diffable-data-sources) | Stable UIKit collection updates | Applying chat snapshots without manual index mutations | Native Chats | 2026-07-31 |
| [UIHostingConfiguration](https://developer.apple.com/documentation/swiftui/uihostingconfiguration) | SwiftUI content hosted inside UIKit cells | Using local SwiftUI row content in a native collection cell | Native Chats | 2026-07-31 |
| [UICellConfigurationState](https://developer.apple.com/documentation/uikit/uicellconfigurationstate) | Native cell state and custom state keys | Keeping hosted rows synchronized with UIKit state | Native Chats | 2026-07-31 |
| [UIContextualAction](https://developer.apple.com/documentation/uikit/uicontextualaction) | A single contextual row action | Adding an approved swipe action | Native Chats | 2026-07-31 |
| [UISwipeActionsConfiguration](https://developer.apple.com/documentation/uikit/uiswipeactionsconfiguration) | Leading and trailing swipe-action groups | Configuring approved row swipe behavior | Native Chats | 2026-07-31 |
| [UIScrollViewDelegate](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate) | UIKit scrolling lifecycle callbacks | Coordinating an approved navigation or scroll effect | Native Chats | 2026-07-31 |
| [contentInsetAdjustmentBehavior](https://developer.apple.com/documentation/uikit/uiscrollview/contentinsetadjustmentbehavior-swift.property) | Safe-area inset adjustment for UIKit scroll views | Resolving content and navigation-bar insets | Native Chats | 2026-07-31 |
| [topEdgeEffect](https://developer.apple.com/documentation/uikit/uiscrollview/topedgeeffect) | System scroll-edge treatment at the top edge | Integrating the current navigation material with UIKit content | Native Chats | 2026-07-31 |
| [UIScrollEdgeEffect.Style.hard](https://developer.apple.com/documentation/uikit/uiscrolledgeeffect/style-swift.class/hard) | Hard system scroll-edge transition | Choosing the documented hard edge for an approved screen | Native Chats | 2026-07-31 |
| [UIScrollEdgeEffect isHidden](https://developer.apple.com/documentation/uikit/uiscrolledgeeffect/ishidden) | Visibility of a system scroll-edge effect | Suppressing a redundant system edge effect | Native Chats | 2026-07-31 |

## 5. Buttons, selection, fields, and standard controls

| Source | Governs | Open when | Current areas | Verified |
| --- | --- | --- | --- | --- |
| [Buttons HIG](https://developer.apple.com/design/human-interface-guidelines/buttons) | Button hierarchy, labels, roles, and prominence | Choosing or reviewing an action treatment | All screens | 2026-07-31 |
| [Button](https://developer.apple.com/documentation/swiftui/button) | Native activation, feedback, focus, and accessibility | Adding any actionable control | All screens | 2026-07-31 |
| [ButtonBorderShape](https://developer.apple.com/documentation/swiftui/buttonbordershape) | System-owned button geometry | Choosing a supported bordered shape | Onboarding actions | 2026-07-31 |
| [Picker](https://developer.apple.com/documentation/swiftui/picker) | Native single-choice selection | Selecting a mode or preference | Settings, Share & Connect | 2026-07-31 |
| [Palette picker style](https://developer.apple.com/documentation/swiftui/pickerstyle/palette) | Compact mutually exclusive palette selection | Presenting closely related modes in a toolbar | Share & Connect | 2026-07-31 |
| [Segmented controls](https://developer.apple.com/design/human-interface-guidelines/segmented-controls) | Appropriate use of mutually exclusive segments | Comparing segmented and palette patterns | Share & Connect | 2026-07-31 |
| [Toggle](https://developer.apple.com/documentation/swiftui/toggle) | Native binary preferences and semantics | Adding an on/off setting | Settings | 2026-07-31 |
| [Text fields HIG](https://developer.apple.com/design/human-interface-guidelines/text-fields) | Field purpose, labels, affordances, and validation | Designing any text-entry experience | Onboarding, conversation, Settings | 2026-07-31 |
| [TextField](https://developer.apple.com/documentation/swiftui/textfield) | Native editable text, focus, submission, and multiline entry | Adding ordinary text entry | Sign Up, conversation, Settings | 2026-07-31 |
| [SecureField](https://developer.apple.com/documentation/swiftui/securefield) | Native obscured sensitive entry | Entering private keys or backup passwords | Sign In, Profile Keys | 2026-07-31 |
| [Focus](https://developer.apple.com/documentation/swiftui/focus) | SwiftUI focus state, movement, and focused values | Coordinating keyboard focus or restoration | Sign In, Sign Up, conversation | 2026-07-31 |
| [disabled](https://developer.apple.com/documentation/swiftui/view/disabled(_:)) | Native disabled interaction and accessibility state | Preventing an action until its requirements are met | Onboarding and forms | 2026-07-31 |
| [isEnabled](https://developer.apple.com/documentation/swiftui/environmentvalues/isenabled) | Reading enabled state from the environment | Adapting a local component to system-disabled behavior | Onboarding controls | 2026-07-31 |
| [TextFieldStyle](https://developer.apple.com/documentation/swiftui/textfieldstyle) | System-provided field styles | Evaluating whether a standard field treatment fits | Sign In, forms | 2026-07-31 |
| [textInputBorderShape](https://developer.apple.com/documentation/swiftui/view/textinputbordershape(_:)) | System border shape for text input | Reviewing a bordered input treatment | Sign In | 2026-07-31 |
| [Capsule](https://developer.apple.com/documentation/swiftui/capsule) | SwiftUI capsule geometry | Implementing a user-approved capsule with semantic fills | Sign In, Share & Connect | 2026-07-31 |
| [secondarySystemFill](https://developer.apple.com/documentation/uikit/uicolor/secondarysystemfill) | Adaptive subordinate fill color | Toning down a local utility control without custom material | Share & Connect | 2026-07-31 |
| [ControlSize](https://developer.apple.com/documentation/swiftui/controlsize) | Semantic system control sizing | Choosing among system-provided size variants | Toolbars and actions | 2026-07-31 |
| [ContentUnavailableView](https://developer.apple.com/documentation/swiftui/contentunavailableview) | Native empty, unavailable, and no-results presentation | Showing absent content or capability recovery | Chats, QR scanning | 2026-07-31 |
| [ProgressView](https://developer.apple.com/documentation/swiftui/progressview) | Native determinate and indeterminate progress | Representing work that is not immediate | Onboarding, relays, support | 2026-07-31 |
| [tint(_:)](https://developer.apple.com/documentation/swiftui/view/tint(_:)) | System tint for controls and indicators | Adding an adaptive semantic color to a standard control | Profile Keys | 2026-08-03 |
| [Progress indicators](https://developer.apple.com/design/human-interface-guidelines/progress-indicators) | Appropriate progress feedback and waiting behavior | Choosing between indeterminate, determinate, and no progress UI | Onboarding, relays | 2026-07-31 |
| [Typography](https://developer.apple.com/design/human-interface-guidelines/typography) | Semantic type hierarchy, legibility, and adaptation | Reviewing text hierarchy or custom type decisions | All screens | 2026-07-31 |
| [badge](https://developer.apple.com/documentation/swiftui/view/badge(_:)) | Native list and tab badge values | Displaying an approved unread count | Chats | 2026-07-31 |
| [BadgeProminence](https://developer.apple.com/documentation/swiftui/badgeprominence) | Native badge emphasis | Choosing standard versus decreased badge emphasis | Chats | 2026-07-31 |

## 6. Toolbars, Liquid Glass, symbols, and motion

| Source | Governs | Open when | Current areas | Verified |
| --- | --- | --- | --- | --- |
| [Toolbars](https://developer.apple.com/documentation/swiftui/toolbars) | SwiftUI toolbar placement, content, and customization | Adding or reorganizing navigation and action controls | Chats, conversation, Share & Connect | 2026-07-31 |
| [Adopting Liquid Glass](https://developer.apple.com/documentation/TechnologyOverviews/adopting-liquid-glass) | System-first adoption of Apple’s current visual design | Adding or reviewing glass, bars, or controls | Toolbars, onboarding, composer | 2026-07-31 |
| [Applying Liquid Glass to custom views](https://developer.apple.com/documentation/SwiftUI/Applying-Liquid-Glass-to-custom-views) | Custom glass only when native components do not fit | Implementing an approved custom glass exception | Conversation composer | 2026-07-31 |
| [GlassButtonStyle](https://developer.apple.com/documentation/swiftui/glassbuttonstyle) | Native secondary glass buttons | Styling an approved secondary action | Onboarding, scanner recovery | 2026-07-31 |
| [GlassProminentButtonStyle](https://developer.apple.com/documentation/swiftui/glassprominentbuttonstyle) | Native prominent glass actions | Styling the primary action | Onboarding, confirmations | 2026-07-31 |
| [Refining system-provided Liquid Glass in toolbars](https://developer.apple.com/documentation/swiftui/landmarks-refining-the-system-provided-glass-effect-in-toolbars) | Toolbar grouping and automatic glass structure | Organizing adjacent toolbar controls | Chats, Share & Connect | 2026-07-31 |
| [ToolbarSpacer](https://developer.apple.com/documentation/swiftui/toolbarspacer) | Semantic separation between toolbar groups | Controlling toolbar grouping without custom gaps | Chats | 2026-07-31 |
| [sharedBackgroundVisibility](https://developer.apple.com/documentation/swiftui/toolbarcontent/sharedbackgroundvisibility(_:)) | Participation in automatic shared toolbar backgrounds | Keeping approved artwork outside a glass group | Chats avatar | 2026-07-31 |
| [safeAreaBar](https://developer.apple.com/documentation/swiftui/view/safeareabar(edge:alignment:spacing:content:)) | Stationary actions beside scrolling content | Installing a system-owned bottom action bar | Chats | 2026-07-31 |
| [safeAreaInset](https://developer.apple.com/documentation/swiftui/view/safeareainset(edge:alignment:spacing:content:)) | Content inset by a view at a safe-area edge | Placing a composer without covering scroll content | Conversation | 2026-07-31 |
| [ignoresSafeArea](https://developer.apple.com/documentation/swiftui/view/ignoressafearea(_:edges:)) | Intentional extension beyond safe areas | Making an approved background or camera preview full-bleed | Chats, QR scanning | 2026-07-31 |
| [ScrollView](https://developer.apple.com/documentation/swiftui/scrollview) | Native scroll container behavior and indicators | Building a custom scrolling timeline | Conversation | 2026-07-31 |
| [LazyVStack](https://developer.apple.com/documentation/swiftui/lazyvstack) | Lazy vertical layout in a scroll view | Rendering a prototype message timeline | Conversation | 2026-07-31 |
| [ScrollEdgeEffectStyle](https://developer.apple.com/documentation/swiftui/scrolledgeffectstyle) | Native transitions between scrolling content and controls | Choosing hard, soft, or automatic scroll-edge behavior | Chats, conversation | 2026-07-31 |
| [Motion](https://developer.apple.com/design/human-interface-guidelines/motion) | Purposeful, comfortable, system-consistent motion | Adding or reviewing animation or transition behavior | All animated flows | 2026-07-31 |
| [SensoryFeedback](https://developer.apple.com/documentation/swiftui/sensoryfeedback) | Semantic system haptic feedback | Confirming a meaningful result or threshold | Copy, selection, success | 2026-07-31 |
| [SF Symbols HIG](https://developer.apple.com/design/human-interface-guidelines/sf-symbols) | Symbol selection, variants, rendering, localization, and effects | Choosing an interface icon | All screens | 2026-07-31 |
| [SF Symbols](https://developer.apple.com/sf-symbols/) | Current symbol browser and availability resources | Verifying a symbol and platform support | All screens | 2026-07-31 |

## 7. Photos, files, sharing, camera, and permissions

| Source | Governs | Open when | Current areas | Verified |
| --- | --- | --- | --- | --- |
| [PhotosPicker](https://developer.apple.com/documentation/photosui/photospicker) | Privacy-preserving system photo selection | Selecting an avatar or message image | Sign Up, Profile, conversation | 2026-07-31 |
| [Bringing Photos picker to your SwiftUI app](https://developer.apple.com/documentation/photokit/bringing-photos-picker-to-your-swiftui-app) | End-to-end SwiftUI photo-picker integration | Implementing selection, loading, and state handling | Sign Up, Profile | 2026-07-31 |
| [fileImporter](https://developer.apple.com/documentation/swiftui/view/fileimporter(ispresented:allowedcontenttypes:allowmultipleselection:oncompletion:)) | System file selection | Importing an image or chat file | Sign Up, conversation | 2026-07-31 |
| [fileExporter](https://developer.apple.com/documentation/swiftui/view/fileexporter(ispresented:document:contenttype:defaultfilename:oncompletion:)) | System destination picker for exported files | Saving a private-key or encrypted-backup document without a custom browser | Profile Keys | 2026-08-03 |
| [FileDocument](https://developer.apple.com/documentation/swiftui/filedocument) | Value-type serialization for exported documents | Preparing deterministic key-export content for `fileExporter` | Profile Keys | 2026-08-03 |
| [File management](https://developer.apple.com/design/human-interface-guidelines/file-management) | Familiar Files destinations and system-owned save behavior | Designing a file export or save flow | Profile Keys | 2026-08-03 |
| [ShareLink](https://developer.apple.com/documentation/swiftui/sharelink) | Native system sharing from SwiftUI | Sharing a profile or export value | Share & Connect, Profile Keys | 2026-07-31 |
| [Activity views](https://developer.apple.com/design/human-interface-guidelines/activity-views) | Share-sheet purpose and presentation | Evaluating native sharing behavior | Share & Connect, exports | 2026-07-31 |
| [QR code generator](https://developer.apple.com/documentation/coreimage/cifilter/qrcodegenerator()) | Local Core Image QR generation | Producing deterministic shareable QR imagery | Sign In, Share & Connect, Donate | 2026-07-31 |
| [DataScannerViewController](https://developer.apple.com/documentation/visionkit/datascannerviewcontroller) | Native live data scanning | Implementing physical-iPhone QR scanning | Sign In, Share & Connect | 2026-07-31 |
| [RecognizedItem](https://developer.apple.com/documentation/visionkit/recognizeditem) | Typed results from VisionKit recognition | Interpreting scanner output without custom camera recognition | Sign In, Share & Connect | 2026-07-31 |
| [Scanning data with the camera](https://developer.apple.com/documentation/visionkit/scanning-data-with-the-camera) | Scanner availability, guidance, highlighting, and recognition | Designing the complete scanning lifecycle | Sign In, Share & Connect | 2026-07-31 |
| [Camera authorization](https://developer.apple.com/documentation/avfoundation/requesting-authorization-to-capture-and-save-media) | Camera permission status and system request | Requesting or recovering camera access | QR scanning | 2026-07-31 |
| [Asking permission to use notifications](https://developer.apple.com/documentation/usernotifications/asking-permission-to-use-notifications) | Contextual notification authorization and response handling | Adding or reviewing notification permission behavior | Notification settings | 2026-07-31 |
| [User Notifications](https://developer.apple.com/documentation/usernotifications) | Local notification creation and remote APNs delivery | Distinguishing on-device notifications from remote push | Notification settings | 2026-08-03 |
| [UNNotificationSettings](https://developer.apple.com/documentation/usernotifications/unnotificationsettings) | Live notification authorization and per-interaction settings | Enabling or disabling app options based on iOS notification access | Notification settings | 2026-08-03 |
| [Pushing background updates to your app](https://developer.apple.com/documentation/usernotifications/pushing-background-updates-to-your-app) | Content-free remote wake-up behavior and delivery limits | Explaining or implementing background push | Notification settings | 2026-08-03 |
| [Open notification settings](https://developer.apple.com/documentation/uikit/uiapplication/opennotificationsettingsurlstring) | Direct URL to this app's notification settings | Offering recovery after notification access is denied | Notification settings | 2026-08-03 |
| [Open Settings](https://developer.apple.com/documentation/uikit/uiapplication/opensettingsurlstring) | System Settings recovery URL | Offering recovery after other denied permissions | QR scanning | 2026-07-31 |
| [UIGraphicsImageRenderer](https://developer.apple.com/documentation/uikit/uigraphicsimagerenderer) | Bounded local image preparation | Resizing selected profile imagery before holding it in memory | Sign Up, Profile | 2026-07-31 |

## 8. Accessibility, text adaptation, and localization

| Source | Governs | Open when | Current areas | Verified |
| --- | --- | --- | --- | --- |
| [Accessibility HIG](https://developer.apple.com/design/human-interface-guidelines/accessibility) | Inclusive visual, motor, hearing, speech, and cognitive design | Designing or reviewing any interactive screen | All screens | 2026-07-31 |
| [SwiftUI accessibility fundamentals](https://developer.apple.com/documentation/swiftui/accessibility-fundamentals) | Labels, values, grouping, actions, and standard-control behavior | Implementing or reviewing SwiftUI accessibility | All screens | 2026-07-31 |
| [Supporting VoiceOver in your app](https://developer.apple.com/documentation/uikit/supporting-voiceover-in-your-app) | VoiceOver auditing, labels, grouping, order, and custom elements | Reviewing spoken navigation or a custom composition | All screens | 2026-07-31 |
| [Performing accessibility audits](https://developer.apple.com/documentation/accessibility/performing-accessibility-audits-for-your-app) | Inspector checks for descriptions, hit regions, contrast, clipping, and traits | Running milestone accessibility review | Milestone reviews | 2026-07-31 |
| [Dynamic Type](https://developer.apple.com/documentation/swiftui/environmentvalues/dynamictypesize) | Content-size adaptation | Checking semantic typography and layout growth | All screens | 2026-07-31 |
| [Reduce Motion](https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityreducemotion) | Motion adaptation from the environment | Adding or reviewing custom motion | Animated flows | 2026-07-31 |
| [Localization](https://developer.apple.com/documentation/xcode/localization) | String catalogs, language and region adaptation, and localization testing | Preparing production copy or checking expansion and right-to-left behavior | All product copy | 2026-07-31 |
| [Supporting multiple languages in your app](https://developer.apple.com/documentation/xcode/supporting-multiple-languages-in-your-app) | Internationalization and system language adaptation | Adding or reviewing supported app languages | Appearance and all product copy | 2026-08-03 |
| [Localizing and varying text with a string catalog](https://developer.apple.com/documentation/xcode/localizing-and-varying-text-with-a-string-catalog) | String-catalog setup, translations, plurals, and language variants | Turning a planned language into a complete localization | Appearance and all product copy | 2026-08-03 |

## 9. Testing, responsiveness, and performance

| Source | Governs | Open when | Current areas | Verified |
| --- | --- | --- | --- | --- |
| [Xcode testing](https://developer.apple.com/documentation/xcode/testing) | Unit, integration, UI, and performance test capabilities | Adding a justified regression or logic test | Test targets | 2026-07-31 |
| [Testing and performance](https://developer.apple.com/documentation/technologyoverviews/testing-and-performance) | Responsiveness, stalls, hitches, energy, and concurrency | Investigating a reproducible quality issue | Chats, conversation | 2026-07-31 |
| [Writing and running performance tests](https://developer.apple.com/documentation/xcode/writing-and-running-performance-tests) | Repeatable performance baselines | Protecting a proven performance-critical path | Native chat list | 2026-07-31 |

## 10. Xcode 27 and current SwiftUI

| Source | Governs | Open when | Current areas | Verified |
| --- | --- | --- | --- | --- |
| [Xcode 27 release notes](https://developer.apple.com/documentation/xcode-release-notes/xcode-27-release-notes) | Current toolchain, SDK, compiler, and beta behavior | A build, API, simulator, preview, or test behavior is uncertain | Project-wide | 2026-07-31 |
| [SwiftUI documentation](https://developer.apple.com/documentation/swiftui/) | Primary framework API reference | Implementing or checking a SwiftUI API | Project-wide | 2026-07-31 |
| [SwiftUI updates](https://developer.apple.com/documentation/updates/swiftui) | Current framework additions and changes | Considering a new or changed SwiftUI capability | Project-wide | 2026-07-31 |
| [WWDC26 SwiftUI guide](https://developer.apple.com/wwdc26/guides/swiftui/) | Curated current SwiftUI sessions and Xcode 27 guidance | Starting research on a current SwiftUI topic | Project-wide | 2026-07-31 |
| [What’s new in SwiftUI](https://developer.apple.com/videos/play/wwdc2026/269/) | Current presentation, toolbar, data-flow, and performance changes | Evaluating iOS 27 implementation options | Project-wide | 2026-07-31 |
| [Xcode, agents, and you](https://developer.apple.com/videos/play/wwdc2026/259/) | Apple’s agent workflow and review expectations | Improving repository agent collaboration | Agent workflow | 2026-07-31 |

## Maintenance

- Add a source only when an implemented or selected screen needs it.
- Prefer a direct HIG page, API page, WWDC session, or official sample over a
  search result, forum answer, or third-party summary.
- Update the verification date when a source is reopened and confirmed.
- Remove duplicates and superseded links instead of retaining historical API
  advice.
- If a live source is temporarily unavailable, do not invent a platform claim;
  state the limitation and use already recorded local decisions until the
  source can be checked.
