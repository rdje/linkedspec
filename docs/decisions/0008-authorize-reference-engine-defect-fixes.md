# 0008 — Authorize two reference-engine defect fixes (sanctioned exception to the engine-frozen doctrine)

- Date: 2026-06-21
- Status: accepted
- Tags: engine, codegen, runtime, regression-gate, phase0, doctrine-exception
- Owning tree: [`docs/tasks/PHASE0-BACKHALF-TRIAGE.md`](../tasks/PHASE0-BACKHALF-TRIAGE.md) (leaves `.3`, `.4`)

## Context

The standing doctrine is to keep the Perl reference engine **frozen** — it is the authoritative
source of truth for all variants, and when docs and the reference disagree, the docs are fixed, not
the reference (see [[feedback_do-not-fix-reference-engine]] and the `MEMORY.md` "ENGINE FROZEN"
directive of 2026-06-19). `PHASE0-BACKHALF-TRIAGE.1` triaged 173 dark back-half phase0 failures into
**108 STALE (test-only re-bless)** and **65 non-stale**, the latter tracing to two concrete
engine-level symptoms that a fresh session (2026-06-21) re-verified read-only and objectively:

- **Defect #1 — AND-rule action-codegen.** A `:AND`/`::AND` rule with multiple indexed edges
  (`-> Rule[0]`, `-> Rule[1]`, …) where an edge action contains a `return(...)` payload emits invalid
  Perl: the per-edge collector name is a stringified SCALAR ref (`SCALAR(0x…)Rule = …`). Top rule ⇒
  compile-fail ⇒ parser returns `undef`; child rule ⇒ compiles but drops the payload ⇒ `[]`. Root
  cause located: `perl/LinkedSpec/HandlerVariantEmitter.pm` `_emit_and_acode_seq_handler` (and the
  sibling `_emit_and_single_acode_handler`) use a mis-written substitution `s/\breturn\s*/\$" . $label
  . " = "/eg` — the bare `\$"` is parsed as a *reference to* `$"` instead of the literal `"$"` used
  correctly elsewhere in the same file (lines 524, 594). The book's own `Pair::AND` worked example
  (`user-model/rule-modes-and-parse-modes.md:124-133`) hits this exact path and breaks. See
  [[and-return-edge-codegen-defect]].
- **Defect #2 — input-boundary-validation regression.** `perl/LinkedSpec/Runtime.pm` (~line 126) — a
  comment/blank-line-skip wrapper added by `MEDIUM-IMPACT.3.2` (commit `d7294d0`) runs an unguarded
  `pos($$input_ref) = 0;` deref **before** the documented SCALAR-ref input guard, so invalid top-level
  input dies with a raw `Not a SCALAR reference at … Runtime.pm line 126` and an empty
  `runtime_ctx->{last_error}`, instead of the contracted friendly boundary error. This is a *recent
  regression of a documented contract*, not a docs-vs-reference disagreement. See
  [[runtime-input-boundary-validation-regression]].

The triage left `.3`/`.4` `blocked` pending an explicit user decision, because both fixes touch
`perl/`. On **2026-06-21 the user explicitly authorized BOTH engine fixes** (via an AskUserQuestion
choice: "Authorize both engine fixes" — touch `perl/` for Defect #1 in the AND-codegen emitter and
Defect #2 in `Runtime.pm`, "and make the `:AND`+return-edge feature work as the broken book example
implies").

## Decision

Treat these two specific defect fixes as a **sanctioned, scoped exception** to the engine-frozen
doctrine — exactly the "do not touch the reference unless objectively shown broken AND the user
explicitly authorizes" carve-out the doctrine already names. Scope is limited to:

1. **Defect #1:** correct the AND action-codegen so an indexed AND edge carrying `return(...)` emits
   valid Perl and the rule returns the author payload — without regressing NORMAL (`::`) rules,
   AND-with-only-`assign` edges, blind-call (`bcode`) AND rules, or the REP/OR families.
2. **Defect #2:** guard the `Runtime.pm` wrapper deref so invalid input yields the documented friendly
   boundary error plus a populated structured `last_error`.

No other `perl/` change is in scope under this authorization. The 108 STALE failures remain test-only
re-bless (`.2.x`). The book's non-conformant `:AND` example is *also* corrected (docs lane) so the
documented surface and the now-fixed engine agree.

## Consequences

- Unblocks `PHASE0-BACKHALF-TRIAGE.3` (Defect #1, ~63 subtests) and `.4` (Defect #2, 2 subtests);
  combined with `.2.x` re-bless and `.5` verification this is the path to a green
  `t/phase0_regression.t`, which in turn unblocks the `SPEC-FORMAT-TERSE`,
  `LEGACY-VHDL-RETIRE.4/.5`, and `NONCORE-QUARANTINE.V` gates.
- Cross-variant parity obligation: the reference is the oracle for Rust/Julia/Dart, so any behavior
  the fix establishes (an AND edge `return(...)` surfaces the author payload) becomes part of the
  cross-variant contract and must be mirrored in the non-Perl variants in a follow-on. Recorded so the
  parity sweep does not miss it.
- The engine-frozen doctrine ([[feedback_do-not-fix-reference-engine]]) otherwise **stands**; this
  record is the named exception, not a reversal. Future engine touches still require the same
  objective-proof + explicit-authorization bar.

## Links

- Tree: [`PHASE0-BACKHALF-TRIAGE`](../tasks/PHASE0-BACKHALF-TRIAGE.md) (`.3`, `.4`)
- Cards: [[and-return-edge-codegen-defect]], [[runtime-input-boundary-validation-regression]],
  [[spec-top-rule-no-regex-two-rule-minimum]]
- Supersedes (scoped, for these two defects only) the "ENGINE FROZEN" framing in the 2026-06-19
  `MEMORY.md` resume pointer and `PHASE0-BACKHALF-TRIAGE.md` triage banner.
