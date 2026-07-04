# TRACE-OBSERVABILITY: a discoverable CLI + comprehensive "see everything" trace

## Metadata

- Tree ID: `TRACE-OBSERVABILITY`
- Status: `active`
- Roadmap lane: `Overall roadmap — engine observability / developer experience`
- Created: `2026-06-19`
- Last updated: `2026-07-04` (`.1` coverage audit complete; `.2` CLI/docs is next)
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
1. **Discoverability/CLI:** no `--trace` flag, no `bin/` entrypoint, not documented in the mdBook —
   so the control is effectively invisible (the user + I both missed it).
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

- There is still no discoverable `bin/` entrypoint or `--trace`/`--trace-file` CLI surface.
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

1. `.2`: add a discoverable CLI/control surface and document the exact env/per-call/API controls. Correct docs must
   say `configure_trace`, per-call options, and env vars are the reliable controls; lazy facade package-variable
   mutation is compatibility state, not the preferred control path.
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

- ID: `TRACE-OBSERVABILITY` · Status: `active` · Children: `.1`, `.2`, `.3`, future backend parity
- ID: `TRACE-OBSERVABILITY.1` · Status: `done` (closed 2026-07-04)
  Goal: Coverage audit — map what is already instrumented (trace_enter/exit/decision sites) across
    the compile pipeline + runtime parser, and enumerate the gaps to "see everything" (which funcs
    lack enter/exit, which branches lack `trace_decision`, runtime-handler branch tracing).
  Acceptance: done — gap inventory + coverage plan recorded above. Read-only.
  Verification: `rg` call-site inventory, emitted handler source probe, routed debug trace probe, Rust trace search,
    mdBook/API drift probes.
  Commit: `pending this commit`
- ID: `TRACE-OBSERVABILITY.2` · Status: `pending`
  Goal: Discoverable CLI control — expose the existing env/`configure_trace` control via a `bin/`
    entrypoint and/or a `--trace LEVEL` / `--trace-file` flag; document the env vars + the CLI in the
    mdBook. (Smallest, highest-DX win — do first if a quick gate is wanted.)
  Verification: `pending`
  Commit: `pending`
- ID: `TRACE-OBSERVABILITY.3` · Status: `pending`
  Goal: Extend instrumentation toward "see everything" (function enter/exit + if/switch/case branch
    decisions), compile pipeline first, then the generated runtime parser (emit trace into handlers).
    Likely incremental; consider a low-overhead auto/aspect approach vs hand-instrumentation.
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `.2` | `pending` | Discoverable CLI control + docs now that the exact existing controls and docs drift are known. |
| 2 | `.3` | `pending` | Extend Perl reference coverage to function enter/exit + branch decisions, pipeline then runtime parser. |
| 3 | future backend parity | `pending split` | Rust has no trace API yet; split after Perl reference trace semantics settle. |

## Decisions

- `2026-06-19`: Owns the user's trace directives (CLI control + comprehensive "see everything" trace).
  The framework already exists (Trace.pm: enter/exit/decision/levels/sinks; env-var control works) —
  the work is (a) make it discoverable (CLI + docs) and (b) extend coverage. Sequence `.2` (CLI/docs)
  early for a quick win; `.1`/`.3` for the coverage push.

## Open Questions

- CLI form: a new `bin/linkedspec` runner with `--trace`, vs documenting the env vars, vs both?
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

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| (creation) | (with the triage WIP commit) | Scaffold owning the trace directives. |
| `.1` | `pending this commit` | Coverage audit and plan; no runtime/code behavior change. |

## Changelog

- `2026-06-19`: Created to own the user's trace directives (discoverable CLI control + comprehensive
  "see everything" trace). Recorded the existing Trace.pm framework + env-var control + the two gaps
  (discoverability, coverage).
- `2026-07-04`: Closed `.1` read-only coverage audit. Current trace is useful but not exhaustive: pipeline
  boundaries, parser/rule handler wrappers, selected decisions, dumps, and mark/capture events are traced; generated
  handler branch/control-flow decisions and most ActionIR owner branches are not. `.2` is now the PNT frontier.
