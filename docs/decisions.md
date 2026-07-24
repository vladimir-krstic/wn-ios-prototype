# Decisions

This file records only material decisions that continue to govern the prototype.

## WN-PROTOTYPE-0001 — Minimal clean restart

- Date: 2026-07-23
- Status: Approved

The repository is a fast native iPhone prototype workspace. It starts with a clean development placeholder and builds one user-agreed screen or tightly related flow at a time.

- Native Apple components and APIs are the default.
- Each selected screen gets one concise brief; future screens are not predesigned.
- Architecture, state, fixtures, permissions, assets, and tests are introduced only when current work needs them.
- Every batch is built, previewed, launched, and inspected directly by the user.
- The user alone accepts product and visual results.
- Claude is never invoked automatically; a neutral prompt is supplied only when the user requests a major review.
- Existing Git history is preserved. The pre-reset working tree was archived outside the repository before cleanup.
