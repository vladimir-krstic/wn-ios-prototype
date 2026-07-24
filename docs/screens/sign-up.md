# Sign Up

## Purpose and navigation

Create a new White Noise profile. **Sign Up** is pushed from Welcome and uses the native navigation bar and Back behavior.

## Copy

- Navigation title: **Sign Up**
- Initial dummy name: **Mochi**
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

- `NavigationStack` push navigation from Welcome.
- Circular SwiftUI avatar preview with the first name initial or the selected image.
- Native `Menu` for the compact source choice.
- `PhotosPicker` limited to images.
- SwiftUI `fileImporter` limited to image files.
- Native grouped `Form` with its scroll background hidden so the canvas matches Welcome.
- Plain native `TextField` controls inside separate grouped Name and About cards.
- Semantic system fill distinguishes the grouped cards from the white canvas while native Form geometry owns their shape and insets.
- Native `glass` avatar action and `glassProminent` primary action.
- Native small `ProgressView` centered inside the primary action while signing up.
- The shared primary-action content follows the adaptive monochrome tint: white title or spinner on the black Light Mode button, and black title or spinner on the white Dark Mode button. Native `glassProminent` continues to own enabled and disabled styling.

## Important behavior

- The form starts with the deterministic pet name **Mochi** and an **M** monogram.
- The avatar remains a white circle with a black initial in Dark Mode.
- Editing Name immediately updates the monogram to the first non-whitespace character.
- A selected photo replaces the monogram and remains in memory only.
- **Change Photo** reopens the same source menu; **Remove Photo** restores the monogram.
- The avatar action uses the regular native control size with one semantic system spacing step below the avatar.
- The white system canvas maintains visual continuity with Welcome and distinguishes onboarding from Settings.
- Native Form sections own the field-card shape, padding, spacing, and focus behavior; no rounded rectangle is drawn by the app.
- The avatar remains visually floating in a transparent Form row above the fields.
- Photos and Files present their system interfaces. No camera or broad photo-library permission is requested.
- Sign Up preserves its normal dimensions, replaces its visible title with a centered spinner, prevents repeat activation, and exposes **Signing Up** and **In progress** to assistive technologies before invoking its callback.
- The deterministic prototype processing state lasts four seconds so the stable loading treatment is easy to inspect.
- The primary action's post-sign-up destination is intentionally deferred until that destination is selected for implementation.

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
- [PhotosPicker](https://developer.apple.com/documentation/photosui/photospicker)
- [Bringing Photos picker to your SwiftUI app](https://developer.apple.com/documentation/photokit/bringing-photos-picker-to-your-swiftui-app)
- [fileImporter](https://developer.apple.com/documentation/swiftui/view/fileimporter%28ispresented%3Aallowedcontenttypes%3Aoncompletion%3A%29)
- [SwiftUI accessibility fundamentals](https://developer.apple.com/documentation/swiftui/accessibility-fundamentals)

## Acceptance

- **Sign Up** on Welcome pushes this screen and native Back returns without custom navigation chrome.
- The default avatar shows **M** for **Mochi**.
- The avatar action is visually compact and clearly separated from the avatar.
- Sign Up uses the same white system canvas as Welcome.
- Name and About use separate native grouped Form cards with a subtle semantic system fill.
- Form owns field-card corner geometry, insets, and spacing; the app does not supply numeric border or corner-radius recipes.
- **Add Photo** opens a menu with working Photos and Files choices.
- Choosing a supported image previews it; removing it restores the current name initial.
- The bottom **Sign Up** action remains visible above the safe area and keyboard.
- Sign Up shows a centered native spinner for four seconds without changing button dimensions or losing contrast.
- In Light Mode the prominent action has white content on black; in Dark Mode it has black content on white, including normal and loading states.
- The layout remains usable in Light and Dark appearances and at accessibility text sizes.
