# Deterministic scenario contract

`docs/catalogs/scenarios.json` is the machine-readable registry. Swift `ScenarioID` values must match it exactly.

Every scenario fixes its starting screen, profile state, people, chats, messages, permissions, system-capability mode, clock, delays, appearance, content-size stress, and expected recovery. Scenario application creates a new in-memory state; Reset recreates the selected seed. No scenario may use randomness, current time, remote content, or persisted state.

## Required state classes

- Populated and empty.
- Loading and recoverable error.
- Offline/degraded.
- Permission not determined, allowed, denied, and restricted when the API distinguishes it.
- Long names, messages, filenames, group membership, and media captions.
- Dynamic Type accessibility sizes, Reduce Motion, Bold Text, Increase Contrast, Light/Dark, and RTL layout stress.
- Destructive confirmation and post-action recovery.

Launch arguments are `-WNScenario <id>`, `-WNSystemMode live|simulated`, and `-WNUITesting`, with optional test-only appearance and accessibility overrides.
