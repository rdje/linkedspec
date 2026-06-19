# PHASE0-BACKHALF-TRIAGE: triage the ~173 pre-existing back-half core-engine test failures

## Metadata

- Tree ID: `PHASE0-BACKHALF-TRIAGE`
- Status: `active` (created 2026-06-19)
- Roadmap lane: `Overall roadmap — regression-gate health (back-half core failures)`
- Created: `2026-06-19`
- Last updated: `2026-06-19` (created; `.1` read-only triage in progress — user chose "triage read-only first")
- Owner: repo-local workflow

## Goal

`t/phase0_regression.t`'s back half (subtests ~111+) was dark for a long time behind the
`RTLUTILS-REGEX-HANG` + the legacy-island hangs. With those cleared (`LEGACY-VHDL-RETIRE` +
`NONCORE-QUARANTINE`), the suite now runs the back half and reveals **~173 pre-existing, real
core-engine test failures** (structural/shape mismatches, 0 timeouts, 0 missing-module errors).
**Not caused by that work** — engine bytes unchanged; the tests simply never ran. Determine, per
cluster and with evidence, whether each is a **STALE test** (written for engine behavior that has
since evolved — fix = re-bless the expected value against the current, documented engine output) or
a **REAL regression** (engine produces wrong output vs its documented contract — fix = the engine),
then report scope/effort before changing anything. A green `t/phase0_regression.t` unblocks the
`SPEC-FORMAT-TERSE` gate + the Rust/Julia/Dart parity (the regression baseline IS the cross-variant
contract).

## Non-Goals

- Changing any test or engine code in `.1` (read-only triage first; the user will scope the fix).
- Re-litigating the quarantine (`NONCORE-QUARANTINE`, done).

## The failures (from the post-quarantine phase0 run, 2026-06-19)

~173 failing subtests, deterministic (same count across runs), clustered:
- **Parser collection-shape (~10+):** `or_plus_blind_call`, `explicit_and`, `blind_call_choice`,
  `and_plus_rule_label`, `bounded_and_rule_labels`, `blind_call_repeated_choice`, … — engine returns
  scalar `'1'` where the test expects an ARRAY(-of-arrays). Looks systematic (one root cause).
- **`emit_context`×21:** `emit_context_meta_exposes_*`, `emit_context_lowers_*`,
  `emit_context_avoids_deps_*`, `emit_context_require_avoids_*` — RuleIR::EmitContext ActionIR
  lowering + metadata shape.
- **`method_like`×75:** the method-like DSL fluent/structured family.
- **`named_mark`×25 / capture / `entry_and` / `current_match` / `cursor` / `anonymous_capture`:**
  capture/mark/source-boundary reader helpers.
- Singles: `parser_invalid_input_fails_at_runtime_parser_boundary`,
  `bootstrap_registry_curly_brace_recursion_smoke`, `compatibility_surface_metadata_*`, etc.

Hypothesis to test: the `$got='1'` collection-shape failures match the `MEDIUM-IMPACT.3.4.x`
HandlerIR/handler-emission rework (which changed collection/return shape; see `DEVELOPMENT_NOTES`
2026-06-17 `SPEC-LANG-REFERENCE.10.1` re `_emit_and_single_acode_handler`). If the current shape is
the *intended* post-rework behavior → those tests are stale; if not → a real regression the hang hid.

## Trace mechanism (for root-causing) + a CLI-control finding (2026-06-19)

- **Tracing is driven by the EXISTING env-var control `LINKEDSPEC_TRACE_LEVEL=debug`** (Trace.pm
  ~236–261, gated by `$TRACE_INITIALIZED`; also `LINKEDSPEC_TRACE_FILE`,
  `LINKEDSPEC_TRACE_MIRROR_STDOUT`, `LINKEDSPEC_TRACE_EMOJI`, `LINKEDSPEC_DUMP_VERBOSITY`).
  `LINKEDSPEC_TRACE_LEVEL=debug perl -Iperl <driver>` emits the full compile/parse/emit trace
  (~22k lines for a tiny spec) to **stdout** (`TRACE_LOG_MODE='stdout'`); levels none/low/medium/high/full/debug.
  Setting `$LinkedSpec::Trace::DUMP_VERBOSITY` directly does NOT work — use the env var (or
  `LinkedSpec::configure_trace(level=>'debug')`).
- **CLI-CONTROL TASK (user directive 2026-06-19):** the control exists but is **undiscoverable** (no
  `--trace` flag, no `bin/` entrypoint, not in the mdBook). Expose it via a discoverable CLI front-end
  (e.g. a small `bin/` runner with `--trace LEVEL` / `--trace-file`, mapping to the env/`configure_trace`)
  + document the env vars in the book. Own this as its own leaf/tree (separate from the failure triage).

## Root-cause progress (2026-06-19)

- **Cluster A — parser collection-shape (`or_plus_blind_call`, `explicit_and`, `blind_call_choice`,
  `and_plus_rule_label`, `bounded_and_rule_labels`, blind-call repeated-choice; ~10+): VERDICT = STALE
  tests.** Reproduced `or_plus_blind_call` (`Choice::OR+ => First => Second`, children `return(1)`,
  input `"ab"`): engine returns **`[1, 1]`** (each child's literal `return(1)`); the test asserts the
  **old tagged-accumulator shape** `[['?First:',[]], ['?Second:',[]]]`. The engine is correct per the
  documented helper-DSL return semantics (`return(1)` ⇒ value `1`; the `['?Rule:',…]` tag is a retired
  optional convention — see the book's output-shape contract). Fix = re-bless these expectations to the
  current engine output. (Consistent with the `MEDIUM-IMPACT.3.4.x` return/shape rework these tests predate.)
- **Clusters B–E — pending root-cause (trace now available):** `method_like`×75, `emit_context`×21,
  `named_mark`/`capture`/`entry_and`/`cursor`/`current_match`. Use `LINKEDSPEC_TRACE_LEVEL=debug` per
  representative; judge stale-vs-real against the book / `ActionIR/Contracts.pm` / shipped-spec behavior.

## Acceptance Criteria (.1, read-only)

- Complete failure inventory (names + got/expected) captured.
- Per-cluster verdict — STALE (re-bless) vs REAL (engine fix) — each backed by checking the current
  engine output against the documented contract (mdBook / `ActionIR/Contracts.pm` / shipped-spec
  behavior / the oracle corpus).
- Scope/effort estimate (how many re-bless vs engine-fix) + a recommended fix order. No code change.

## Task Tree

- ID: `PHASE0-BACKHALF-TRIAGE` · Status: `active` · Children: `.1` (more after triage)
- ID: `PHASE0-BACKHALF-TRIAGE.1` · Status: `in_progress`
  Goal: Read-only cluster-by-cluster stale-vs-real triage of the ~173 failures, with evidence + scope.
  Acceptance: per-cluster verdict + scope/effort + recommended fix plan, decomposed into `.2+` leaves.
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `PHASE0-BACKHALF-TRIAGE.1` | `in_progress` | Read-only triage (user-chosen). Sample each cluster; judge stale-vs-real vs the documented engine contract; report scope before any fix. |

## Decisions

- `2026-06-19`: User chose "triage read-only first" (AskUserQuestion) over fix-iteratively or defer.
  These failures are pre-existing (not from the quarantine — engine bytes unchanged), revealed by
  finally running the back half. Triage before touching anything; re-blessing risks masking a real bug.

## Open Questions

- Per cluster: stale (re-bless to current engine output) vs real (engine regression to fix)?
- Is the `$got='1'` collection-shape the intended post-`MEDIUM-IMPACT.3.4.x` behavior or a regression?

## Blockers

- None to start `.1` (read-only). Green phase0 (and `SPEC-FORMAT-TERSE` / `LEGACY-VHDL-RETIRE.4-.5` /
  `NONCORE-QUARANTINE.V`) is blocked until the fix leaves land.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-19` | `.1` | `pending` (cluster sampling + contract checks) | `pending` |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `.1` | `pending` | `pending` |

## Changelog

- `2026-06-19`: Created after `NONCORE-QUARANTINE` exposed ~173 pre-existing back-half core failures.
  `.1` read-only triage in progress (user chose "triage read-only first").
