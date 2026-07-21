# Information architecture

## Product root

- An unconfigured launch enters Welcome.
- Simulated Sign Up or Sign In activates a profile and enters Chats.
- Chats is the signed-in root. Native hierarchical navigation reaches chats, people, groups, profiles, and Settings.
- The current profile avatar opens the Settings profile hub. Do not introduce a macOS sidebar, multiwindow model, or desktop Settings assumptions.

## Team boundary

Scenario Lab, Developer Tools, and Diagnostics are explicitly team-only destinations under a separated Developer Tools area. They never become top-level product navigation and are absent from ordinary product screenshots and accessibility trees unless that team destination is active.

## Screen definition

An app-owned navigation destination or substantive app-owned full-screen/sheet receives a `ScreenID` and individual approval gate. Native menus, alerts, permission prompts, pickers, and share sheets are states of the invoking contract unless app-owned decisions make them independently substantive.
