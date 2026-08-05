# Sign Up

## Purpose and navigation

Create a new White Noise profile. **Sign Up** on first-launch Welcome presents a native large sheet. Add Profile pushes it inside the existing onboarding sheet.

## Copy

- Navigation title: **Sign Up**
- Initial dummy name: **Marmota**
- Avatar action before selection: **Add Photo**
- Avatar action after selection: **Change Photo**
- Image-source menu: **Choose from Photos**, **Choose from Files**
- Selected-image removal: **Remove Photo**
- Field labels: **Name**, **About**
- About prompt: **A little about you**
- Image error: **Couldn't use that photo. Choose another image and try again.**
- Primary action: **Sign Up**
- Progress accessibility label: **Signing Up**

## Native components

- A first-launch native large sheet with visible drag indicator and a native Close toolbar action.
- Add Profile keeps native Back behavior inside its existing sheet.
- Circular SwiftUI avatar preview with the first name initial or the selected image.
- Native `Menu` for the compact source choice.
- `PhotosPicker` limited to images.
- SwiftUI `fileImporter` limited to image files.
- Native grouped `Form` with its scroll background hidden so the canvas matches Welcome.
- Plain native `TextField` controls inside separate grouped Name and About cards.
- Semantic system fill distinguishes the grouped cards from the white canvas while native Form geometry owns their shape and insets.
- Native `glass` avatar action and `glassProminent` primary action.
- Native small `ProgressView` centered inside the primary action while signing up.
- Enabled primary-action content follows the adaptive monochrome tint: white title or spinner on the black Light Mode button, and black title or spinner on the white Dark Mode button.
- If this shared control enters a disabled environment, its content returns to semantic `primary` and lets native `glassProminent` own the disabled material and reduced prominence.

## Important behavior

- The form starts with the deterministic pet name **Marmota** and an **M** monogram.
- Completing either initial Sign In or Sign Up uses the bundled, user-supplied marmot photo as the active profile avatar.
- The avatar remains a white circle with a black initial in Dark Mode.
- Editing Name immediately updates the monogram to the first non-whitespace character.
- A selected photo replaces the monogram and remains in memory only.
- **Change Photo** reopens the same source menu; **Remove Photo** restores the monogram.
- **Remove Photo** uses SwiftUI's destructive button role. Its complete native `Label` also receives the semantic red style so the title and standard trash symbol match Apple's destructive-menu example despite the current iOS 27 beta rendering the role on the title only.
- The avatar action uses the regular native control size with one stable semantic system spacing step below the avatar. Changing between the monogram and selected image does not alter this spacing.
- The white system canvas maintains visual continuity with Welcome and distinguishes onboarding from Settings.
- Native Form sections own the field-card shape, padding, spacing, and focus behavior; no rounded rectangle is drawn by the app.
- The avatar remains visually floating in a transparent Form row above the fields.
- Photos and Files present their system interfaces. No camera or broad photo-library permission is requested.
- Sign Up preserves its normal dimensions, replaces its visible title with a centered spinner, prevents repeat activation, and exposes **Signing Up** and **In progress** to assistive technologies before invoking its callback.
- The deterministic prototype processing state lasts two seconds so the stable loading treatment remains inspectable without slowing the flow.
- Initial Sign Up and Add Profile both finish on Chats. Add Profile removes the
  underlying Settings destination without animation while its onboarding sheet
  remains visible. The sheet dismissal begins only on the following render turn,
  after the navigation state has committed, and reveals Chats directly.

## Accessibility

- The initials preview is announced as **Profile photo, M** and updates with the name.
- A selected image is announced as **Profile photo**.
- Persistent labels identify Name and About after their prompts disappear.
- Native controls retain system traits, focus, hit targets, Dynamic Type, menu behavior, keyboard behavior, and motion.
- The screen scrolls and dismisses the keyboard interactively.

## Apple references

- [Text fields](https://developer.apple.com/design/human-interface-guidelines/text-fields)
- [Form](https://developer.apple.com/documentation/swiftui/form)
- [Menus](https://developer.apple.com/design/human-interface-guidelines/menus)
- [Populating SwiftUI menus with adaptive controls](https://developer.apple.com/documentation/SwiftUI/Populating-SwiftUI-menus-with-adaptive-controls)
- [PhotosPicker](https://developer.apple.com/documentation/photosui/photospicker)
- [Bringing Photos picker to your SwiftUI app](https://developer.apple.com/documentation/photokit/bringing-photos-picker-to-your-swiftui-app)
- [fileImporter](https://developer.apple.com/documentation/swiftui/view/fileimporter(ispresented:allowedcontenttypes:allowmultipleselection:oncompletion:))
- [SwiftUI accessibility fundamentals](https://developer.apple.com/documentation/swiftui/accessibility-fundamentals)

## Acceptance

- **Sign Up** on Welcome presents a native large sheet; Close or swipe-down returns to Welcome.
- **Sign Up** from Add Profile remains in the existing large onboarding sheet and native Back returns to its Welcome step.
- Completing Sign In or Sign Up from Add Profile shows only the native onboarding-sheet dismissal and reveals Chats directly; Settings never appears or slides away between them.
- The default Sign Up avatar shows **M** for **Marmota** before completion.
- After Sign In or Sign Up completes, Chats and Settings show the bundled Marmota photo as the active profile avatar.
- Wiping the last profile or erasing app data never changes fixture identity:
  fresh Sign In or Sign Up recreates Marmota with the Marmota avatar, while
  Add Profile Sign Up creates the separate Pebble profile with the Pebble
  avatar and stable ID.
- The avatar action is visually compact and clearly separated from the avatar.
- The avatar-to-action spacing remains unchanged before and after selecting a photo.
- Sign Up uses the same white system canvas as Welcome.
- Name and About use separate native grouped Form cards with a subtle semantic system fill.
- Form owns field-card corner geometry, insets, and spacing; the app does not supply numeric border or corner-radius recipes.
- **Add Photo** opens a menu with working Photos and Files choices.
- Choosing a supported image previews it; removing it restores the current name initial.
- The destructive Remove Photo menu item displays both its title and trash symbol with the system destructive treatment.
- The bottom **Sign Up** action remains visible above the safe area and keyboard.
- Sign Up shows a centered native spinner for two seconds without changing button dimensions or losing contrast.
- In Light Mode the prominent action has white content on black; in Dark Mode it has black content on white, including normal and loading states.
- The layout remains usable in Light and Dark appearances and at accessibility text sizes.
