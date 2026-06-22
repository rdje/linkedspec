# LEGACY-VHDL-RETIRE: Retire the Perl-only legacy VHDL/RTL/FSM-generation subsystem

## Metadata

- Tree ID: `LEGACY-VHDL-RETIRE`
- Status: `active` (created 2026-06-18)
- Roadmap lane: `Overall roadmap — keep only portable/cross-variant code (retirement)`
- Created: `2026-06-18`
- Last updated: `2026-06-22` (`.4` **DONE** — RTLUtils hang cleared + full local gate green via
  `PHASE0-BACKHALF-TRIAGE`; `.5` blocker **cleared** (`pending`, executed cross-tree by
  `PHASE0-BACKHALF-TRIAGE.5.3.2.2`). Prior: `.1`/`.2`/`.3` done — subsystem retired, RTLUtils hang cleared.)
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
  Status: `done`
  Goal: Remove the exclusively-dependent `plugin/*.plg` files and their phase0 migration-smoke
    test blocks, so nothing calls the three modules anymore.
  Acceptance: `plugin/{fsmgen,lte_digital_rf,mbist,msword,regtest,rtl}.plg` deleted; the
    RTLUtils/FSMGen/VHDL::ConstantEval migration-smoke blocks in `t/phase0_regression.t` removed;
    `git grep` shows no remaining functional caller of the three modules.
  Verification: Done — 2026-06-18. 6 `.plg` removed via `git rm`; 8 module-smoke subtests deleted +
    7 mixed subtests surgically cleaned (plan counts adjusted); `git grep` = 0 module/`.plg`
    references in phase0; `perl -c` OK; the edited subtests all PASS in a live run (e.g.
    `http_file_access_logic_moves_into_domain_owner` ran `1..19` green). Landed with `.3`.
  Commit: `LEGACY-VHDL-RETIRE.2` (see Commit Log)

- ID: `LEGACY-VHDL-RETIRE.3`
  Status: `done`
  Goal: Remove the three core modules and the dangling comment references.
  Acceptance: `perl/RTLUtils.pm`, `perl/FSMGen.pm`, `perl/VHDL/ConstantEval.pm` deleted; the
    stale comments at `perl/LinkedSpec.pm:246` and `tools/gen_oracle_corpus.pl:31` removed/updated.
  Verification: Done — 2026-06-18. 3 modules removed via `git rm` (the now-empty `perl/VHDL/` is
    gone); the `LinkedSpec.pm:246` + `gen_oracle_corpus.pl:31` comments updated (no functional
    reference remains — only a deliberate historical comment); `perl -c perl/LinkedSpec.pm` OK;
    `perl -c t/phase0_regression.t` OK. Landed with `.2`.
  Commit: `LEGACY-VHDL-RETIRE.2` (landed with `.2`; see Commit Log)

- ID: `LEGACY-VHDL-RETIRE.4`
  Status: `done` (2026-06-22)
  Goal: Confirm the RTLUtils hang is cleared. (Originally "full phase0 green" — **REVISED**: the
    retirement clears the RTLUtils hang but does NOT make phase0 green; see Back-Half Discovery.)
  Acceptance: RTLUtils hang gone — **PROVEN 2026-06-18** (pristine HEAD hangs at subtest 110; the
    post-retirement suite runs past it). "Full local gate green" — the back-half hang/failures it
    unmasked were owned + resolved by `PHASE0-BACKHALF-TRIAGE`, so this is now also **MET**:
    `t/phase0_regression.t` is **960/960 GREEN** end-to-end and `bash tools/run_ci_local.sh` exits **0**.
    (The second hang `HTML::PathLinks::link_path_tokens` at subtest 131 became moot — its smoke subtest
    was excised when `NONCORE-QUARANTINE.3` relocated HTML::PathLinks to `noncore/`, so phase0 reaches
    green without an HTML::PathLinks fix.) **MET.**
  Verification: RTLUtils hang cleared (pristine-worktree comparison, 2026-06-18); full gate green via
    `PHASE0-BACKHALF-TRIAGE` (phase0 960/960; `tools/run_ci_local.sh` EXIT 0, recorded in `.5.4`/`.5.3.1`).
  Commit: `PHASE0-BACKHALF-TRIAGE.5.3.2.1` (cross-tree status reconciliation; this commit)

- ID: `LEGACY-VHDL-RETIRE.5`
  Status: `pending` (blocker CLEARED 2026-06-22; executed cross-tree by `PHASE0-BACKHALF-TRIAGE.5.3.2.2`)
  Goal: Doc + book + KM sync — remove subsystem references and fix the pre-existing stale drift.
  Acceptance: `ROADMAP_V2.md`, `ARCHITECTURE_STATE.md` (owner tree + the stale
    `generic_fake_memory_module.plg` / `wrapgen.plg` `ceil_log2` prose), the mdBook
    (`specs-and-corpora/shipped-specs-and-corpora.md` package-owner list + `architecture/owner-tree.md`),
    and the KM card are re-synced; `SPEC-FORMAT-TERSE` blocker updated to "cleared". (The
    `SPEC-FORMAT-TERSE` blocker flip + the KM-card status update landed in
    `PHASE0-BACKHALF-TRIAGE.5.3.2.1`; the remaining narrative-doc + book drift is `.5.3.2.2`.)
  Verification: `pending` (→ `PHASE0-BACKHALF-TRIAGE.5.3.2.2`)
  Commit: `pending` (→ `PHASE0-BACKHALF-TRIAGE.5.3.2.2`)

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| — | `LEGACY-VHDL-RETIRE.1` | `done` | Read-only inventory complete (2026-06-18). |
| — | `LEGACY-VHDL-RETIRE.2` | `done` | User confirmed scope (AskUserQuestion: "Full subsystem closure", 2026-06-18). 6 `.plg` + phase0 smoke removed. |
| — | `LEGACY-VHDL-RETIRE.3` | `done` | 3 modules + dangling comments removed (landed with `.2`). RTLUtils hang cleared (proven). |
| — | ~~BACK-HALF DECISION~~ | `resolved` 2026-06-22 | The back-half hang/failures the retirement unmasked were owned + resolved by `PHASE0-BACKHALF-TRIAGE` (phase0 **960/960 green** + full gate EXIT 0). The subtest-131 `HTML::PathLinks` hang became moot — its smoke was excised when `NONCORE-QUARANTINE.3` relocated the module to `noncore/`. |
| — | `LEGACY-VHDL-RETIRE.4` | `done` 2026-06-22 | RTLUtils hang cleared (proven 2026-06-18) **and** full local gate now green via `PHASE0-BACKHALF-TRIAGE` — flipped in `.5.3.2.1`. |
| 1 | `LEGACY-VHDL-RETIRE.5` | `pending` (blocker cleared) | Doc/book/KM sync. The `SPEC-FORMAT-TERSE` blocker flip + KM-card status landed in `PHASE0-BACKHALF-TRIAGE.5.3.2.1`; the remaining narrative-doc + book drift (`ROADMAP_V2`/`ARCHITECTURE_STATE` owner-tree + 2 mdBook files + `generic_fake_memory_module.plg`/`wrapgen.plg`) is executed in `.5.3.2.2`. |

## Inventory (LEGACY-VHDL-RETIRE.1 deliverable — verified 2026-06-18)

### The subsystem (3 Perl-only modules — zero portable counterpart)

| Module | Path | Lines | Role | Key symbols |
| --- | --- | --- | --- | --- |
| RTLUtils | `perl/RTLUtils.pm` | 877 | RTL/VHDL emission + Verilog parsing helpers | `ceil_log2`, `add_header_n_context_clause`, `string_align`, `string_realign`, `drive_entity_component`, `_drive_instances` |
| FSMGen | `perl/FSMGen.pm` | 3,549 | FSM→VHDL generation; `AUTOLOAD`→PluginBridge | `getop_plugin_list`, `top_from_string`, `top_from_tree`, `fsm_initialize`, `synthetic_plugin` (test) |
| VHDL::ConstantEval | `perl/VHDL/ConstantEval.pm` | 90 | VHDL constant extraction/eval | `evaluate_constant_values`, `substitute_hash_values`, `print_constant_values_for_conf` |

Internal coupling: `FSMGen` `use RTLUtils` (≈30 RTLUtils calls); `VHDL::ConstantEval` `require RTLUtils`.

### `RTLUTILS-REGEX-HANG` (corrected 2026-06-18 via pristine-HEAD worktree run)

- The hang is in **`RTLUtils::add_header_n_context_clause`**, not `_drive_instances`/line 746.
  Proven by running the pristine HEAD suite in a detached worktree: it completes subtest 109
  `rtlutils_drive_entity_component_uses_header_package_owner` (ok) and **hangs at subtest 110
  `rtlutils_header_context_clause_package_owner_preserves_payload`**.
- Root cause: that smoke test passes a **recursive** `add_package_re`
  (`([[:alpha:]]\w+)(?:\.((?1)))?$`), applied at **`perl/RTLUtils.pm:104`**
  (`map { m/$add_package_re/o } …`) — the `(?1)` recursion + `$` anchor backtracks catastrophically.
- **The `.1` "correction" to line 746 / `drive_entity_component` was WRONG**; the original MEMORY/ADR
  attribution (`add_header_n_context_clause`) was right. Recorded honestly. (Moot for the fix — the
  whole module is deleted — but recorded for accuracy.)

### Back-Half Discovery (2026-06-18 — a SECOND, pre-existing hang unmasked by the retirement)

Removing the RTLUtils hang (subtest 110) revealed that the **entire back half of phase0 (subtests
111+) had never executed** while the hang stood. That back half has its own pre-existing problems,
**unrelated to this subsystem**:

- **`HTML::PathLinks::link_path_tokens(...)` HANGS** (subtest 131
  `html_path_link_owner_avoids_pplugin_and_preserves_link_wrapping_contract`) — a separate
  catastrophic regex. `require HTML::PathLinks` / `require HTTP::FileAccess` load fine + fast; the
  **call** to `link_path_tokens` hangs (subprocess alarm-killed → that subtest fails 3/7).
  HTML::PathLinks depends only on **kept** modules (Global, HTTP::FileAccess,
  Text::VariableSubstitution) — so this is **not** caused by the retirement (proven: pristine HEAD
  never reaches subtest 111+).
- Consequence: **the retirement clears the RTLUtils hang but does NOT make phase0 green / usable.**
  The `SPEC-FORMAT-TERSE` gate stays blocked — now by the back-half hang(s)+failures, not RTLUtils.
  This needs its own fix track (Open Question → user decision).

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

- ~~Removal scope~~ **RESOLVED (user, 2026-06-18, AskUserQuestion):** "Full subsystem closure" —
  the 3 modules + 6 dependent `.plg` + their phase0 smoke blocks. Done in `.2`+`.3`.
- **Back-half fix track (user, blocks a green phase0 / the `SPEC-FORMAT-TERSE` gate):** clearing the
  RTLUtils hang unmasked a SECOND pre-existing hang (`HTML::PathLinks::link_path_tokens`, subtest
  131) + back-half failures (everything after subtest 110 was previously dark). How to proceed —
  own a new tree to investigate/fix the whole back half (likely several hangs/failures)? scope it?
  defer? This is the immediate decision surfaced to the user.

## Blockers

- `.1`/`.2`/`.3`/`.4` are `done`. The **RTLUtils hang is cleared** (proven). ~~`.4`/`.5` blocked by the
  back-half hang(s)+failures the retirement unmasked.~~ **CLEARED 2026-06-22.** The `PHASE0-BACKHALF-TRIAGE`
  tree owned + resolved the whole back half (the 173 + the corpus/dark-tail tail), and the subtest-131
  `HTML::PathLinks::link_path_tokens` hang became moot when `NONCORE-QUARANTINE.3` relocated the module to
  `noncore/` and excised its smoke subtest — so `t/phase0_regression.t` is now **960/960 GREEN** end-to-end
  and `bash tools/run_ci_local.sh` exits **0**. `.4` is now `done`; `.5` is `pending` and executed
  cross-tree by `PHASE0-BACKHALF-TRIAGE.5.3.2.2` (the narrative-doc + book drift sync).

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-18` | `LEGACY-VHDL-RETIRE.1` | `git grep` reference sweep (modules + public symbols); `wc -l` counts; existence check of doc-named `.plg`; `scripts/check_memory_architecture.sh`; KM gate | Done — zero core functional dependency; 6 dependent `.plg` + ≈206 phase0 smoke lines; ≈6,701-line footprint; `generic_fake_memory_module.plg`/`wrapgen.plg` confirmed nonexistent (doc drift). NOTE: `.1`'s "regex at line 746" claim was later **corrected** in `.2`/`.3` (the hang is in `add_header_n_context_clause`, RTLUtils.pm:104). Self-check + KM gate pass. |
| `2026-06-18` | `LEGACY-VHDL-RETIRE.2`+`.3` | `git rm` 6 `.plg` + 3 modules; surgical phase0 edits; `git grep`=0 refs; `perl -c` core + phase0 OK; **pristine-HEAD worktree run** (proves original hangs at subtest 110; post-retirement runs past to 130+); direct `link_path_tokens` timing | Done — RTLUtils hang cleared. **Discovered** a second pre-existing back-half hang (`HTML::PathLinks::link_path_tokens`, subtest 131) + back-half failures — unrelated to the retirement (proven). Hang attribution corrected. |
| `2026-06-22` | `LEGACY-VHDL-RETIRE.4` | RTLUtils hang cleared (2026-06-18 pristine-worktree proof) + full local gate green via `PHASE0-BACKHALF-TRIAGE` (phase0 960/960; `bash tools/run_ci_local.sh` EXIT 0). subtest-131 `HTML::PathLinks` hang moot (smoke excised by `NONCORE-QUARANTINE.3`) | Done — `.4` flipped to `done`; `.5` blocker cleared (`pending`, → `PHASE0-BACKHALF-TRIAGE.5.3.2.2`). Doc-only status reconciliation (`PHASE0-BACKHALF-TRIAGE.5.3.2.1`). |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `LEGACY-VHDL-RETIRE.1` | `LEGACY-VHDL-RETIRE.1 — own retirement tree + read-only inventory of the Perl-only legacy VHDL/RTL/FSM subsystem` | Tree created `active`; KM card [[rtlutils-regex-hang]]; no engine/spec/test code changed; removal scope surfaced to user. |
| `LEGACY-VHDL-RETIRE.2`+`.3` | `LEGACY-VHDL-RETIRE.2+.3 — retire the Perl-only legacy VHDL/RTL/FSM subsystem (3 modules + 6 .plg + phase0 smoke)` | User-confirmed "Full subsystem closure". RTLUtils hang cleared; back-half pre-existing hang/failures discovered + surfaced. |
| `LEGACY-VHDL-RETIRE.4` | `PHASE0-BACKHALF-TRIAGE.5.3.2.1 — status & continuity reconciliation` (cross-tree) | RTLUtils hang cleared + full gate green (phase0 960/960; `tools/run_ci_local.sh` EXIT 0). `.4`→`done`; `.5` blocker cleared. |

## Changelog

- `2026-06-22` (`.4` done; `.5` blocker cleared): The back-half hang/failures that reblocked `.4`/`.5` were
  owned + resolved by `PHASE0-BACKHALF-TRIAGE` — `t/phase0_regression.t` is **960/960 green** end-to-end and
  `bash tools/run_ci_local.sh` exits **0**. The subtest-131 `HTML::PathLinks::link_path_tokens` hang became
  moot when `NONCORE-QUARANTINE.3` relocated the module to `noncore/` and excised its smoke. `.4` flipped
  `blocked`→`done` (RTLUtils hang cleared + full gate green); `.5` flipped `blocked`→`pending` (its doc/book/KM
  drift sync — `ROADMAP_V2`/`ARCHITECTURE_STATE` owner-tree + 2 mdBook files + the
  `generic_fake_memory_module.plg`/`wrapgen.plg`/`ceil_log2` drift — is executed cross-tree in
  `PHASE0-BACKHALF-TRIAGE.5.3.2.2`). Doc-only status reconciliation in `PHASE0-BACKHALF-TRIAGE.5.3.2.1`; no
  code/spec/test change.
- `2026-06-18` (`.2`+`.3` landed): User confirmed "Full subsystem closure" (AskUserQuestion).
  Retired the subsystem — `git rm` 3 modules (`RTLUtils.pm`/`FSMGen.pm`/`VHDL/ConstantEval.pm`) + 6
  dependent `.plg`; surgically cleaned the phase0 migration-smoke (8 whole-subtest deletes + 7 mixed
  subtests cleaned). **Proved via a pristine-HEAD worktree** that the original hang is at subtest
  110 (`add_header_n_context_clause`, recursive `add_package_re` at `RTLUtils.pm:104`) — **correcting
  `.1`'s wrong "line 746/`drive_entity_component`" claim**. **Discovered** a SECOND pre-existing,
  unrelated hang unmasked by removing the first: `HTML::PathLinks::link_path_tokens` (subtest 131) +
  back-half failures (the back half had been dark behind the RTLUtils hang). RTLUtils hang cleared;
  phase0 still not green → `.4`/`.5` reblocked on a back-half fix track; surfaced to the user.
- `2026-06-18`: Created tree; completed read-only feasibility/inventory leaf `.1`; removal leaves
  `.2`–`.5` blocked pending user removal-scope confirmation. Supersedes the earlier "fix
  `RTLUTILS-REGEX-HANG`" direction (now: retire the subsystem, which also clears the hang).
