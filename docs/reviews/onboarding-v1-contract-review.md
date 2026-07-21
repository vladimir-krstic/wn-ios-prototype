# Onboarding v1 contract review disposition

- Review received: 2026-07-21
- Scope: `onboarding.welcome`, `onboarding.sign-in`, `onboarding.qr-scanner`, `onboarding.sign-up`, and shared onboarding records
- Reviewer: user-supplied Claude Code response
- Claude CLI version: not supplied in the response
- Requested model and effort: Fable, medium
- Raw response: [onboarding-v1-claude-raw.md](onboarding-v1-claude-raw.md)
- Outcome: all accepted findings are corrected; materially revised packet awaits independent re-review

## Material findings

| ID | Disposition | Result |
|---|---|---|
| WN-ONB-001 | Accepted; fixed | Added the machine-readable fixture catalog, the documented fictional-universe section, matching Swift fixture IDs and values, scenario references, and deterministic tests. User direction fixes successful Sign In to Maya Chen and empty-Name Sign Up to Quiet Pine (`QP`). |
| WN-ONB-002 | Accepted; fixed | Both Welcome references now use the cataloged `onboarding.welcome.default` identifier. |
| WN-ONB-003 | Accepted; fixed | All credential fixtures are exactly 32 characters. Sign In now defines neutral behavior below the threshold, exact-equality accepted/existing outcomes at completion, invalid behavior for every other completed or longer value, reset-on-edit/Clear, and Return submission only while enabled. |
| WN-ONB-004 | Accepted; fixed | Added launchable `onboarding.qr.valid-code` catalog and Swift identifiers with a fixed-delay simulated result contract. |
| WN-ONB-005 | Accepted; fixed | Added `onboarding.qr.accessibility-stress` and constrained it to the dense simulated camera-error recovery state. |
| WN-ONB-006 | Accepted; fixed from existing authority | Changed progress to **Signing Up…**. The screen-specific approved issue #832 is more specific than the general example, and the local language reference now reserves **Creating Profile…** for an action actually named **Create Profile**. |
| WN-ONB-007 | Accepted; fixed | Corrected the Dark logomark asset UUID in the provenance manifest. |

## Minor findings

| ID | Disposition | Result |
|---|---|---|
| WN-ONB-008 | Accepted; fixed | Welcome now specifies **White Noise**, **Login**, **Sign Up** as the full VoiceOver order. |
| WN-ONB-009 | Accepted; fixed | Restored the approved compact-screen logo-scale anchor while preserving safe-area and action protection. |
| WN-ONB-010 | Accepted; fixed with stronger coverage | Restored the distinct no-camera copy and added `onboarding.qr.no-camera` instead of silently merging it into unavailable. |
| WN-ONB-011 | Accepted; fixed | Sign Up creation failure is inline near the primary-action region; **Back** remains the native navigation action. Partial-save recovery is inline with its actions. |
| WN-ONB-012 | Accepted; fixed | Sign Up VoiceOver order now follows native Form semantics: avatar preview, actions, disclosure. |
| WN-ONB-013 | Accepted; fixed | The reusable review prompt now references `docs/design-system.md`. |
| WN-ONB-014 | Accepted; fixed | Each onboarding contract now contains a Review section with the available review metadata and pending status. |

## Cross-screen hardening

- Accepted the optional registry-parity recommendation. `scripts/validate-foundation.sh` now rejects catalog-like screen or scenario identifiers in contracts when no matching catalog entry exists.
- The fixture catalog, Swift `OnboardingFixtureID`, scenario references, contract identifiers, and unit tests are validated together so credential values, QR payloads, Profile outcomes, and tests cannot drift.

## Re-review gate

Run foundation validation and Xcode 27 tests, then use `docs/review-prompts/onboarding-v1-claude-rereview.md` for a neutral read-only review of the materially revised packet. No screen moves to `independentlyApproved` before that response is dispositioned.

## Verification after correction

- `./scripts/validate-foundation.sh`: passes with 36 screens, 60 scenarios, fixture/catalog parity, and no prohibited runtime dependencies.
- Xcode 27 beta Swift Testing: 6 tests in `Prototype foundation` pass on iPhone 17 simulator, including credential threshold/outcomes, QR allowlisting, and Quiet Pine creation fixtures.
- `git diff --check`: passes.
