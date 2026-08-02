# MDBOOK DESTINATION ROOT ALIGNMENT

Roadmap lane: project-data locality / mdBook workflow safety

Status: `active` — surfaced safety mismatch takes precedence before returning to typed-source runtime work

## Objective

Make `tools/run_mdbook_local.sh` validate and execute every relative custom mdBook destination against one exact
repository-derived base. Prevent a path from passing same-volume validation under one resolution and then being
interpreted by mdBook under another, including when the repository moves or the caller runs outside it.

## Scope boundary

This tree owns the wrapper working directory/destination-resolution seam, a real argument-aware regression in
`tools/test_tool_project_data_storage.sh`, the canonical storage Knowledge fact, and required live continuity.
It does not own mdBook prose readability, book content/theme, language/runtime behavior, dependency upgrades,
general path canonicalization, or off-volume access.

## Task Tree

- ID: `MDBOOK-DESTINATION-ROOT-ALIGNMENT.0`
  Status: `done` / signoff-complete (2026-08-01; intended landing 138/300, no push)
  Goal: Preserve the reproduced validation/execution base mismatch and freeze the smallest exact repair/test plan
    before changing the wrapper.
  Acceptance: Retrieve the canonical tool-storage Knowledge card and existing oracle before re-derivation; record
    the exact relative custom destination, wrapper validation base, mdBook execution base, denial result, affected
    claims, non-goals, implementation seam, RED proof, and next leaf. Change no script, test, book, or behavior.
  Verification: Knowledge Map 785/6,377; memory 55/60; task metadata and all seven doctrines pass; whitespace clean.
  Commit: `MDBOOK-DESTINATION-ROOT-ALIGNMENT.0 - own mdbook destination root mismatch`

### `MDBOOK-DESTINATION-ROOT-ALIGNMENT.0` Acceptance Checklist

- [x] **CLEAN ACTIVATION / TASK OWNERSHIP** — Prove typed-source correction `.14.2.0.1` landed cleanly at
  `bd777ee8` as 137/300 with no push, empty status/diffs, zero-byte brief, synchronized Knowledge Map, absent
  generated book/non-cache bytecode, and no unconsumed background result before this task-tree diff.
- [x] **RETRIEVE EXISTING AUTHORITY** — Retrieve [[tool-project-data-ssd-storage]], the wrapper, and its current
  storage oracle before classifying the reproduced failure.
- [x] **ROOT-CAUSE EXACT BASES** — Record which base validates relative custom destinations, which base mdBook
  actually uses, and why the mismatch can attempt an off-repository write after validation.
- [x] **FREEZE REPAIR / RED PLAN** — Keep default and absolute destination behavior stable; make custom relative
  resolution and execution share the book root; add an argument-aware current-working-directory/output regression
  that fails before the wrapper change and passes afterward.
- [x] **VERIFY / COMMIT / CLEAN** — Synchronize task/index/roadmap/Knowledge/live continuity only, run focused
  task/memory/Knowledge/doctrine/whitespace checks, commit, clear the brief, and prove clean before `.1` code.

Activation and reproduction evidence 2026-08-01: `.14.2.0.1` landed at `bd777ee8` as 137/300 with no push. Exact
post-commit proof found empty status and staged/unstaged diffs, zero-byte `git_message_brief.txt`, activation pointer
`5a294f39` resolving to `HEAD^1`, synchronized Knowledge Map 785/6,375, no generated book or non-cache Python
bytecode, and no background result. During that leaf's rendered verification,
`bash tools/run_mdbook_local.sh --dest-dir ../../.linkedspec-data/scratch/mdbook-14-2-0-1` passed wrapper validation
as `docs/linkedspec-book/../../.linkedspec-data/...` on the repository volume, but the wrapper then ran mdBook from
the repository root. mdBook interpreted the same relative argument as `../../.linkedspec-data/...` from that root
and attempted the off-repository path before the sandbox denied it with `Operation not permitted`.

Root cause and frozen repair 2026-08-01: `run_mdbook_local.sh` deliberately resolves relative output validation
against `BOOK_ROOT`, then changes to `REPO_ROOT` and invokes `mdbook build docs/linkedspec-book "$@"`. Default
output is not forwarded as a CLI override, and absolute overrides have no relative base, so the defect is limited
to relative custom `--dest-dir` forms. The smallest repair is to invoke mdBook from `BOOK_ROOT` as `mdbook build .`
while preserving all arguments. This makes mdBook's relative CLI base identical to validation, keeps the default
book output and absolute destinations stable, and remains independent of caller CWD. The storage oracle must use
an argument-aware fake mdBook that asserts `BOOK_ROOT` CWD, resolves the passed relative destination itself, writes
inside its existing repository-managed case root, and proves the exact output. The test must fail against the
pre-fix wrapper before `.1` changes it.

- ID: `MDBOOK-DESTINATION-ROOT-ALIGNMENT.1`
  Status: `pending`
  Goal: Align mdBook execution with the validated book-root base and close the storage-safety regression.
  Depends on: `.0`
  Acceptance: First land/reproduce the argument-aware RED oracle; then run mdBook from `BOOK_ROOT` with `build .`,
    preserve default/absolute/env behavior, prove relative split/equals/compact forms resolve exactly inside the
    repository, reject symlink/external destinations before execution, update the canonical storage fact and live
    records, run focused storage/path/book/doctrine and canonical gates, commit, clear the brief, and prove clean
    before returning to `FUTURE-PARITY-BACKLOG.14.2.1.0`.

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `MDBOOK-DESTINATION-ROOT-ALIGNMENT.0` | `done` / signoff-complete | Root cause and exact RED/repair plan are durable. |
| 2 | `MDBOOK-DESTINATION-ROOT-ALIGNMENT.1` | `pending after clean .0 commit` | Repair and mechanically lock the one unsafe relative-override seam. |

## Decisions

- `2026-08-01`: Treat the mismatch as project-data safety, not the nonurgent prose-readability audit. A destination
  that validates under one base and executes under another violates same-volume policy even if the current sandbox
  happens to deny the attempted write.
- `2026-08-01`: Preserve the wrapper's existing book-root-relative contract by changing execution CWD/book operand;
  do not redefine relative overrides as repository-root-relative or require callers to supply absolute paths.

## Open Questions

- None. The reproduced paths and actual mdBook error identify both bases exactly.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-08-01` | `.0` | Clean activation; Knowledge/wrapper/oracle retrieval; exact failed relative build; source root-cause; KM 785/6,377; memory 55/60; task metadata; seven doctrines; whitespace. | PASS; signoff-complete, commit/clean proof pending. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `.0` | `MDBOOK-DESTINATION-ROOT-ALIGNMENT.0 - own mdbook destination root mismatch` | Tracking/root-cause only; no script or test change. |
| `.1` | pending | Wrapper, RED regression, storage fact, complete signoff, closeout. |

## Changelog

- `2026-08-01`: Created from the clean typed-source correction boundary after rendered verification exposed one
  validation/execution base mismatch. Repair is isolated before Perl typed-source RED work resumes.
