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
>
> **UPDATE (2026-06-21 — authorization given; see ADR `0008`).** A fresh session re-verified BOTH
> defects objectively, read-only: (1) the book's OWN `:AND` worked example
> (`user-model/rule-modes-and-parse-modes.md:124-133`) breaks with the `SCALAR(0x…)Pair`/`near ")Pair"`
> codegen error — so a documented-but-self-inconsistent `:AND` example does break; (2) Defect #2 is now
> CONFIRMED (`Not a SCALAR reference at … Runtime.pm line 126`, empty `last_error`). The user then
> **authorized BOTH engine fixes** (ADR `0008`). Root cause of #1 is now pinned to a `\$"`-vs-`"\$"`
> substitution typo in `HandlerVariantEmitter.pm` (`_emit_and_acode_seq_handler` /
> `_emit_and_single_acode_handler`). The book's non-conformant `:AND` example is ALSO corrected (docs
> lane) so the surface and the fixed engine agree. The engine-frozen doctrine otherwise stands.

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

- ID: `PHASE0-BACKHALF-TRIAGE` · Status: `active` · Children: `.1` (done), `.2`, `.3` (done), `.4` (done), `.5`, `.6`
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
- ID: `PHASE0-BACKHALF-TRIAGE.3` · Status: `done` (2026-06-21 — **authorized by ADR `0008`**)
  Goal: **Engine fix** — AND-rule action-codegen defect (#1). Fix the AND multi-branch handler
    assembly so a `return(...)` edge emits a valid collector assignment (not `SCALAR(0x…)<Rule>`).
    Unblocks 63 subtests + makes capture/mark/cursor/entry helpers usable in multi-edge AND rules.
  Root cause (confirmed 2026-06-21, fresh-session re-verify + generated-source dump):
    `HandlerVariantEmitter.pm` `_emit_and_acode_seq_handler` (multi-regex AND) and
    `_emit_and_single_acode_handler` (single-regex AND) use the mis-written substitution
    `s/\breturn\s*/\$" . $label . " = "/eg` — the bare `\$"` evaluates as a *reference to* the
    list-separator var `$"` (stringifies `SCALAR(0x…)`), where the correct form (already used at
    lines 524 & 594) is `"\$" . $label . " = "` (literal `$`). Generated-source dump for
    `named_mark_capture_from_reads_rule_local_checkpoint` shows `SCALAR(0x…)Top = [...]` and a
    `return \@Top_collect` that is never pushed to. The test contract expects the **raw edge payload**
    (`['?Top:','bar']`), i.e. an AND edge `return(X)` should make the handler **return X directly** —
    the transform-to-assignment+collect model (borrowed from REP) is wrong for a single-pass AND.
  Acceptance: book `Pair::AND` + the named-mark reproducer compile and return the author payload; the
    63 subtests pass; no NORMAL/`assign`-only-AND/bcode-AND/REP/OR regression; full phase0 re-run shows
    the 63 cleared. **MET.**
  Fix: `perl/LinkedSpec/HandlerVariantEmitter.pm` — `_emit_and_acode_seq_handler` +
    `_emit_and_single_acode_handler` now emit edge acodes verbatim (removed the broken
    `s/\breturn.../\$" . $label . " = "/eg` ref-stringification + the single-acode never-`push` drop).
  Verification (2026-06-21): `perl -c` clean (emitter + facade); reproducers return the raw author
    payload (`['?Top:','bar']`); full `perl -Iperl t/phase0_regression.t` = **173 → 111 failing (62
    cleared)** — all 60 cluster-D + named-G AND tests + C-t13 `push_nonempty` pass; remaining 111 =
    108 STALE (`.2.x`) + 2 Defect #2 (`.4`) + 1 `corpus_regression` tail (`.5`); zero regressions.
  Commit: (this commit)
- ID: `PHASE0-BACKHALF-TRIAGE.4` · Status: `done` (2026-06-21 — **authorized by ADR `0008`**)
  Goal: **Engine fix** — input-boundary-validation regression (#2). Make the `Runtime.pm` comment-skip
    wrapper guard its deref (or run the documented SCALAR-ref validation ahead of it) so invalid input
    yields the friendly boundary error + populated `runtime_ctx->{last_error}`. Unblocks 2 subtests.
    Defect #2 **re-confirmed objectively 2026-06-21**: `Not a SCALAR reference at … Runtime.pm line 126`
    with empty `last_error` (was unverified in the prior session). **MET.**
  Fix: `perl/LinkedSpec/Runtime.pm` — gate the `pos($$input_ref)=0` reset + leading-comment/blank-skip
    behind `if (ref($input_ref) eq 'SCALAR')` (mirrors `Compiler.pm:1109` `ref ne 'SCALAR'`) and always
    delegate to `$original_parser->($input_ref)`, so the documented inner guard fires for invalid input.
  Verification (2026-06-21): `perl -c` clean; reproducer → friendly error + populated `last_error`
    (`type=runtime_parser`), valid scalar-ref input still parses; full `perl -Iperl t/phase0_regression.t`
    = **111 → 109 failing**, set-diff vs post-`.3` = exactly the 2 Defect #2 subtests cleared, zero
    regressions. Blocker: **cleared 2026-06-21** (ADR `0008`).
  Commit: (this commit)
- ID: `PHASE0-BACKHALF-TRIAGE.5` · Status: `pending`
  Goal: Verify a fully green `t/phase0_regression.t` end-to-end (all 959 subtests), including the
    881–959 tail not observed in the `.1` run (the run was terminated at subtest 881; confirm no fresh
    hang at `vhdl_small_blocker_helper_flow_eliminates_raw_fallback`/`corpus_regression`). Then flip the
    downstream gates (`SPEC-FORMAT-TERSE`, `LEGACY-VHDL-RETIRE.4/.5`, `NONCORE-QUARANTINE.V`).
  Verification: `pending`  ·  Commit: `pending`
- ID: `PHASE0-BACKHALF-TRIAGE.6` · Status: `pending` (added 2026-06-21)
  Goal: Book `:AND` reconciliation. With Defect #1 fixed, an `::AND` top rule carrying regex slots +
    indexed edges with a `return(...)` edge now compiles and returns the raw author payload (the engine
    contract the cluster-D/G tests encode). But `appendix/formal-grammar.md:66-78` marks every `:AND`
    mode "Body rule only" and `worked-spec-walkthrough.md:119-124` + `what-is-linkedspec.md:45` say a
    top `::` rule "carries no regex" — both now contradicted by the engine+tests. Reconcile the book so
    it neither misleads (the broken `Pair::AND` example) nor contradicts the engine, while preserving the
    recommended 2-rule idiom ([[spec-top-rule-no-regex-two-rule-minimum]]) as *style guidance* distinct
    from *engine capability*. Likely needs a short user policy check: document `::AND`+regex as a
    supported form vs. keep steering authors to the 2-rule idiom (or both — "supported but not idiomatic").
  Acceptance: no book `.spec` example is broken or doctrine-contradictory; the "Body rule only" /
    "no regex on top" claims are corrected or reframed as idiom; `mdbook build` exit 0; outputs verified
    via `LinkedSpec::Get`.
  Verification: `pending`  ·  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| — | `.3` | `done` 2026-06-21 | AND-codegen fix landed — 62 phase0 failures cleared, zero regressions. |
| — | `.4` | `done` 2026-06-21 | input-boundary guard landed — 2 cleared, zero regressions. Both engine defects now fixed. |
| 1 | `.2.1` | `pending` | Lowest-risk re-bless (8, cluster A); independent of the engine fixes (these expectations are stale regardless). |
| 2 | `.2.2`–`.2.4` | `pending` | Re-bless / retire the remaining 100 stale subtests (B=75, C=20, F+G). |
| 3 | `.5` | `pending` | Green-phase0 verification (incl. the `corpus_regression` subtest-941 tail) + downstream gate flips. |
| 4 | `.6` | `pending` (new) | Book `:AND` reconciliation: the now-fixed `::AND`+regex+return form vs the book's "Body rule only" / "no regex on top" idiom statements. |

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

- ~~Authorize the reference-engine fixes (`.3`/`.4`)?~~ **RESOLVED 2026-06-21** — user authorized BOTH
  engine fixes (ADR `0008`); the engine-frozen doctrine otherwise stands (this is the named exception).
- Did subtests 881–959 run clean? The `.1` run stopped at 881; `MEMORY` claims a ~940–959 reach with 173
  total, implying 881+ are clean — confirm in `.5` with a longer-budget run.

## Blockers

- ~~`.3`/`.4` blocked pending user authorization to touch the reference Perl engine.~~ **CLEARED
  2026-06-21 (ADR `0008`).** Green phase0 (and `SPEC-FORMAT-TERSE` / `LEGACY-VHDL-RETIRE.4-.5` /
  `NONCORE-QUARANTINE.V`) stays blocked until both engine defects are fixed AND the 108 stale are
  re-blessed AND `.5` verifies the full 959-subtest run.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-19` | `.1` | full phase0 TAP (173 fail/707 pass); cluster-D V1–V4 bisection; capture_from/return-array lowering isolation; entry_and child `[]` repro; 2 parallel read-only deep-dives (B; C+F+G) | `done` — 108 STALE / 65 REAL (2 defects) |
| `2026-06-21` | `.3` | `perl -c` (emitter+facade); generated-source dump; book `Pair::AND` + named-mark reproducers; 21-test AND contract catalog; full `perl -Iperl t/phase0_regression.t` | `done` — 173 → 111 failing (62 cleared, 0 regressions) |
| `2026-06-21` | `.4` | `perl -c` (`Runtime.pm`); invalid-ARRAY-input + valid-scalar-ref reproducers; full `perl -Iperl t/phase0_regression.t` + `comm -23` set-diff vs post-`.3` | `done` — 111 → 109 failing (exactly the 2 Defect #2 cleared, 0 regressions) |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `.1` | `PHASE0-BACKHALF-TRIAGE.1 — read-only triage complete` | prior commit `3a6d25b`/`f3c8a9b` |
| `.3` | `PHASE0-BACKHALF-TRIAGE.3 — engine fix: AND-rule action-codegen defect (#1)` | commit `a410d93` |
| `.4` | `PHASE0-BACKHALF-TRIAGE.4 — engine fix: input-boundary-validation regression (#2)` | this commit |

## Changelog

- `2026-06-19`: Created after `NONCORE-QUARANTINE` exposed 173 pre-existing back-half core failures.
- `2026-06-19`: `.1` read-only triage **DONE** — full per-cluster verdict (108 STALE / 65 REAL across 2
  engine defects: AND-rule action-codegen + input-boundary-validation regression). Added `.2` (re-bless,
  4 sub-leaves), `.3` (AND-codegen fix, blocked on engine-touch OK), `.4` (input-boundary fix, blocked),
  `.5` (green-phase0 verification). Knowledge cards [[and-return-edge-codegen-defect]] +
  [[runtime-input-boundary-validation-regression]].
- `2026-06-21`: User **authorized BOTH engine fixes** (ADR `0008` — sanctioned scoped exception to the
  engine-frozen doctrine); `.3`/`.4` blockers cleared. Fresh session re-verified both defects objectively
  (incl. the book's OWN `Pair::AND` example breaking). `.3` **DONE** — fixed the AND-acode emitter
  (`\$"`→verbatim) in `HandlerVariantEmitter.pm`; full phase0 173 → 111 failing (62 cleared, 0
  regressions). KM card [[and-return-edge-codegen-defect]] → `resolved`. Frontier → `.4`.
- `2026-06-21`: `.4` **DONE** — fixed Defect #2 (input-boundary) in `Runtime.pm` (gate the `pos()`/skip
  block behind `ref eq 'SCALAR'`, always delegate to the inner guard); full phase0 111 → 109 failing
  (set-diff = exactly the 2 Defect #2 subtests, 0 regressions). Both reference-engine defects now fixed.
  KM card [[runtime-input-boundary-validation-regression]] → `resolved`. Added `.6` (book `:AND`
  reconciliation). Frontier → `.2.1` (re-bless the 108 STALE, TEST-ONLY).
