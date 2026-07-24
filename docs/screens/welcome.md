# Welcome

## Purpose and navigation

First-launch entry screen. It presents the White Noise mark and two choices. **Sign In** opens the existing-profile flow; **Sign Up** opens profile creation.

## Copy

- Secondary action: **Sign In**
- Primary action: **Sign Up**
- Logo accessibility label: **White Noise**
- No heading, tagline, description, dismiss action, or technical language.

## Native components

- `NavigationStack` at the app root for future push navigation.
- Native SwiftUI `Button` controls.
- `glass` for **Sign In** and `glassProminent` for **Sign Up**.
- Flexible extra-large system button sizing.
- Adaptive vector image asset for the White Noise mark.
- Semantic system background and adaptive monochrome accent.

## Important behavior

- The mark is centered above the actions and scales proportionally.
- Actions remain grouped at the bottom inside system safe-area margins.
- Light appearance uses a black mark and black prominent glass with white text.
- Dark appearance uses a white mark and white prominent glass with black text.
- The mark occupies one-half of the available width, exactly 25% less than the previous two-thirds treatment.
- Buttons expose closures now and will receive destinations only when those screens are selected.

## Accessibility

- The mark is announced as **White Noise**.
- Buttons retain native labels, traits, hit targets, focus, press feedback, and Dynamic Type behavior.
- Layout uses safe areas and flexible sizing without fixed text sizes.

## Apple references

- [Buttons](https://developer.apple.com/design/human-interface-guidelines/buttons)
- [GlassProminentButtonStyle](https://developer.apple.com/documentation/swiftui/glassprominentbuttonstyle)
- [SwiftUI accessibility fundamentals](https://developer.apple.com/documentation/swiftui/accessibility-fundamentals)
- [Adopting Liquid Glass](https://developer.apple.com/documentation/TechnologyOverviews/adopting-liquid-glass)

## Acceptance

- Welcome launches without a blank frame.
- The only visible product content is the adaptive White Noise mark, **Sign In**, and **Sign Up**.
- **Sign In** is visually secondary; **Sign Up** is visually primary.
- Both buttons use native Liquid Glass styling and fill the available width within system margins.
- The primary action preserves strong monochrome contrast in both appearances.
- The adaptive mark occupies one-half of the available width.
- The screen builds and renders in Light and Dark appearances.
