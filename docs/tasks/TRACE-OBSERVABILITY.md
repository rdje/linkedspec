# TRACE-OBSERVABILITY: a discoverable CLI + comprehensive "see everything" trace

## Metadata

- Tree ID: `TRACE-OBSERVABILITY`
- Status: `active`
- Roadmap lane: `Overall roadmap — engine observability / developer experience`
- Created: `2026-06-19`
- Last updated: `2026-07-04` (`.3.1` generated-handler trace helper seam complete; `.3.2` is next)
- Owner: repo-local workflow

## Goal (user directive, 2026-06-19)

Make LinkedSpec's execution **fully observable** from the command line:
1. **A discoverable CLI control** for the trace API ("introduce a CLI control to this API").
2. **Comprehensive trace** — "ideally a well-implemented trace shall be able to see everything":
   which functions are **entered/exited**, which **if/switch/case branch** is taken, decisions,
   values, parse positions — across the compile pipeline AND the generated runtime parser.

This also directly enables root-causing (e.g. `PHASE0-BACKHALF-TRIAGE`).

## Current state of the trace (assessed 2026-06-19)

The framework **already exists** in `perl/LinkedSpec/Trace.pm` (public surface re-exported from
`LinkedSpec.pm`): `configure_trace`, `trace_enter`/`trace_exit` (function/scope enter-exit),
`trace_decision` (branch/decision: `DECISION <name> => TAKEN`), `log_output`, `log_dump`,
`should_dump`; UVM-style levels `none(0)/low(100)/medium(200)/high(300)/full(400)/debug(500)`;
indent nesting; mark-excerpt rendering; sink routing (stdout | route-to-file | mirror).

**It works** — `LINKEDSPEC_TRACE_LEVEL=debug perl -Iperl <driver>` emits large ENTER/DECISION/dump
traces for tiny specs (a 2026-07-04 probe with routed debug trace wrote 40,199 lines). Existing env
controls (Trace.pm ~236–261, gated by `$TRACE_INITIALIZED`): `LINKEDSPEC_TRACE_LEVEL`,
`LINKEDSPEC_DUMP_VERBOSITY`, `LINKEDSPEC_TRACE_FILE`, `LINKEDSPEC_TRACE_MIRROR_STDOUT`,
`LINKEDSPEC_TRACE_EMOJI`, `LINKEDSPEC_TRACE_RESET_FILE`. (Setting `$DUMP_VERBOSITY` directly does
NOT reliably work through the lazy-loaded `LinkedSpec` facade before first Trace load — use env vars,
per-call trace options, or `configure_trace`.)

**The two gaps (= this tree's work):**
1. **Discoverability/CLI:** `TRACE-OBSERVABILITY.2` now closes the first discoverability gap with
   `bin/linkedspec`, a command-line compile/run runner that exposes `--trace LEVEL`, `--trace-file`,
   `--trace-mode`, `--trace-reset`, and `--trace-emoji`, and with mdBook/TOOLBOX documentation.
2. **Coverage:** instrumentation is at *pipeline stages + key decisions*, NOT exhaustive. "See
   everything" wants function enter/exit + every if/switch/case branch across the compile pipeline
   AND the **generated runtime parser** (the emitted handler source in `SpecEntry`/`HandlerVariantEmitter`
   — runtime branch tracing likely needs emitting trace calls into the generated handlers).

## Coverage Audit (`TRACE-OBSERVABILITY.1`, 2026-07-04)

The existing trace call-site map is concentrated in the Perl reference backend:

- `perl/LinkedSpec/Trace.pm`: owns verbosity parsing, sink routing, ENTER/EXIT/DECISION/MARK rendering,
  dump output, and env/per-call configuration.
- `perl/LinkedSpec.pm`: exposes facade wrappers for `configure_trace`, `trace_enter`, `trace_exit`,
  `trace_decision`, `log_output`, `log_dump`, and `should_dump`. It does **not** expose a facade wrapper for
  `trace_mark_event`; that is an owner-level `LinkedSpec::Trace` function reached by generated/runtime internals.
- `perl/LinkedSpec/Compiler.pm`: traces the broad `LinkedSpec::Get` compile pipeline, parser invocation,
  top-rule resolution/input validation/invocation decisions, `build_compiled_rule_table`, and
  `build_dependency_regex_map`.
- `perl/LinkedSpec/ParserFactory.pm`, `perl/LinkedSpec/Resolver.pm`, and `perl/LinkedSpec/Validation.pm`:
  trace named-spec lookup, resolver fallbacks, and validation failures/warnings.
- `perl/LinkedSpec/SpecEntry.pm`: traces per-rule compile entry/exit, handler source dumps, runtime
  `LinkedSpec::rule_handler:<label>` entry/exit, handler compile/eval failures, and the no-consume recursion cut.
- `perl/LinkedSpec/RuleIR.pm` and ActionIR mark contracts: emit mark/capture trace calls into generated handler
  code for supported mark operations.

The important gaps are now pinned:

- At the time of this `.1` audit there was no discoverable `bin/` entrypoint or
  `--trace`/`--trace-file` CLI surface. `TRACE-OBSERVABILITY.2` has since closed that discoverability gap.
- Most ActionIR/lowering owner functions have no ENTER/EXIT scopes and their `if`/`switch`/case decisions are not
  traced; the current pipeline trace sees stage boundaries and a few validation decisions, not every branch.
- `perl/LinkedSpec/HandlerVariantEmitter.pm` emits untraced runtime branches (`while`, `foreach`, `if`/`elsif`,
  `unless`, repetition min/max and zero-progress branches, acode index dispatch, bcode call dispatch, and
  no-match/LX/EX paths). A 2026-07-04 `dump_parser_source` probe for a minimal parser showed emitted
  `while (` and `unless(` branches but no emitted `trace_decision`/`trace_enter`/`trace_exit` in the handler body.
  Runtime execution for that same parser exposed only wrapper-level `parser_invoke`, `rule_handler`, and
  `rule_handler_eval` decisions.
- Generated in-body trace is currently limited mainly to mark/capture events; ordinary match/dispatch/repetition
  control flow is opaque unless the whole handler source is dumped and read manually.
- Rust currently has no analogous trace API/sink surface in `rust/linkedspec-runtime`; `rg` finds no runtime trace
  implementation beyond ordinary test variables named `log`.

Coverage plan:

1. `.2`: done — add a discoverable CLI/control surface and document the exact env/per-call/API controls. Correct
   docs say `configure_trace`, per-call options, env vars, and `bin/linkedspec` flags are the reliable controls;
   lazy facade package-variable mutation is compatibility state, not the preferred control path.
2. `.3`: extend Perl reference coverage in small sub-leaves: first add low-overhead runtime decision helpers for
   generated handlers, then instrument handler variant templates for match/no-match, dispatch, lifecycle path, and
   repetition decisions, then add missing compile/ActionIR owner ENTER/EXIT and branch decisions.
3. Future backend-parity leaf: after the Perl reference trace semantics are concrete, define/implement the Rust
   equivalent trace model instead of pretending the current Perl-only trace surface already covers Rust.

## Non-Goals

- Re-implementing the trace framework (it exists; extend + expose it).
- Tracing into `noncore/` (out of scope; core only).

## Acceptance Criteria

- A discoverable CLI front-end drives trace (level + file/mirror) and is documented in the mdBook.
- Trace coverage reaches "see everything": function enter/exit + branch (if/switch/case) decisions
  across the compile pipeline and the generated runtime parser, gated by verbosity.
- Regression-locked; no change to default (untraced) behavior/output.

## Task Tree (scaffold — refine on pickup)

- ID: `TRACE-OBSERVABILITY` · Status: `active` · Children: `.1`, `.2`, `.3.{1..5}`, future backend parity
- ID: `TRACE-OBSERVABILITY.1` · Status: `done` (closed 2026-07-04)
  Goal: Coverage audit — map what is already instrumented (trace_enter/exit/decision sites) across
    the compile pipeline + runtime parser, and enumerate the gaps to "see everything" (which funcs
    lack enter/exit, which branches lack `trace_decision`, runtime-handler branch tracing).
  Acceptance: done — gap inventory + coverage plan recorded above. Read-only.
  Verification: `rg` call-site inventory, emitted handler source probe, routed debug trace probe, Rust trace search,
    mdBook/API drift probes.
  Commit: `9085a026` (`TRACE-OBSERVABILITY.1 - audit trace coverage gaps`)
- ID: `TRACE-OBSERVABILITY.2` · Status: `done` (closed 2026-07-04)
  Goal: Discoverable CLI control — expose the existing env/`configure_trace` control via a `bin/`
    entrypoint and/or a `--trace LEVEL` / `--trace-file` flag; document the env vars + the CLI in the
    mdBook. (Smallest, highest-DX win — do first if a quick gate is wanted.)
  Acceptance: done — `bin/linkedspec` compiles/runs inline, file, or named specs; prints canonical JSON; exposes
    `--trace`, `--trace-file`, `--trace-mode`, `--trace-reset`, and `--trace-emoji`; and the mdBook plus
    `TOOLBOX.md` document the control path.
  Verification: `perl -c bin/linkedspec`; `perl -c -Iperl t/trace_cli.t`; `prove -v -Iperl t/trace_cli.t`;
    `mdbook build docs/linkedspec-book`; `bash knowledge-map/scripts/check_knowledge_map.sh`;
    `bash scripts/check_memory_architecture.sh`; `bash scripts/check_doctrines.sh`; `git diff --check`;
    `bash tools/run_ci_local.sh`.
  Commit: `30981c44` (`TRACE-OBSERVABILITY.2 - add trace CLI control`)
- ID: `TRACE-OBSERVABILITY.3` · Status: `split` (closed 2026-07-04)
  Goal: Extend instrumentation toward "see everything" (function enter/exit + if/switch/case branch
    decisions), compile pipeline first, then the generated runtime parser (emit trace into handlers).
  Acceptance: done — split into executable children below so coverage work can land in signoff-sized slices.
  Verification: task-tree split review; no runtime/code behavior change.
  Commit: `pending this commit`
- ID: `TRACE-OBSERVABILITY.3.1` · Status: `done` (closed 2026-07-04)
  Goal: Generated-handler trace helper contract — add the smallest reusable Perl runtime helper seam for emitted
    handler branch decisions, prove trace-off behavior stays quiet/cheap, and document the emitted-call contract.
  Acceptance: done — `LinkedSpec::Trace::trace_generated_handler_branch(%args)` returns the original branch
    boolean, emits structured `generated_handler_branch:<kind>:<rule>:<branch>` decisions when enabled, evaluates
    lazy details only when trace output is enabled, and captures detail-builder errors without perturbing branch
    behavior. mdBook documents the owner-level emitted-call contract and keeps template instrumentation scoped to
    later leaves.
  Verification: `perl -c -Iperl perl/LinkedSpec/Trace.pm`; `perl -c -Iperl t/trace_generated_handler_branch.t`;
    `prove -v -Iperl t/trace_generated_handler_branch.t`; mdBook; Knowledge Map; memory/doctrine; whitespace;
    `bash tools/run_ci_local.sh`.
  Commit: `pending this commit`
- ID: `TRACE-OBSERVABILITY.3.2` · Status: `pending`
  Goal: Instrument non-repetition generated handler dispatch paths: match/no-match, acode index dispatch, bcode
    child-call dispatch, and `LX`/`EX` outcomes.
  Verification: `pending`
  Commit: `pending`
- ID: `TRACE-OBSERVABILITY.3.3` · Status: `pending`
  Goal: Instrument repetition generated handler paths: min/max bounds, loop entry/exit, zero-progress cutoff, and
    per-iteration success/failure decisions.
  Verification: `pending`
  Commit: `pending`
- ID: `TRACE-OBSERVABILITY.3.4` · Status: `pending`
  Goal: Add missing Perl compile/ActionIR owner ENTER/EXIT scopes and branch decisions for the lowering paths that
    select helper families, control-flow branches, and fallback/diagnostic outcomes.
  Verification: `pending`
  Commit: `pending`
- ID: `TRACE-OBSERVABILITY.3.5` · Status: `pending`
  Goal: Coverage closeout — update mdBook examples/coverage boundaries, run no-drift trace probes, and decide
    whether Rust trace parity can now be split from concrete Perl reference semantics.
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `.3.2` | `pending` | Instrument non-repetition generated handler dispatch now that the helper seam exists. |
| 2 | `.3.3` | `pending` | Instrument repetition paths separately because min/max/zero-progress loops have distinct risks. |
| 3 | `.3.4` | `pending` | Add compile/ActionIR owner scopes after runtime handler trace semantics are concrete. |
| 4 | `.3.5` | `pending` | Close coverage docs/probes and decide the backend-parity split. |
| 5 | future backend parity | `pending split` | Rust has no trace API yet; split after Perl reference trace semantics settle. |

## Decisions

- `2026-06-19`: Owns the user's trace directives (CLI control + comprehensive "see everything" trace).
  The framework already exists (Trace.pm: enter/exit/decision/levels/sinks; env-var control works) —
  the work is (a) make it discoverable (CLI + docs) and (b) extend coverage. Sequence `.2` (CLI/docs)
  early for a quick win; `.1`/`.3` for the coverage push.
- `2026-07-04`: CLI form is `bin/linkedspec`, a small Perl reference runner that maps CLI trace flags directly
  to the existing trace option keys and keeps routed trace output separate from canonical JSON stdout.
- `2026-07-04`: `.3` is split before code. Generated handler helper/seam work comes first, generated non-REP and
  REP branches are separate leaves, compile/ActionIR owner scopes follow, and backend parity waits until Perl
  reference semantics are concrete.
- `2026-07-04`: `.3.1` adds only the helper contract. It deliberately does not instrument non-repetition or
  repetition templates; `.3.2` and `.3.3` own those emitted call-site changes.

## Open Questions

- Runtime-parser branch tracing: emit explicit decision calls into generated handler source
  (`HandlerVariantEmitter` templates via `SpecEntry` runtime helpers), gated by verbosity.
- Auto-instrumentation (`Devel::*`/aspect style) is not the preferred first path: generated template instrumentation
  and owner-level trace wrappers are more portable and reviewable.

## Blockers

- None. Independent of the triage; `.2` (CLI) can land standalone.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-19` | (scaffold) | assessed existing Trace.pm + ran `LINKEDSPEC_TRACE_LEVEL=debug` | framework exists + works; gaps = discoverability + coverage |
| `2026-07-04` | `.1` | `rg` trace call-site inventory; `dump_parser_source` probe; routed debug trace probe to `/tmp/linkedspec_trace_audit.log`; direct facade/owner state probes; Rust trace search | PASS — audit recorded; generated handler control flow is not exhaustively traced; CLI/docs and coverage gaps are explicit |
| `2026-07-04` | `.2` | `perl -c bin/linkedspec`; `perl -c -Iperl t/trace_cli.t`; `prove -v -Iperl t/trace_cli.t`; mdBook; Knowledge Map; memory/doctrine; whitespace; `tools/run_ci_local.sh` | PASS — CLI help exposes trace flags; routed trace file is non-empty; stdout remains canonical parser JSON; full local CI passes with phase0 1021 green |
| `2026-07-04` | `.3` | task-tree split review; `bash scripts/check_memory_architecture.sh`; `bash scripts/check_doctrines.sh`; `bash knowledge-map/scripts/check_knowledge_map.sh`; `git diff --check` | PASS — coverage extension split before code |
| `2026-07-04` | `.3.1` | `perl -c -Iperl perl/LinkedSpec/Trace.pm`; `perl -c -Iperl t/trace_generated_handler_branch.t`; `prove -v -Iperl t/trace_generated_handler_branch.t`; mdBook; Knowledge Map; memory/doctrine; whitespace; `bash tools/run_ci_local.sh` | PASS — helper contract added before generated template instrumentation; full local CI passed with phase0 1021 green |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| (creation) | (with the triage WIP commit) | Scaffold owning the trace directives. |
| `.1` | `9085a026` (`TRACE-OBSERVABILITY.1 - audit trace coverage gaps`) | Coverage audit and plan; no runtime/code behavior change. |
| `.2` | `30981c44` (`TRACE-OBSERVABILITY.2 - add trace CLI control`) | CLI/docs control; no trace coverage expansion yet. |
| `.3` | `8e371460` (`TRACE-OBSERVABILITY.3 - split trace coverage extension`) | Split Perl reference coverage extension into executable child leaves; no runtime/code behavior change. |
| `.3.1` | `pending this commit` | Generated-handler branch trace helper contract; templates not yet instrumented. |

## Changelog

- `2026-06-19`: Created to own the user's trace directives (discoverable CLI control + comprehensive
  "see everything" trace). Recorded the existing Trace.pm framework + env-var control + the two gaps
  (discoverability, coverage).
- `2026-07-04`: Closed `.1` read-only coverage audit. Current trace is useful but not exhaustive: pipeline
  boundaries, parser/rule handler wrappers, selected decisions, dumps, and mark/capture events are traced; generated
  handler branch/control-flow decisions and most ActionIR owner branches are not. `.2` is now the PNT frontier.
- `2026-07-04`: Closed `.2` CLI/docs control. `bin/linkedspec` now exposes the existing trace API from the command
  line while routed trace output keeps parser JSON stdout stable. `.3` is now the PNT frontier for Perl reference
  coverage extension.
- `2026-07-04`: Split `.3` before implementation into helper-seam, non-repetition generated dispatch, repetition
  generated dispatch, compile/ActionIR owner-scope, and coverage-closeout leaves. `.3.1` is now the PNT frontier.
- `2026-07-04`: Closed `.3.1` helper seam. `LinkedSpec::Trace::trace_generated_handler_branch(%args)` is the
  owner-level contract for emitted branch decisions; `.3.2` is now the PNT frontier for non-repetition template
  call sites.
