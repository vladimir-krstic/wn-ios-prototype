# White Noise product language

Source baseline: the approved `wn-ios-agile` product-language and terminology references as reviewed on 2026-07-21. Latest explicit user direction always wins.

## Product voice

Write calmly, directly, and with light warmth. Lead with the person's task and concrete outcome. Avoid hype, fear, blame, jokes, exclamation marks, false reassurance, and repetitive privacy marketing.

- Welcome entry action: **Login**.
- Existing-profile credential screen and action: **Sign In**.
- New profile entry and action: **Sign Up**.
- Use **Profile**, **Private Key**, **Public Key**, **Chat**, **Group**, **Person/People**, **Member** inside a group, **Relays**, **Sign Out**, **Remove Profile**, and **Sign Out and Remove Data**.
- Do not use identity, account, session, thread, peer, MLS, NIP numbers, Marmot, event, epoch, control plane, raw codes, or raw engine errors in ordinary product UI.
- Developer Tools and Diagnostics may use precise technical terminology when that precision is the purpose.

## Interface rules

- Buttons name their result: **Sign In**, **Retry**, **Remove Profile**, **Open Settings**, **Cancel**.
- Empty states say what is absent and offer the most useful next action.
- Progress uses the action: **Signing In…**, **Creating Profile…**.
- Failures begin with what could not be completed, add a useful reason when known, then recovery. Prefer **Couldn't…** over **Failed to…**.
- Destructive copy names exactly what is removed, what remains, recovery, and device-local consequences once.
- Permission copy explains the feature benefit immediately before the system prompt. Denial explains what is unavailable and offers **Open Settings** when applicable.
- Never expose sensitive values in examples, logs, screenshots, errors, or accessibility output.

English is the authored language. Every custom layout must tolerate localization expansion and right-to-left presentation without inventing translations.
