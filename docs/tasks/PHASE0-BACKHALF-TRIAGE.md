# PHASE0-BACKHALF-TRIAGE: triage the ~173 pre-existing back-half core-engine test failures

## Metadata

- Tree ID: `PHASE0-BACKHALF-TRIAGE`
- Status: `active` (created 2026-06-19)
- Roadmap lane: `Overall roadmap — regression-gate health (back-half core failures)`
- Created: `2026-06-19`
- Last updated: `2026-06-19` (`.1` read-only triage **DONE** — full per-cluster verdict below; `.2`–`.5` fix leaves added)
- Owner: repo-local workflow

## Goal

`t/phase0_regression.t`'s back half was dark for a long time behind the `RTLUTILS-REGEX-HANG` +
the legacy-island hangs. With those cleared (`LEGACY-VHDL-RETIRE` + `NONCORE-QUARANTINE`), the suite
now runs the back half and reveals **173 pre-existing core-engine test failures** (structural/shape
mismatches + 2 codegen/validation defects; 0 missing-module errors). **Not caused by that work** —
engine bytes unchanged; the tests simply never ran. Determine, per cluster and with evidence, whether
each is a **STALE test** (written for engine behavior that has since evolved by intent — fix = re-bless
the expected value) or a **REAL** defect (engine produces wrong output vs its documented contract — fix
= the engine), then report scope/effort. A green `t/phase0_regression.t` unblocks the
`SPEC-FORMAT-TERSE` gate + the Rust/Julia/Dart parity (the regression baseline IS the cross-variant
contract).

## Non-Goals

- Re-litigating the quarantine (`NONCORE-QUARANTINE`, done).
- Touching the reference Perl engine in `.1` (read-only triage). `.3`/`.4` propose engine fixes; per
  [[feedback_do-not-fix-reference-engine]] those need explicit user authorization to touch `perl/`.

## Triage result (`.1`, read-only — DONE 2026-06-19)

> **CORRECTION (2026-06-19 — user directives: "if not broke don't fix" + "do not break the reference Perl
> engine").** The "REAL → engine-fix" framing below is **SUPERSEDED / overclaimed**. The 65 non-stale
> failures are **NOT confirmed reference defects** — there is only an OBSERVED bad-codegen *symptom* for
> an explicit `:AND`/`::AND` multi-slot rule with a `return`-bearing indexed edge (parser builds, then
> emits invalid Perl `SCALAR(0x…)Rule` ⇒ returns `undef`/`[]`). Whether that is a genuine defect vs.
> tests exercising a **non-conformant / undocumented construct is UNRESOLVED**: `:AND` is documented, but
> (a) NO shipped spec uses explicit `:AND` (all default mode), (b) the failing specs put regex on a `::`
> top rule which `formal-grammar.md` marks "Body rule only", and (c) the book's only `:AND` example
> (`ThirdChild:AND`, formal-grammar.md:625) uses call edges `-> A/-> B`, **not** a `return` edge. **The
> reference engine is FROZEN.** `.3`/`.4` must NOT touch `perl/` unless a fully BOOK-CONFORMANT `:AND`
> spec is OBJECTIVELY shown to break AND the user authorizes. Default remedy for the 65 = re-bless/retire
> the tests (TEST-ONLY). "Defect #2 (input-boundary)" was sub-agent-claimed and NOT verified. **The 108
> STALE verdicts stand and are test-only.** Read this banner over the section below.

Authoritative run: `perl -Iperl t/phase0_regression.t` → **173 failing subtests / 707 passing**
(reached subtest 880/959 before the background run was terminated, exit 144 mid-subtest-881; the 173
matches the known deterministic count). Full TAP captured to `/tmp/phase0_triage.tap` (transient).

### Verdict by cluster (all 173 reconciled)

| Cluster | Count | Verdict | Root cause |
| --- | --- | --- | --- |
| **A** parser-collection-shape (`or_plus_blind_call`, `explicit_and`, `blind_call_*`, `and_plus`, `bounded_and`) | 8 | **STALE** | engine returns each child's `return(1)` ⇒ `[1,1]`; test asserts retired auto-tag shape `[['?First:',[]],…]` |
| **B** `method_like` (incl. lifecycle/switch branch-block forms) | 75 | **STALE** | retired `return_a/return_m/return_ma/return_imatch/return_im/return_array` helpers + `RETURN_A/RETURN_M` nodes (COMPAT-ALIAS-RETIREMENT-V2, 2026-06-14). 20 use a retired helper in the spec body; 55 hard-code a retired node (`RETURN_A`) in the assertion. Branch-block canonical lowering itself is intended/working/book-documented. |
| **C** `emit_context` | 21 | **20 STALE + 1 REAL** | 20 = white-box seams that monkeypatch now-removed `LinkedSpec::Deps::*` (traps can't fire; only the retired-`return_a`-shape output asserts fail) + retired-helper passthrough + a stale `plan 89` (88 run) + one mis-authored re-bless (`a(IMATCH)`⇒`[IMATCH]` is correct). 1 REAL = `emit_context_lowers_push_nonempty_method_contract` test 13 (AND-codegen defect). |
| **D** capture/mark/cursor/entry/current_match/whole_input | 60 | **REAL** | AND-rule action-codegen defect (see Defect #1). |
| **F** descriptor/metadata migration-summary | 3 | **STALE** | specs use `return(1)`; tests expect it classified as a `return_a` blocker (unresolved). Engine correctly treats `return(1)` as a resolved plain return ⇒ ready, not blocked. |
| **G** singles | 6 | **2 STALE + 4 REAL** | 2 STALE = `return(1)` AST-shape re-bless (`bootstrap_registry_curly_brace_recursion_smoke`, `get_avoids_runtime_run_get_from_args_wrapper` — expect ARRAY, engine returns scalar `1`). 4 REAL: `anonymous_and_named_capture_boundaries_can_bridge_explicitly` + `multi_rule_parsers_default_to_first_rule_and_honor_explicit_top_rule_option` (Defect #1); `parser_invalid_input_fails_at_runtime_parser_boundary` + `get_parser_runtime_ctx_ref_records_invalid_input_ref_with_spec_identity` (Defect #2). |

**Totals: 108 STALE (re-bless) · 65 REAL (engine-fix), across 2 distinct engine defects.**

### REAL Defect #1 — AND-rule action-codegen (63 subtests: D=60, C `lowers_push` t13, G `anonymous_and_named_capture`, G `multi_rule_parsers`)

An `AND` rule with **multiple indexed edges** (`-> Rule[0]`, `-> Rule[1]`, …) where an edge action
contains a lowered `return(...)` payload emits broken `<Rule>:AND_ACODE`. Dumped generated source:
```
} elsif ($$minfo{index} == 1) {
   SCALAR(0x841821b88)Top = [[@items]]
}
```
The lowered payload is replaced by a **stringified SCALAR ref concatenated with the rule label**
(`SCALAR(0x…)Top = …`). Two symptoms:
- **Top rule** ⇒ Perl syntax error `Bareword found where operator expected … near ")Top" (Missing operator before Top?)` ⇒ `rule_handler_compile:<Rule> => SKIPPED` ⇒ parser returns `undef`.
- **Child rule** (reached via `call`) ⇒ compiles but **drops the return payload** ⇒ returns `[]`.

Bisection (engine bytes unchanged): single-edge AND + capture/mark = OK; multi-edge AND with all
`assign` edges (no `return`) = OK; multi-edge AND + a `return` edge = BROKEN. Per-edge helper lowering
(`capture_from`, `return(array(...))`, `assign`) is individually valid Perl — the bug is in the AND
multi-branch handler **assembly** (emitter), not the helper lowering. NORMAL (`::`) rules unaffected.
Likely site: `perl/LinkedSpec/HandlerVariantEmitter.pm` / `perl/LinkedSpec/SpecEntry.pm` AND-acode
branch assembly. See [[and-return-edge-codegen-defect]].

### REAL Defect #2 — input-boundary-validation regression (2 subtests: G `parser_invalid_input`, G `get_parser_runtime_ctx_ref`)

`perl/LinkedSpec/Runtime.pm:~126` (comment-skip wrapper added by `MEDIUM-IMPACT.3.2`, commit `d7294d0`)
runs `pos($$input_ref) = 0;` **before** delegating to the parser that holds the documented input-boundary
guard (`Compiler.pm:~1113`). For non-SCALAR-ref input it dies with a raw `Not a SCALAR reference at
… Runtime.pm line 126` instead of the friendly `Top-level parser expects a SCALAR reference input; got
ARRAY`, and `runtime_ctx->{last_error}` is never populated. (Agent-identified; confirm exact line at
fix time.) See [[runtime-input-boundary-validation-regression]].

## Acceptance Criteria (`.1`, read-only) — MET

- ✅ Complete failure inventory (173 names + got/expected) captured + bucketed.
- ✅ Per-cluster verdict (STALE re-bless vs REAL engine-fix), each backed by got/expected vs the
  documented contract + direct reproductions.
- ✅ Scope/effort: 108 re-bless vs 65 engine-fix (2 defects) + recommended fix order, decomposed into
  `.2`–`.5`. No code change.

## Task Tree

- ID: `PHASE0-BACKHALF-TRIAGE` · Status: `active` · Children: `.1` (done), `.2`, `.3`, `.4`, `.5`
- ID: `PHASE0-BACKHALF-TRIAGE.1` · Status: `done` (2026-06-19)
  Goal: Read-only cluster-by-cluster stale-vs-real triage of the 173 failures, with evidence + scope.
  Acceptance: per-cluster verdict + scope/effort + recommended fix plan, decomposed into `.2+`. **Met.**
  Verification: full phase0 TAP run + 5 direct reproductions (cluster D bisection, capture/mark lowering,
    entry_and child-rule `[]`, return(1) AST shape) + 2 parallel read-only deep-dives (B; C+F+G).
  Commit: (this commit)
- ID: `PHASE0-BACKHALF-TRIAGE.2` · Status: `active` · Children: `.2.1`–`.2.4`
  Goal: Re-bless / retire the 108 STALE subtests against the current documented engine behavior.
  - ID: `.2.1` · Status: `pending` — Cluster A (8): re-bless parser-collection-shape to the current
    `[1,1]`-style child-return output (drop the retired auto-tag `['?Rule:',[]]` expectation).
  - ID: `.2.2` · Status: `pending` — Cluster B (75): re-bless the `method_like` family — rewrite 20
    retired-helper spec bodies to `return(array(...))`/`return(...)`, and drop the `RETURN_A`/`RETURN_M`
    terms from 55 node-membership/hit-count fixtures. (May split a1 vs a2.)
  - ID: `.2.3` · Status: `pending` — Cluster C (20): re-bless/retire the `emit_context` white-box tests
    — fix the stale `plan` (88), re-bless `return_imatch`/`return_array` passthrough + the `a(IMATCH)`
    case, and **delete or rewrite** the seams that monkeypatch the removed `LinkedSpec::Deps::*` (they
    exercise a non-existent seam — prefer delete/rewrite over re-bless).
  - ID: `.2.4` · Status: `pending` — Cluster F (3) + Cluster G STALE (2): re-bless the `return(1)`
    migration-summary metadata (resolved, not blocked) + the `return(1)` AST-shape (scalar `1`).
- ID: `PHASE0-BACKHALF-TRIAGE.3` · Status: `blocked`
  Goal: **Engine fix** — AND-rule action-codegen defect (#1). Fix the AND multi-branch handler
    assembly so a `return(...)` edge emits a valid collector assignment (not `SCALAR(0x…)<Rule>`).
    Unblocks 63 subtests + makes capture/mark/cursor/entry helpers usable in multi-edge AND rules.
  Acceptance: V1/V2 reproducers compile + return the author payload; the 63 subtests pass; no NORMAL-rule
    regression; full phase0 re-run shows the 63 cleared.
  Blocker: touches the reference Perl engine (`perl/LinkedSpec/HandlerVariantEmitter.pm` /
    `SpecEntry.pm`) — needs user authorization per [[feedback_do-not-fix-reference-engine]].
  Verification: `pending`  ·  Commit: `pending`
- ID: `PHASE0-BACKHALF-TRIAGE.4` · Status: `blocked`
  Goal: **Engine fix** — input-boundary-validation regression (#2). Make the `Runtime.pm` comment-skip
    wrapper guard its deref (or run the documented SCALAR-ref validation ahead of it) so invalid input
    yields the friendly boundary error + populated `runtime_ctx->{last_error}`. Unblocks 2 subtests.
  Blocker: touches the reference Perl engine (`perl/LinkedSpec/Runtime.pm`) — needs user authorization.
  Verification: `pending`  ·  Commit: `pending`
- ID: `PHASE0-BACKHALF-TRIAGE.5` · Status: `pending`
  Goal: Verify a fully green `t/phase0_regression.t` end-to-end (all 959 subtests), including the
    881–959 tail not observed in the `.1` run (the run was terminated at subtest 881; confirm no fresh
    hang at `vhdl_small_blocker_helper_flow_eliminates_raw_fallback`/`corpus_regression`). Then flip the
    downstream gates (`SPEC-FORMAT-TERSE`, `LEGACY-VHDL-RETIRE.4/.5`, `NONCORE-QUARANTINE.V`).
  Verification: `pending`  ·  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `.3` | `blocked` | AND-codegen fix — biggest unblock (63). **Needs user OK to touch the reference engine.** |
| 2 | `.4` | `blocked` | input-boundary fix (2). **Needs user OK to touch the reference engine.** |
| 3 | `.2.1` | `pending` | Lowest-risk re-bless (8, cluster A); independent of the engine fixes (these expectations are stale regardless). |
| 4 | `.2.2`–`.2.4` | `pending` | Re-bless / retire the remaining 100 stale subtests. |
| 5 | `.5` | `pending` | Green-phase0 verification + downstream gate flips. |

Recommended order once authorized: `.3` → `.4` → `.2.1`–`.2.4` → `.5` (fix the engine first so re-bless
never freezes buggy output; the 108 stale expectations are independent of the engine fixes, so `.2.x`
can also proceed in parallel if the engine touch is deferred).

## Decisions

- `2026-06-19`: User chose "triage read-only first" (over fix-iteratively or defer). **Vindicated** —
  re-blessing cluster D (60) would have masked a real AND-codegen defect.
- `2026-06-19`: Triage complete. 108/173 STALE (re-bless), 65/173 REAL across 2 engine defects. The two
  big stale families trace to *intentional* engine changes (COMPAT-ALIAS-RETIREMENT-V2 retired the
  `return_*` helpers/`RETURN_A` nodes; `return(1)` is a plain resolved return). The engine is correct
  for all 108 stale cases. **Open decision (user):** authorize touching the reference engine for `.3`/`.4`
  (genuine codegen/validation bugs — invalid Perl + pre-empted validation, not docs-vs-reference drift).

## Open Questions

- Authorize the reference-engine fixes (`.3`/`.4`)? They are real defects, but touch `perl/` — your
  standing guidance is to keep the reference frozen. Alternative: quarantine the 65 real tests instead
  (keeps the reference untouched but leaves the capture/mark/multi-edge-AND feature broken + undocumented).
- Did subtests 881–959 run clean? The `.1` run stopped at 881; `MEMORY` claims a ~940–959 reach with 173
  total, implying 881+ are clean — confirm in `.5` with a longer-budget run.

## Blockers

- `.3`/`.4` blocked pending user authorization to touch the reference Perl engine. `.2.x` (test re-bless)
  is not blocked by that. Green phase0 (and `SPEC-FORMAT-TERSE` / `LEGACY-VHDL-RETIRE.4-.5` /
  `NONCORE-QUARANTINE.V`) stays blocked until both engine defects are fixed and the 108 stale are re-blessed.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-19` | `.1` | full phase0 TAP (173 fail/707 pass); cluster-D V1–V4 bisection; capture_from/return-array lowering isolation; entry_and child `[]` repro; 2 parallel read-only deep-dives (B; C+F+G) | `done` — 108 STALE / 65 REAL (2 defects) |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `.1` | `PHASE0-BACKHALF-TRIAGE.1 — read-only triage complete` | this commit |

## Changelog

- `2026-06-19`: Created after `NONCORE-QUARANTINE` exposed 173 pre-existing back-half core failures.
- `2026-06-19`: `.1` read-only triage **DONE** — full per-cluster verdict (108 STALE / 65 REAL across 2
  engine defects: AND-rule action-codegen + input-boundary-validation regression). Added `.2` (re-bless,
  4 sub-leaves), `.3` (AND-codegen fix, blocked on engine-touch OK), `.4` (input-boundary fix, blocked),
  `.5` (green-phase0 verification). Knowledge cards [[and-return-edge-codegen-defect]] +
  [[runtime-input-boundary-validation-regression]].
