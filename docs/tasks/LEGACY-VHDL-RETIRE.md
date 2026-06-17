# LEGACY-VHDL-RETIRE: Retire the Perl-only legacy VHDL/RTL/FSM-generation subsystem

## Metadata

- Tree ID: `LEGACY-VHDL-RETIRE`
- Status: `active` (created 2026-06-18)
- Roadmap lane: `Overall roadmap — keep only portable/cross-variant code (retirement)`
- Created: `2026-06-18`
- Last updated: `2026-06-18` (`.1` read-only inventory done; removal leaves `.2`–`.5` blocked on
  user removal-scope confirmation)
- Owner: repo-local workflow

## Goal

Retire the self-contained, **Perl-only** legacy VHDL/RTL/FSM **generation** subsystem —
`perl/RTLUtils.pm`, `perl/FSMGen.pm`, `perl/VHDL/ConstantEval.pm` and the `plugin/*.plg`
files that exclusively depend on them — per the user doctrine [[feedback_keep-only-portable-cross-variant]]
(keep only code that can be ported / have a Rust/Julia/Dart variant; non-portable Perl-only
legacy is retirement debt, not something to fix).

Retiring this subsystem **also clears `RTLUTILS-REGEX-HANG`** — the catastrophic-backtracking
regex (`perl/RTLUtils.pm:746`) that hangs `t/phase0_regression.t` — which is the gate currently
blocking the `SPEC-FORMAT-TERSE` implementation leaves (`.1.x`+). Removing the code is strictly
better than patching a regex in a module that is being deleted anyway.

## Non-Goals

- **NOT** retiring the legacy `.plg` plugin corpus wholesale. Only the `.plg` files that
  functionally depend on the three retired modules are in scope here; the broader legacy `.plg`
  corpus (the 19 files kept by `PLUGIN-ACTION-MIGRATION`) is a separate decision.
- **NOT** removing the deterministic named-`.spec` resolution, the plugin *registry* surface, or
  `PPlugin`/`PluginBridge` transition machinery (separate `PLUGIN-MODERNIZATION` lineage).
- **NOT** touching the active `.spec` parser/compiler/runtime core — verified to have **zero**
  functional dependency on this subsystem.
- **NOT** the `andplusplus-lx-parser-hang` (a different, spec.spec self-parse hang).

## Acceptance Criteria

- The three modules + their exclusively-dependent `.plg` files + their phase0 migration-smoke
  test blocks are removed (scope confirmed by the user first).
- `t/phase0_regression.t` runs to completion (no hang) and the full local gate is green.
- The all-target ActionIR-ready invariant (ADR 0002) is unaffected (no shipped `.spec` touched).
- Live docs + the mdBook are re-synced (including the stale `generic_fake_memory_module.plg` /
  `wrapgen.plg` references); KM card written; committed per `COMMIT.md`.

## Task Tree

- ID: `LEGACY-VHDL-RETIRE`
  Status: `active`
  Goal: Retire the Perl-only legacy VHDL/RTL/FSM-generation subsystem; clear `RTLUTILS-REGEX-HANG`
  Children: `.1`, `.2`, `.3`, `.4`, `.5`

- ID: `LEGACY-VHDL-RETIRE.1`
  Status: `done`
  Goal: Read-only feasibility/inventory — map the full subsystem, every reference, the phase0
    smoke tests to remove, exact line counts, and the offending regex; confirm zero core
    dependency; propose the removal scope.
  Acceptance: A precise, verified inventory exists (below); a KM fact card records the durable
    structural facts; the removal scope is proposed for user confirmation. No deletion.
  Verification: Done — 2026-06-18. Full reference sweep (`git grep`) + module inspection; see
    Inventory + Verification Log. KM card [[rtlutils-regex-hang]] written. Self-check + KM gate
    pass. No engine/spec/test code changed (docs/task-tree/KM only) — phase0 gate N/A to `.1`
    (and `.1` is read-only; the suite still hangs until `.2`–`.4`).
  Commit: `LEGACY-VHDL-RETIRE.1` (see Commit Log)

- ID: `LEGACY-VHDL-RETIRE.2`
  Status: `blocked`
  Goal: Remove the exclusively-dependent `plugin/*.plg` files and their phase0 migration-smoke
    test blocks, so nothing calls the three modules anymore.
  Acceptance: `plugin/{fsmgen,lte_digital_rf,mbist,msword,regtest,rtl}.plg` deleted; the
    RTLUtils/FSMGen/VHDL::ConstantEval migration-smoke blocks in `t/phase0_regression.t` removed;
    `git grep` shows no remaining functional caller of the three modules.
  Verification: `pending`
  Commit: `pending`

- ID: `LEGACY-VHDL-RETIRE.3`
  Status: `blocked`
  Goal: Remove the three core modules and the dangling comment references.
  Acceptance: `perl/RTLUtils.pm`, `perl/FSMGen.pm`, `perl/VHDL/ConstantEval.pm` deleted; the
    stale comments at `perl/LinkedSpec.pm:246` and `tools/gen_oracle_corpus.pl:31` removed/updated.
  Verification: `pending`
  Commit: `pending`

- ID: `LEGACY-VHDL-RETIRE.4`
  Status: `blocked`
  Goal: Confirm the gate is unblocked — `t/phase0_regression.t` runs to completion (no hang),
    full local gate green.
  Acceptance: `perl -c perl/LinkedSpec.pm`; `prove -Iperl t/phase0_regression.t` completes within
    normal time; `bash tools/run_ci_local.sh` green.
  Verification: `pending`
  Commit: `pending`

- ID: `LEGACY-VHDL-RETIRE.5`
  Status: `blocked`
  Goal: Doc + book + KM sync — remove subsystem references and fix the pre-existing stale drift.
  Acceptance: `ROADMAP_V2.md`, `ARCHITECTURE_STATE.md` (owner tree + the stale
    `generic_fake_memory_module.plg` / `wrapgen.plg` `ceil_log2` prose), the mdBook
    (`specs-and-corpora/shipped-specs-and-corpora.md` package-owner list), and the KM card are
    re-synced; `SPEC-FORMAT-TERSE` blocker updated to "cleared".
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| — | `LEGACY-VHDL-RETIRE.1` | `done` | Read-only inventory complete (2026-06-18). |
| 🚧 | **REMOVAL-SCOPE CONFIRMATION PENDING (user)** | `blocked` | `.2`–`.5` are deletions. Per [[feedback_keep-only-portable-cross-variant]] + `MEMORY.md`, removal scope must be confirmed by the user before any file is deleted. Recommended scope = the full self-contained closure (3 modules + 6 dependent `.plg` + their phase0 smoke blocks ≈ 6,701 lines). |
| 1 | `LEGACY-VHDL-RETIRE.2` | `blocked` | Remove dependent `.plg` + their smoke tests. Unblock = user confirms scope. |
| 2 | `LEGACY-VHDL-RETIRE.3` | `blocked` | Remove the 3 core modules. Must follow `.2` (no dangling callers). |
| 3 | `LEGACY-VHDL-RETIRE.4` | `blocked` | Verify the phase0 hang is gone + full gate green. |
| 4 | `LEGACY-VHDL-RETIRE.5` | `blocked` | Doc/book/KM sync + flip `SPEC-FORMAT-TERSE` blocker. |

## Inventory (LEGACY-VHDL-RETIRE.1 deliverable — verified 2026-06-18)

### The subsystem (3 Perl-only modules — zero portable counterpart)

| Module | Path | Lines | Role | Key symbols |
| --- | --- | --- | --- | --- |
| RTLUtils | `perl/RTLUtils.pm` | 877 | RTL/VHDL emission + Verilog parsing helpers | `ceil_log2`, `add_header_n_context_clause`, `string_align`, `string_realign`, `drive_entity_component`, `_drive_instances` |
| FSMGen | `perl/FSMGen.pm` | 3,549 | FSM→VHDL generation; `AUTOLOAD`→PluginBridge | `getop_plugin_list`, `top_from_string`, `top_from_tree`, `fsm_initialize`, `synthetic_plugin` (test) |
| VHDL::ConstantEval | `perl/VHDL/ConstantEval.pm` | 90 | VHDL constant extraction/eval | `evaluate_constant_values`, `substitute_hash_values`, `print_constant_values_for_conf` |

Internal coupling: `FSMGen` `use RTLUtils` (≈30 RTLUtils calls); `VHDL::ConstantEval` `require RTLUtils`.

### `RTLUTILS-REGEX-HANG` (the gate blocker)

- Catastrophic-backtracking regex: `perl/RTLUtils.pm:746`
  - `/(\w+)(?=(?:\[.*?\])?\s*<=((?s).+?);)/go` — variable-width lookahead with dotall non-greedy
    `(?s).+?` → exponential backtracking on inputs lacking a matching `<= … ;`.
- Reached via `RTLUtils::drive_entity_component(...)` → `_drive_instances(...)`.
- Phase0 exercises `RTLUtils` in subprocess smoke blocks, incl. `drive_entity_component` at
  `t/phase0_regression.t:3540`. (Exact phase0 hang trigger not re-run here — the suite hangs;
  full subsystem removal eliminates the regex regardless of which call path triggers it.)
- Prior attribution named `add_header_n_context_clause`; the actual offending pattern is at
  line 746 (`_drive_instances`). Recorded for accuracy.

### Every reference (verified `git grep`, 2026-06-18)

- **Active `.spec` parser/compiler/runtime core: ZERO functional dependency.** Only external
  `perl/` reference is a **comment** (`perl/LinkedSpec.pm:246`). `tools/gen_oracle_corpus.pl:31`
  is also a **comment**.
- **Shipped `specs/*.spec`: ZERO.** `bin/`: ZERO.
- **Dependent `plugin/*.plg` (6, exclusively depend on the modules):**
  `fsmgen.plg` (464), `lte_digital_rf.plg` (43), `mbist.plg` (75), `msword.plg` (326),
  `regtest.plg` (345), `rtl.plg` (726) = **1,979 lines**.
- **`t/phase0_regression.t` migration-smoke blocks** (validate the *prior* plugin→package-owner
  migration of this code; obsolete once the code is gone): approx lines `3486–3691`, `3732–3742`,
  `3753–3758`, `3780–3809`, `5136–5150`, `5202–5247` (≈206 lines).

### Removal footprint (recommended scope = full self-contained closure)

| Bucket | Lines |
| --- | --- |
| 3 core modules | 4,516 |
| 6 dependent `.plg` | 1,979 |
| phase0 migration-smoke blocks | ≈206 |
| **Total** | **≈6,701** |

### Doc drift found (to fix in `.5`, not introduced by this tree)

- `ROADMAP_V2.md:157` and `ARCHITECTURE_STATE.md:588` describe `plugin/generic_fake_memory_module.plg`
  and `plugin/wrapgen.plg` as live `RTLUtils::ceil_log2(...)` callers. **Both files no longer
  exist**, and no `.plg` references `ceil_log2` at all anymore.

## Decisions

- `2026-06-18`: **Retire, do not fix.** Per [[feedback_keep-only-portable-cross-variant]] the
  subsystem is Perl-only non-portable legacy with no Rust/Julia/Dart counterpart and zero core
  dependency → retirement debt. Removing it clears `RTLUTILS-REGEX-HANG` and unblocks the
  `SPEC-FORMAT-TERSE` implementation gate, instead of patching a regex in soon-deleted code.
- `2026-06-18`: **Read-only inventory first; confirm removal scope before deleting** (recorded
  next action in `MEMORY.md`). `.1` is non-destructive; `.2`–`.5` stay `blocked` until the user
  confirms the scope.
- `2026-06-18`: **Recommended scope = full self-contained closure** (3 modules + 6 dependent
  `.plg` + their phase0 smoke blocks). Removing the modules without the `.plg` would leave
  dangling callers; removing the `.plg` smoke tests is correct because they only assert the
  migration shape of code being deleted.

## Open Questions

- **Removal scope (user, blocks `.2`+):** confirm the full self-contained closure (recommended)
  vs. a broader sweep of the rest of the RTL/VHDL-flavored legacy `.plg` corpus vs. a narrower cut.

## Blockers

- `.2`–`.5` are `blocked`. Blocker: **removal scope not yet confirmed by the user**; deletions are
  destructive and the doctrine + `MEMORY.md` require confirming scope first. Unblock condition:
  user confirms the removal scope. Next task if not unblocked: none in this tree — return to the
  `SPEC-FORMAT-TERSE` design conversation / other active trees.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-18` | `LEGACY-VHDL-RETIRE.1` | `git grep` reference sweep (modules + public symbols) across `perl/ plugin/ t/ tools/ bin/ specs/`; `wc -l` line counts; `RTLUtils.pm:746` regex inspection; existence check of doc-named `.plg` files; `scripts/check_memory_architecture.sh`; KM gate | Done — zero core functional dependency confirmed; 6 dependent `.plg` + ≈206 phase0 smoke lines catalogued; ≈6,701-line footprint; regex at line 746 confirmed; `generic_fake_memory_module.plg`/`wrapgen.plg` confirmed nonexistent (doc drift). Self-check + KM gate pass. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `LEGACY-VHDL-RETIRE.1` | `LEGACY-VHDL-RETIRE.1 — own retirement tree + read-only inventory of the Perl-only legacy VHDL/RTL/FSM subsystem` | Tree created `active`; KM card [[rtlutils-regex-hang]]; no engine/spec/test code changed; removal scope surfaced to user. |

## Changelog

- `2026-06-18`: Created tree; completed read-only feasibility/inventory leaf `.1`; removal leaves
  `.2`–`.5` blocked pending user removal-scope confirmation. Supersedes the earlier "fix
  `RTLUTILS-REGEX-HANG`" direction (now: retire the subsystem, which also clears the hang).
