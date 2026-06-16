# MDBOOK-FORMAT-CORRECTNESS: Fix `.spec` format errors in the mdBook

## Metadata

- Tree ID: `MDBOOK-FORMAT-CORRECTNESS`
- Status: `active`
- Roadmap lane: `Overall roadmap — documentation and book sync`
- Created: `2026-06-16`
- Last updated: `2026-06-16`
- Owner: repo-local workflow

## Goal

Find and fix `.spec` code snippets in the mdBook (`docs/linkedspec-book/src/`) that
misrepresent the actual `.spec` file format recognized by the hardcoded reference grammar
(`perl/LinkedSpec/BootstrapSpec/Core.pm`) and demonstrated by the shipped `specs/*.spec`.
This is a **format-validity** audit, distinct from `MDBOOK-VARIANT-AGNOSTIC` (which addressed
variant-agnostic *framing*, not whether the example syntax is structurally legal).

Trigger: a user caught a malformed example in `appendix/runtime-semantics.md` §5.2/§5.3 —
lifecycle blocks (`I`/`LE`/`E`) nested **inside** an action-edge `-> Bar { … }` code block.
In the real format, lifecycle blocks (`I`/`LS`/`LE`/`E`/`EX`/`IT`/`LX`) are **top-level
rule-paragraph members — siblings of the `->`/`=>` edges**, never nested inside an edge's
`{ … }` (the brace scanner would swallow them as edge code, not recognize them as hooks).

## Non-Goals

- Variant-agnostic framing (already done under `MDBOOK-VARIANT-AGNOSTIC`).
- Changing the `.spec` language or the bootstrap grammar (this fixes docs, not the format).
- Changing internal continuity docs.

## Acceptance Criteria

- Every `.spec` snippet in the book is structurally valid against the bootstrap grammar +
  shipped specs: lifecycle markers are top-level paragraph members (not nested in edge blocks);
  edge syntax (`-> T`, `-> T[N]`, `=> C`, block/fluent/bare), rule headers (`Name:`/`Name::`
  + mode), split markers, and helper forms are all legal.
- The known runtime-semantics §5.2/§5.3 lifecycle-nesting bug is fixed, grounded in real specs.
- Book builds cleanly (`mdbook build`).
- Live docs updated (CHANGES.md, DEVELOPMENT_NOTES.md, MEMORY.md); each leaf committed per `COMMIT.md`.

## Task Tree

- ID: `MDBOOK-FORMAT-CORRECTNESS`
  Status: `active`
  Goal: Find and fix `.spec` format errors in the mdBook
  Children: `.1`, `.2`, `.3`

- ID: `MDBOOK-FORMAT-CORRECTNESS.1`
  Status: `done`
  Goal: Fix the confirmed lifecycle-nesting bug in `appendix/runtime-semantics.md` §5.2/§5.3
  Acceptance: §5.2 and §5.3 show lifecycle blocks as top-level siblings of the `->` edge (not nested), grounded in `tablegrep.spec` / `value-container-flow-helper-reference.md`; `mdbook build` exit 0
  Verification: `done` — §5.2 rewritten to `-> Bar {push(Bar)}` + top-level `LX {return(array_copy(array(Foo)))}` (mirrors `value-container`'s implicit-accumulator form + `tablegrep`'s LX return); §5.3 rewritten to top-level `I {declare(array, results)}` + `-> Bar {push_value(array(results), call(Bar))}` + top-level `E {return(...)}`. Added a clarifying note that the lifecycle blocks are top-level siblings of the edges. `git diff --check` clean; `mdbook build` exit 0.
  Commit: `MDBOOK-FORMAT-CORRECTNESS.1 — fix lifecycle-nesting bug in runtime-semantics §5.2/§5.3`

- ID: `MDBOOK-FORMAT-CORRECTNESS.2`
  Status: `pending`
  Goal: Full format-validity sweep of all remaining book `.spec` snippets; fix any other errors
  Acceptance: every `.spec` code fence audited against the bootstrap grammar + shipped specs; all structural errors fixed (or page confirmed clean); findings recorded
  Verification: `pending`
  Commit: `pending`

- ID: `MDBOOK-FORMAT-CORRECTNESS.3`
  Status: `pending`
  Goal: Finalize — build, live docs, close tree
  Acceptance: `mdbook build` exit 0; CHANGES/DEVELOPMENT_NOTES/MEMORY updated; tree moved to Completed
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `MDBOOK-FORMAT-CORRECTNESS.2` | `pending` | Sweep the rest of the book for other format errors |
| 2 | `MDBOOK-FORMAT-CORRECTNESS.3` | `pending` | Finalize + close |

(`.1` complete — §5.2/§5.3 fixed.)

## Decisions

- `2026-06-16`: Created tree after a user caught a malformed example. Root cause classification:
  lifecycle markers (`I`/`LS`/`LE`/`E`/`EX`/`IT`/`LX`) are `NON_ACTION_CODE_BLOCK` tokens in
  `BootstrapSpec::Core` — top-level paragraph members, peers of the `ACTION_CODE_BLOCK` (`-> T {…}`)
  and `BLIND_CALL_CODE_BLOCK` (`=> C {…}`) edge tokens. Nesting a lifecycle marker inside an edge
  block is invalid (the recursive brace scanner consumes the inner `{…}` as edge-code text).
- `2026-06-16`: Pre-audit grep over all 41 `src/**.md` pages for the malformed signature (an
  edge block-opener immediately followed by a lifecycle marker inside it) found the bug isolated to
  `appendix/runtime-semantics.md` §5.2/§5.3; the three `LX {` hits in
  `dsl/value-container-flow-helper-reference.md` are CORRECT (edge block closes first; `LX` is a
  sibling) — false positives. `.2` widens this to all snippet-structure checks, not just nesting.

## Open Questions

- None.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-16` | `MDBOOK-FORMAT-CORRECTNESS.1` | rewrote runtime-semantics §5.2/§5.3 to top-level lifecycle layout (grounded in tablegrep/value-container); `git diff --check` clean; `mdbook build` exit 0 | PASS |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `MDBOOK-FORMAT-CORRECTNESS.1` | `MDBOOK-FORMAT-CORRECTNESS.1 — fix lifecycle-nesting bug in runtime-semantics §5.2/§5.3` | §5.2/§5.3 lifecycle blocks now top-level siblings of the edge |

## Changelog

- `2026-06-16`: Created task tree (user caught a malformed lifecycle-in-edge-block example in
  `appendix/runtime-semantics.md`). Pre-audit isolated the nesting bug to §5.2/§5.3.
- `2026-06-16`: `.1` done — fixed runtime-semantics §5.2/§5.3 (lifecycle blocks now top-level
  siblings of the `->` edge, not nested inside it), grounded in the shipped specs. Frontier → `.2`.
