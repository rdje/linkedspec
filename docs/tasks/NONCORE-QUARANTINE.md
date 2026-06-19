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

- ID: `NONCORE-QUARANTINE.3` · Status: `pending`
  Goal: Relocate the 24 domain-island `.pm` to `noncore/` (layout preserved) + remove their
    `t/phase0_regression.t` subtests, **one coherent cluster per slice**: Timing (`Timing::*`),
    QC (`QC::*`), Table (`Table*`/`HUtils`/`TableGrep`/`TcFlow`), Web/Text (`HTML::PathLinks`/
    `HTTP::FileAccess`/`Text::VariableSubstitution`/`HLinkSubst`), MSOffice (`MSOffice::Excel`),
    Lisp (`Lispish`/`LispML`), misc (`Global`/`InteractivePrompt`).
  Acceptance per cluster: cluster `.pm` `git mv`'d; their subtests removed; `perl -c` OK; specs
    compile; phase0's stall point advances. Clears the back-half hangs cluster by cluster.
  Verification: `pending`
  Commit: `pending`

- ID: `NONCORE-QUARANTINE.4` · Status: `pending`
  Goal: Relocate the 13 `.plg` to `noncore/plugin/` + remove the `.plg`-discovery/parse phase0
    subtests (`pplugin_*` corpus/readdir, `*_still_parse_under_pplugin`, etc.) that depend on `.plg`
    living in `plugin/`. (Keep the machinery subtests that don't depend on a relocated `.plg`.)
  Verification: `pending`
  Commit: `pending`

- ID: `NONCORE-QUARANTINE.N` · Status: `blocked` (POSTPONE — core-facade change)
  Goal: Decide the plugin machinery's fate — `PPlugin`/`PluginBridge`/`PluginRegistry` + the
    deprecated `LinkedSpec.pm` stubs + their subtests. ("AUTOLOAD feels too magical" — eventual
    relocate/retire from the core.)
  Verification: `pending`

- ID: `NONCORE-QUARANTINE.V` · Status: `pending`
  Goal: Verify `t/phase0_regression.t` runs to completion green + full local gate; doc/book/KM sync;
    clear the `SPEC-FORMAT-TERSE` + `LEGACY-VHDL-RETIRE.4/.5` blockers.
  Verification: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| — | `.1`, `.2` | `done` | Inventory + `noncore/` + 12 zero-ref modules relocated (risk-free). |
| 1 | `.3` (per cluster) | `pending` | Relocate domain clusters + drop their phase0 subtests; clears the hangs incrementally. |
| 2 | `.4` | `pending` | Relocate the 13 `.plg` + drop their `.plg`-dependent subtests. |
| 3 | `.N` | `blocked` | POSTPONE — plugin machinery + deprecated core stubs (facade change). |
| 4 | `.V` | `pending` | Verify green phase0 + gate; clear blockers. |

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

- `.3` pace — straight through the clusters, or check in per cluster? (default: straight through,
  verifying phase0 advances each time.)
- Eventually drop `conf/`/`ebnf/`/`tablescript/` data once their consuming `.plg`/`.pm` are gone?
  (user: keep for now.)

## Blockers

- `.N` POSTPONED (core-facade). `.V` blocked until `.3`+`.4` land (phase0 can't be green until the
  non-core subtests are gone).

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-19` | `.1` | agent dep map + `git grep` cross-checks; self-check; KM gate | 41 KEEP / 36 non-core `.pm`; 13 `.plg`; zero core→domain edges |
| `2026-06-19` | `.2` | 12 `git mv`; `perl -c perl/LinkedSpec.pm` OK; `git grep` 0 refs to the 12 | Done — `noncore/` seeded; perl/ top-level `.pm` 28→16; no test impact |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `.1`+`.2` | `NONCORE-QUARANTINE.1 — dependency inventory + create noncore/ + relocate 12 zero-ref modules (.1+.2)` | Read-only inventory + safe relocation; `noncore/README.md` ledger. |

## Changelog

- `2026-06-19`: Created (repurposed from `DEADCODE-PRUNE` per the user's relocate-not-delete
  direction). `.1` inventory + `.2` 12 zero-ref modules → `noncore/` done. Clusters (`.3`) + `.plg`
  (`.4`) next; machinery (`.N`) postponed.
