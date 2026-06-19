# TRACE-OBSERVABILITY: a discoverable CLI + comprehensive "see everything" trace

## Metadata

- Tree ID: `TRACE-OBSERVABILITY`
- Status: `active` (created 2026-06-19)
- Roadmap lane: `Overall roadmap — engine observability / developer experience`
- Created: `2026-06-19`
- Last updated: `2026-06-19` (created — owns the user's 2026-06-19 trace directives; scaffold)
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

**It works** — `LINKEDSPEC_TRACE_LEVEL=debug perl -Iperl <driver>` emits ~22k lines of
ENTER/DECISION/dump trace for a tiny spec (to **stdout**; `TRACE_LOG_MODE='stdout'`). Existing env
controls (Trace.pm ~236–261, gated by `$TRACE_INITIALIZED`): `LINKEDSPEC_TRACE_LEVEL`,
`LINKEDSPEC_DUMP_VERBOSITY`, `LINKEDSPEC_TRACE_FILE`, `LINKEDSPEC_TRACE_MIRROR_STDOUT`,
`LINKEDSPEC_TRACE_EMOJI`, `LINKEDSPEC_TRACE_RESET_FILE`. (Setting `$DUMP_VERBOSITY` directly does
NOT work — use the env var or `configure_trace`.)

**The two gaps (= this tree's work):**
1. **Discoverability/CLI:** no `--trace` flag, no `bin/` entrypoint, not documented in the mdBook —
   so the control is effectively invisible (the user + I both missed it).
2. **Coverage:** instrumentation is at *pipeline stages + key decisions*, NOT exhaustive. "See
   everything" wants function enter/exit + every if/switch/case branch across the compile pipeline
   AND the **generated runtime parser** (the emitted handler source in `SpecEntry`/`HandlerVariantEmitter`
   — runtime branch tracing likely needs emitting trace calls into the generated handlers).

## Non-Goals

- Re-implementing the trace framework (it exists; extend + expose it).
- Tracing into `noncore/` (out of scope; core only).

## Acceptance Criteria

- A discoverable CLI front-end drives trace (level + file/mirror) and is documented in the mdBook.
- Trace coverage reaches "see everything": function enter/exit + branch (if/switch/case) decisions
  across the compile pipeline and the generated runtime parser, gated by verbosity.
- Regression-locked; no change to default (untraced) behavior/output.

## Task Tree (scaffold — refine on pickup)

- ID: `TRACE-OBSERVABILITY` · Status: `active` · Children: `.1`, `.2`, `.3`
- ID: `TRACE-OBSERVABILITY.1` · Status: `pending`
  Goal: Coverage audit — map what is already instrumented (trace_enter/exit/decision sites) across
    the compile pipeline + runtime parser, and enumerate the gaps to "see everything" (which funcs
    lack enter/exit, which branches lack `trace_decision`, runtime-handler branch tracing).
  Acceptance: a gap inventory + a coverage plan. Read-only.
  Verification: `pending`
  Commit: `pending`
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
| 1 | `.1` | `pending` | Coverage audit (read-only) — know what exists vs the "see everything" gap before instrumenting. |
| 2 | `.2` | `pending` | Discoverable CLI control + docs (quick DX win; also helps the triage). |
| 3 | `.3` | `pending` | Extend coverage to function enter/exit + branch decisions, pipeline then runtime parser. |

## Decisions

- `2026-06-19`: Owns the user's trace directives (CLI control + comprehensive "see everything" trace).
  The framework already exists (Trace.pm: enter/exit/decision/levels/sinks; env-var control works) —
  the work is (a) make it discoverable (CLI + docs) and (b) extend coverage. Sequence `.2` (CLI/docs)
  early for a quick win; `.1`/`.3` for the coverage push.

## Open Questions

- CLI form: a new `bin/linkedspec` runner with `--trace`, vs documenting the env vars, vs both?
- Runtime-parser branch tracing: emit `trace_decision`/`trace_enter` into the generated handler
  source (in `SpecEntry`/`HandlerVariantEmitter`), gated by verbosity — design needed.
- Auto-instrumentation (aspect/`Devel::*`) vs hand-placed trace calls for the "everything" coverage.

## Blockers

- None. Independent of the triage; `.2` (CLI) can land standalone.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-19` | (scaffold) | assessed existing Trace.pm + ran `LINKEDSPEC_TRACE_LEVEL=debug` | framework exists + works; gaps = discoverability + coverage |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| (creation) | (with the triage WIP commit) | Scaffold owning the trace directives. |

## Changelog

- `2026-06-19`: Created to own the user's trace directives (discoverable CLI control + comprehensive
  "see everything" trace). Recorded the existing Trace.pm framework + env-var control + the two gaps
  (discoverability, coverage).
