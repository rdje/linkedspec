# SCALAREF-RETIREMENT: Retire Legacy `scalaref(...)` Access

## Metadata

- Tree ID: `SCALAREF-RETIREMENT`
- Status: `active`
- Roadmap lane: `Overall roadmap — .spec language evolution / compatibility retirement`
- Created: `2026-07-02`
- Last updated: `2026-07-02` (`.1` done — user directive owned and split; frontier -> `.2`)
- Owner: repo-local workflow

## Goal

Retire and remove the legacy `scalaref(...)` helper surface from the public DSL and implementation, replacing it
with canonical direct nested access and the eventual non-Perl-shaped hash/object literal surface.

## Non-Goals

- Do not undo `RUST-PARITY.7.5.2`; that slice restored Rust parity for the existing shipped Lispish surface.
- Do not remove `scalaref(...)` before shipped specs, oracle fixtures, tests, and docs have a canonical replacement.
- Do not silently preserve `scalaref(...)` as a hidden compatibility helper after the removal leaf lands.
- Do not broaden the removal to unrelated helper families unless the inventory proves they are the same surface.

## Acceptance Criteria

- Every live `scalaref(...)` use in shipped specs, tests, docs, and Rust/Perl implementation code is inventoried.
- A canonical replacement is selected and documented before code removal.
- Shipped specs and corpus fixtures no longer require `scalaref(...)`.
- Perl and Rust reject or no longer recognize `scalaref(...)` consistently after the removal leaf.
- The mdBook no longer teaches `scalaref(...)` as a user-facing helper.
- Knowledge Map and live docs record the replacement contract and removal evidence.
- Focused tests plus the broader gates pass.
- Each completed leaf is committed through `COMMIT.md`.

## Task Tree

- ID: `SCALAREF-RETIREMENT`
  Status: `active`
  Goal: Retire and remove the legacy `scalaref(...)` access helper.
  Children: `.1`, `.2`, `.3`, `.4`, `.5`

- ID: `SCALAREF-RETIREMENT.1`
  Status: `done`
  Goal: Own the 2026-07-02 user directive that `scalaref(...)` shall be retired/removed, and split the retirement migration before any behavior change.
  Acceptance: This task tree exists, `docs/TASK_TREE.md` links it, roadmap/live docs record the directive, and the next executable leaf is an inventory/design pass.
  Verification: Done — 2026-07-02. Created this tree after `RUST-PARITY.7.5.2` restored Rust parity for the existing shipped Lispish surface. The removal is explicitly split so no code/spec/book behavior changes happen without a dedicated owner.
  Commit: `SCALAREF-RETIREMENT.1 - own scalaref retirement track` (see Commit Log)

- ID: `SCALAREF-RETIREMENT.2`
  Status: `pending`
  Goal: Inventory all `scalaref(...)` use and select the canonical replacement contract.
  Acceptance: Grep/code-search inventory covers `specs/`, `perl/`, `rust/`, `t/`, `docs/`, oracle fixtures, and generated/reference docs; every live use is classified as shipped-spec behavior, test-only lock, implementation support, or historical prose. The replacement contract states when direct nested access is sufficient and what remains blocked by hash/object literal spelling.
  Verification: `pending`
  Commit: `pending`

- ID: `SCALAREF-RETIREMENT.3`
  Status: `pending`
  Goal: Migrate shipped specs, tests, oracle fixtures, and public docs away from `scalaref(...)`.
  Acceptance: No shipped spec or public book example requires `scalaref(...)`; Lispish and every migrated fixture still produce the same reference output through the canonical replacement; docs call `scalaref(...)` retired/removal-bound rather than supported.
  Verification: `pending`
  Commit: `pending`

- ID: `SCALAREF-RETIREMENT.4`
  Status: `pending`
  Goal: Remove `scalaref(...)` recognition/execution from Perl and Rust.
  Acceptance: Perl lowering/scanner contracts and Rust parser/runtime no longer accept `scalaref(...)` as a supported helper; unsupported uses fail consistently with the current diagnostic policy; focused negative tests lock the rejection; migrated positive tests stay green.
  Verification: `pending`
  Commit: `pending`

- ID: `SCALAREF-RETIREMENT.5`
  Status: `pending`
  Goal: Final drift sweep and close-out.
  Acceptance: No stale `scalaref(...)` support claims remain outside historical logs; Knowledge Map points to the replacement/removal contract; mdBook, roadmap, live docs, and task-tree status agree; full local gate passes; tree closes.
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| — | `SCALAREF-RETIREMENT.1` | `done` | Directive owned and split before behavior changes. |
| 1 | `SCALAREF-RETIREMENT.2` | `pending` | Need exact use inventory and replacement contract before touching specs, docs, or implementations. |
| 2 | `SCALAREF-RETIREMENT.3` | `pending` | Migrate live specs/tests/docs after the replacement contract is known. |
| 3 | `SCALAREF-RETIREMENT.4` | `pending` | Remove implementation support after live users are migrated. |
| 4 | `SCALAREF-RETIREMENT.5` | `pending` | Final no-drift sweep and tree close. |

## Decisions

- `2026-07-02`: User directive accepted: `scalaref(...)` shall be retired and removed. The directive is split into this tree rather than folded into `RUST-PARITY.7.5.2` because `.7.5.2` is a parity fix for the current shipped surface, while retirement changes the language contract.
- `2026-07-02`: Replacement is expected to be direct nested access plus the future non-Perl-shaped hash/object literal surface, but `.2` must prove the exact contract from current uses before code changes.

## Open Questions

- Does `scalaref(...)` have any remaining use that direct nested access cannot express without first changing hash/object literal syntax?
- Should unsupported `scalaref(...)` produce a dedicated retirement diagnostic or fall through to the existing unknown-helper path?

## Blockers

- None for `.2`; behavior changes are blocked until `.2` completes.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-02` | `SCALAREF-RETIREMENT.1` | Task-tree/index/roadmap/live-doc/KM tracking only; Knowledge Map regeneration/check, memory architecture, doctrine registry, mdBook build, `git diff --check` | Directive owned; no behavior change |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `SCALAREF-RETIREMENT.1` | `SCALAREF-RETIREMENT.1 - own scalaref retirement track` | Tracking-only split; next executable leaf is `.2` inventory/design. |

## Changelog

- `2026-07-02`: Created tree from user directive that `scalaref(...)` shall be retired and removed.
