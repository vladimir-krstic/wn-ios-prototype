# Foundation v1 independent review

- Date: 2026-07-21
- Reviewer: Claude Code 2.1.215, Claude Fable 5, medium effort
- Mode: read-only (`Read`, `Glob`, `Grep`); no edits or shell access
- Scope: screen gate, determinism, prohibited capabilities, Xcode setup, dual-audience separation, repository skill, and validation controls
- Result: no blockers; five major enforcement findings, all fixed before Foundation v1 handoff

## Findings and dispositions

1. **Screen approval enforcement was procedural only.** Fixed by adding the catalog `implementation` field and rejecting unregistered files, preapproval implementation declarations, and implemented states without files under `WhiteNoisePrototype/Screens/`.
2. **The prohibited-capability scan omitted common indirect forms.** Fixed by covering `@AppStorage`, `@SceneStorage`, SwiftData, Core Data, Security/Keychain APIs, SQLite, additional URL-loading APIs, and crypto imports.
3. **Scenario routes and the fixture clock were duplicated without parity checks.** Fixed by validating every Swift `startScreen` mapping against the scenario catalog and the Swift epoch against the catalog ISO timestamp.
4. **Invalid launch-argument values fell back silently.** Fixed by making missing or unknown scenario and system-mode values precondition failures and by making UI testing force simulated mode regardless of argument order.
5. **The validator did not lock the complete iPhone/portrait boundary.** Fixed by checking the app's Debug and Release orientation, iPhone-only, Mac Catalyst, and Designed-for-iPhone-on-Mac settings and rejecting landscape values.

## Residual checks for screen work

Team-language leakage into screenshots and accessibility output requires per-screen UI assertions and manual review. Scenario class values are now validated. The development team remains intentionally local-project configuration and no remote or distribution workflow is in scope.

## Final disposition

All material findings were accepted and fixed. Foundation v1 may proceed to the first screen's user-approval gate; this review does not independently approve any screen contract or screen implementation.

The same reviewer completed a read-only follow-up and returned `FOLLOW-UP PASSED`. Two non-gating observations were also resolved: project checks now inspect the app's specific Debug and Release configuration blocks, and `onboarding.welcome.default` uses live mode consistently with normal launch while `-WNUITesting` continues to force simulated capabilities.
