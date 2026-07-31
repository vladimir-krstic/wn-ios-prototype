# Decisions

This file records only material decisions that continue to govern the prototype.

## WN-PROTOTYPE-0001 — Minimal clean restart

- Date: 2026-07-23
- Status: Approved

The repository is a fast native iPhone prototype workspace. It started with a clean development placeholder and builds one user-agreed screen or tightly related flow at a time. WN-PROTOTYPE-0002 supersedes the original per-batch build and inspection cadence below.

- Native Apple components and APIs are the default.
- Each selected screen gets one concise brief; future screens are not predesigned.
- Architecture, state, fixtures, permissions, assets, and tests are introduced only when current work needs them.
- Every batch is built, previewed, launched, and inspected directly by the user.
- The user alone accepts product and visual results.
- Claude is never invoked automatically; a neutral prompt is supplied only when the user requests a major review.
- Existing Git history is preserved. The pre-reset working tree was archived outside the repository before cleanup.

## WN-PROTOTYPE-0002 — Fast iteration and inspection workflow

- Date: 2026-07-30
- Status: Approved

The prototype now contains implemented product flows, but the clean-restart
working style remains authoritative.

- Work on one user-agreed screen or bounded flow at a time.
- Screen briefs record durable accepted decisions rather than every iteration.
- Small changes use static validation; build once at the end of a meaningful
  batch.
- Device Hub inspection occurs only when requested or explicitly approved.
- The iPhone Air running iOS 27 is the single default inspection device. Reuse
  it rather than booting another simulator.
- Never claim visual verification without inspecting the current build.
- The user alone accepts visual and product results.
- Claude and Fable are manual major-batch reviewers only.

## WN-PROTOTYPE-0003 — Consolidate only proven duplication

- Date: 2026-07-30
- Status: Approved

- Keep the empty unit-test target and its tracked `.gitkeep` as a normal Xcode
  project placeholder; add a test only when meaningful nonvisual logic
  justifies one.
- Keep mutable chat state with its owning profile so list actions and profile
  unread badges share one source of truth.
- Use one shared profile-avatar renderer, one QR-image generator, and one
  physical VisionKit scanner after repeated implementations proved those
  abstractions necessary.
- Bundle profile imagery at a maximum 512-pixel dimension. Preserve the
  scanner backdrop dimensions while using efficient photographic compression.
- Raw public-key QR values and key-shaped export fixtures must not expose
  prototype terminology through shareable product surfaces.

## WN-PROTOTYPE-0004 — Self-contained project knowledge

- Date: 2026-07-31
- Status: Approved

- All White Noise product knowledge, terminology, screen requirements,
  decisions, and workflow rules required for normal work live in this
  repository.
- Do not read, invoke, or depend on project-specific files, source code,
  instructions, or skills from another local project unless the user explicitly
  requests a bounded cross-project investigation.
- Current official Apple design and developer documentation is an intentional
  live authority. Use `docs/references/apple.md` to open the relevant source
  before a material platform decision and apply
  `docs/references/native-ui.md` when evaluating the result.
- The user’s latest direction outranks Apple’s default pattern. Record an
  approved exception in the selected screen brief.
- User-supplied Figma links, GitHub issues, shipped-app examples, and asset
  sources may remain as optional provenance or comparison evidence, but no
  implementation may require them.
