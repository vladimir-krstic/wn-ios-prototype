# Native design and accessibility contract

## Visual foundation

- Use semantic system colors and materials. The adaptive accent is black in Light and white in Dark.
- Support Light and Dark. Do not create a true-black theme.
- Use semantic text styles and Dynamic Type. Do not set fixed font sizes for product UI.
- Use SF Symbols for standard actions and document deployment availability.
- Let native controls own spacing, shape, padding, typography, material, motion, focus, and accessibility wherever possible.
- Custom UI requires an approved screen-contract exception explaining why no native component fits.

## Interaction

- Use `NavigationStack` for product hierarchy, native sheets for bounded tasks, menus for compact commands, confirmation dialogs or alerts for consequential choices, and Forms/Lists/Pickers/Toggles for their standard semantics.
- Preserve native Back and swipe behavior. Gestures cannot be the only route to important actions.
- Keep feedback near the initiating action. Define loading, disabled, empty, offline, error, destructive, success, and recovery states when relevant.

## Motion and haptics

- Prefer system navigation, presentation, control, and SF Symbol motion.
- Custom motion must explain state or preserve continuity, remain interruptible, and respect Reduce Motion.
- Avoid decorative bounce, stacked animation, and fixed-delay choreography.
- Use haptics sparingly and always retain visible feedback.

## Accessibility acceptance

Every screen contract addresses Dynamic Type, VoiceOver labels/values/traits/order/grouping/actions, 44-point practical targets, contrast, color independence, Reduce Motion, Voice Control naming, keyboard/focus behavior, localization expansion, and RTL. Verification includes Accessibility Inspector and hands-on assistive-technology passes.
