# NONCORE-QUARANTINE: relocate non-core `.pm`/`.plg` to `noncore/` (parked; fate decided later)

## Metadata

- Tree ID: `NONCORE-QUARANTINE`
- Status: `active` (created 2026-06-19)
- Roadmap lane: `Overall roadmap — keep only portable/cross-variant code (non-core quarantine)`
- Created: `2026-06-19`
- Last updated: `2026-06-19` (`.1` inventory done; `.2` relocated the 12 zero-ref modules to `noncore/`)
- Owner: repo-local workflow

## Goal

Keep only what the **product** uses (`perl/LinkedSpec.pm` ∪ shipped `specs/*.spec` ∪
`conf/`+`ebnf/`+`tablescript/`). Everything proven unreachable — the legacy domain `.pm` island +
the `.plg` corpus — is **relocated (`git mv`) to `noncore/`**, NOT deleted: the boundary becomes
explicit ("provably not in the LinkedSpec tree → `git rm`-able anytime"), while preserving the option
to **refactor / port (Rust/Julia/Dart) / publish / delete** each on its own merits later
(see `noncore/README.md` — the parked fate ledger). Per [[feedback_keep-only-portable-cross-variant]].
Side effect: removing the relocated modules' phase0 smoke tests **greens the suite** (the back-half
hangs live in exactly those tests), unblocking `SPEC-FORMAT-TERSE` + the local CI gate + the ports.

## Non-Goals

- Deciding each module's fate now (the ledger parks that; default = undecided).
- Touching the `.spec` engine CORE (the 41-module keep closure).
- Deleting `specs/` / `conf/` / `ebnf/` / `tablescript/`.
- Retiring the plugin *machinery* now (POSTPONE — `.N`).

## Acceptance Criteria

- Every non-core `.pm` (36) + `.plg` (13) relocated to `noncore/` (incrementally; layout preserved).
- Their orphaned `t/phase0_regression.t` subtests removed; `t/phase0_regression.t` runs to completion
  green; `perl -c perl/LinkedSpec.pm` OK; all 20 shipped specs compile; `bash tools/run_ci_local.sh` green.
- `noncore/README.md` ledger complete; live docs + KM synced; `SPEC-FORMAT-TERSE` +
  `LEGACY-VHDL-RETIRE.4/.5` blockers cleared.

## Dependency-Tree Inventory (`.1` — verified 2026-06-19)

Roots, edges, and the full keep/ditch result are in the commit `DEADCODE-PRUNE.1`-superseded record
and `noncore/README.md`. Summary: **41 KEEP `.pm`** (the `LinkedSpec.pm` closure: facade/dispatch +
compile/runtime owners + ParserFactory/Resolver + RuleIR/EmitContext/HandlerVariantEmitter + the
20-module ActionIR sub-tree + `LinkedRE`/`PathSearch` + the plugin machinery reachable only via the
deprecated stubs). **36 NON-CORE `.pm`** + **13 `.plg`** relocate to `noncore/`. **Zero core→domain
edges** (verified). Method captured the dynamic edges (`get_parser`→spec via `PathSearch`,
`get_plugin`/AUTOLOAD→`.plg`, `.plg`→`.pm`), not just `use` — the `Lispish.pm`→`Lispish.spec` lesson.

## Task Tree

- ID: `NONCORE-QUARANTINE`  · Status: `active` · Children: `.1`(done) `.2`(done) `.3` `.4` `.N`(postpone) `.V`

- ID: `NONCORE-QUARANTINE.1` · Status: `done`
  Goal: Extract the full dependency tree; classify KEEP vs non-core. (Was `DEADCODE-PRUNE.1`.)
  Verification: Done 2026-06-19 — agent dependency map + `git grep` cross-checks (no core→Global ref;
    tools/bin clean; 12 zero-ref modules confirmed 0 refs repo-wide). 41 KEEP / 36 non-core; 13 `.plg`.
  Commit: `NONCORE-QUARANTINE.1` (with `.2`)

- ID: `NONCORE-QUARANTINE.2` · Status: `done`
  Goal: Create `noncore/` + the parked ledger; relocate the 12 zero-reference `.pm` (risk-free — 0
    refs anywhere, so no test/code/spec touched).
  Acceptance: `noncore/{AmbiTiming,EasyTk,EncounTiming,HDisplay,LibReader,MagmaTiming,PTiming,
    Reportiming,rvp,TkGui,XLSreader,PluginUtils}.pm` moved via `git mv`; `noncore/README.md` ledger;
    `perl -c perl/LinkedSpec.pm` OK; `git grep` still 0 refs.
  Verification: Done 2026-06-19 — 12 `git mv`s; core compiles; 0 refs. No test impact (the 12 have no
    test references). perl/ top-level `.pm` 28→16.
  Commit: `NONCORE-QUARANTINE.1` (with `.1`)

- ID: `NONCORE-QUARANTINE.3` · Status: `done`
  Goal: Relocate the 23 domain-island `.pm` to `noncore/` (layout preserved) + remove their
    `t/phase0_regression.t` subtests. (Done as ONE batch + one block-excision rather than per-cluster:
    the migration-smoke subtests cross-reference clusters, so a single move + contiguous-block excise
    is cleaner and the user chose "straight through".)
  Acceptance: 23 domain `.pm` `git mv`'d to `noncore/`; their subtests removed; `perl -c` OK.
  Verification: Done 2026-06-19 — `git mv` 23 domain `.pm`; the 37-subtest legacy-migration block
    (phase0 source lines 3312–5378, subtests `tablescript_http_exec…`→ just before `get_parser_normalizes…`)
    excised via guarded anchor-splice; `perl -c t/phase0_regression.t` OK; subtest count 996→959;
    `git grep`=0 island refs in tests; `perl -c perl/LinkedSpec.pm` OK; emptied `perl/` subdirs rmdir'd.
  Commit: `NONCORE-QUARANTINE.3+.4` (see Commit Log)

- ID: `NONCORE-QUARANTINE.4` · Status: `done`
  Goal: Relocate the 13 `.plg` to `noncore/plugin/` + remove their `.plg`-dependent phase0 subtests.
  Verification: Done 2026-06-19 — 13 `.plg` `git mv`'d to `noncore/plugin/`; the `.plg`-dependent
    subtests were within the same excised block; `plugin/` emptied + rmdir'd. (Landed with `.3`.)
  Commit: `NONCORE-QUARANTINE.3+.4` (with `.3`)

- ID: `NONCORE-QUARANTINE.N` · Status: `blocked` (POSTPONE — core-facade change)
  Goal: Decide the plugin machinery's fate — `PPlugin`/`PluginBridge`/`PluginRegistry` + the
    deprecated `LinkedSpec.pm` stubs + their subtests. ("AUTOLOAD feels too magical" — eventual
    relocate/retire from the core.)
  Verification: `pending`

- ID: `NONCORE-QUARANTINE.V` · Status: `blocked`
  Goal: Verify `t/phase0_regression.t` runs to completion green + full local gate; doc/book/KM sync;
    clear the `SPEC-FORMAT-TERSE` + `LEGACY-VHDL-RETIRE.4/.5` blockers.
  Blocker: phase0 now runs the back half (no hangs) but reveals **~173 PRE-EXISTING core-engine test
    failures** (see Back-Half Core Failures, below) — unrelated to this relocation; must be resolved
    (own a separate tree) before phase0 can be green.
  Verification: `pending`

## Back-Half Core Failures (discovered 2026-06-19 — NOT caused by this work)

Relocating the island + excising its subtests cleared the hangs, so phase0 now runs the long-dark
back half (subtests ~111+) for the first time — revealing **~173 real, deterministic core-engine
test failures**: structural/shape assertion mismatches (0 timeouts, 0 missing-module errors), e.g.
`or_plus_blind_call`: parser returns scalar `'1'` where the test expects an array-of-arrays.
Clustered: `method_like`×75, `named_mark`×25, `emit_context`×21, capture/mark/entry families.
**This work changed ZERO engine bytes** (only `git mv` of non-engine files + test-subtest removal +
docs), so the engine behaves identically to before — these failures are PRE-EXISTING, masked by the
original hang (which sat at subtest 110, so subtests 111+ never ran). Most likely **stale tests**
(written for evolved ActionIR/HandlerIR behavior, never re-run because of the hang) rather than 173
real regressions (the shipped specs + the front 100 subtests pass). **Decision needed** — own a new
tree to triage stale-vs-real and bring phase0 green. (Separately: external `bin/fsmgen` CPU
contention slows runs but is not the cause.)

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| — | `.1`, `.2`, `.3`, `.4` | `done` | Inventory + ALL non-core `.pm`/`.plg` relocated to `noncore/` + island subtests excised; `perl/` is core-only. |
| 🚧 | **BACK-HALF CORE FAILURES DECISION (user)** | `blocked` | ~173 pre-existing core-engine test failures revealed (NOT from this work). Triage stale-vs-real in a new tree before phase0 can be green. |
| 1 | `.N` | `blocked` | POSTPONE — plugin machinery + deprecated core stubs (facade change). |
| 2 | `.V` | `blocked` | Green phase0 + gate; blocked by the 173. |

## Decisions

- `2026-06-19`: **Relocate, don't delete (user).** `git mv` non-core to `noncore/` preserving layout;
  keeps refactor/port/publish/delete options open + reversible; makes the non-core boundary explicit.
  Repurposed from the delete-framed `DEADCODE-PRUNE` after the user's "move to a new tree, decide later"
  direction. Fate hints recorded in `noncore/README.md` (parked; non-binding).
- `2026-06-19`: Honest fate read (recorded as hints, not decisions): `revive-candidate` = `Lispish`,
  `LispML`, `LibReader`; `replaceable` = `HUtils`/`Table*`/`HTML`/`HTTP`/`Text`/`InteractivePrompt`/
  `Global`/`XLSreader`; `likely-rm` = vendor-timing/`Timing::*`/`QC::*`/`Tk*`/`HDisplay`/`MSOffice::Excel`/
  `TcFlow`/`rvp`/`PluginUtils` + all 13 `.plg`. The prize remains the Rust/Julia/Dart ports; no revival
  work invested now.
- `2026-06-19`: Plugin machinery stays in core for now (reachable via deprecated stubs) — `.N` postpone.

## Open Questions

- ~~`.3` pace~~ RESOLVED (user: "straight through"). Done as one batch + block-excision.
- **Back-half core failures (user decision — the immediate blocker):** ~173 pre-existing core-engine
  test failures (see the section above) now block green phase0. Triage stale-vs-real in a new tree?
  Scope? This is unrelated to the quarantine and is the next decision.
- Eventually drop `conf/`/`ebnf/`/`tablescript/` data once their consuming `.plg`/`.pm` are gone?
  (user: keep for now.)

## Blockers

- `.N` POSTPONED (core-facade). `.V` blocked by the **~173 pre-existing back-half core-engine test
  failures** (NOT from this relocation — engine bytes unchanged; masked by the original hang). Needs
  its own triage/fix tree before phase0 can be green.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-19` | `.1` | agent dep map + `git grep` cross-checks; self-check; KM gate | 41 KEEP / 36 non-core `.pm`; 13 `.plg`; zero core→domain edges |
| `2026-06-19` | `.2` | 12 `git mv`; `perl -c perl/LinkedSpec.pm` OK; `git grep` 0 refs to the 12 | Done — `noncore/` seeded; perl/ top-level `.pm` 28→16; no test impact |
| `2026-06-19` | `.3`+`.4` | 23 domain `.pm` + 13 `.plg` `git mv`'d; 37-subtest block excised (anchor-splice, guarded); `perl -c` core+test OK; `git grep`=0 island refs; emptied dirs rmdir'd; phase0 re-run | Done — `perl/` is core-only. **Discovered ~173 PRE-EXISTING back-half core failures** (structural mismatches; 0 timeouts/missing-module; engine bytes unchanged → not from this work). External `bin/fsmgen` CPU contention noted. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `.1`+`.2` | `NONCORE-QUARANTINE.1 — dependency inventory + create noncore/ + relocate 12 zero-ref modules (.1+.2)` | Read-only inventory + safe relocation; `noncore/README.md` ledger. |
| `.3`+`.4` | `NONCORE-QUARANTINE.3+.4 — relocate 23 domain .pm + 13 .plg to noncore/ + excise their 37 phase0 subtests` | `perl/` now core-only. Revealed ~173 pre-existing back-half core failures (separate tree to triage). |

## Changelog

- `2026-06-19` (`.3`+`.4`): Relocated ALL 23 remaining domain `.pm` + 13 `.plg` to `noncore/`
  (`git mv`, layout preserved) and excised the 37-subtest legacy-migration block from
  `t/phase0_regression.t` (source lines 3312–5378, anchor-splice). `perl/` is now core-only;
  `perl -c` core+test OK; emptied dirs rmdir'd. **Discovered ~173 pre-existing real core-engine test
  failures** in the now-runnable back half (`method_like`×75/`named_mark`×25/`emit_context`×21/…) —
  unrelated to this work (engine bytes unchanged), masked by the original hang. `.V`/green-phase0
  blocked on triaging them (new tree). External `bin/fsmgen` CPU contention also observed.
- `2026-06-19`: Created (repurposed from `DEADCODE-PRUNE` per the user's relocate-not-delete
  direction). `.1` inventory + `.2` 12 zero-ref modules → `noncore/` done.
