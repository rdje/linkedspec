---
id: handler-ir-design
title: HandlerIR — structured handler representation separating structural decisions from code generation
answers:
  - what is HandlerIR
  - how does HandlerIR enable multi-backend portability
  - what are the HandlerIR node kinds
  - how do I add a new backend emitter
  - what are the fields of a HandlerIR node
  - how do variant builders work
  - how does the JSON backend prove pluggability
date: 2026-06-14
status: accepted
tags: [architecture, handler-ir, portability, backends, specentry]
evidence: "perl/LinkedSpec/HandlerVariantEmitter.pm — 10 variant builders return HandlerIR hashrefs; _emit_handler dispatches via %BACKEND_EMITTERS; _emit_handler_json proves pluggability"
reverify: "grep -n 'kind =>' perl/LinkedSpec/HandlerVariantEmitter.pm | head -15"
---

## Context

`LinkedSpec::SpecEntry` historically generated Perl source strings directly for each
runtime handler variant (AND, OR, REP, and their acode/bcode combinations). This
tight coupling to Perl code generation was the clearest backend-portability ceiling
in the project.

HandlerIR replaces direct source-string generation with a structured intermediate
representation. Variant builders produce **HandlerIR nodes** (hashref-based ASTs)
that describe handler structure — loop type, match expression, dispatch style,
lifecycle slot placement — without committing to any target language. A separate
**backend emitter** consumes the HandlerIR node and produces the final output.

## Decision

1. **HandlerIR is a hashref AST.** Every variant builder returns a plain hashref
   with well-defined keys. No Perl source strings in the IR layer.

2. **10 variant kinds.** The current variant catalog covers all combinations of
   rule mode (default/AND/OR/REP) and dispatch style (acode/bcode/mixed).

3. **Backend dispatch table.** `%BACKEND_EMITTERS` maps backend names to emitter
   functions. Perl is the default. JSON is a diagnostic backend proving the
   architecture is pluggable.

4. **Two-phase pipeline.** Compilation produces HandlerIR → emitter consumes
   HandlerIR. The IR is the stable contract; emitters are replaceable.

5. **This specification is the contract.** Every backend emitter must accept any
   valid HandlerIR node and produce behaviorally equivalent output.

## HandlerIR Node Structure

Every HandlerIR node is a hashref with these fields. Fields marked `optional`
may be absent or empty.

### Common Fields (all variants)

| Field | Type | Required | Description |
|---|---|---|---|
| `kind` | string | yes | Variant kind identifier (see §Variant Kinds) |
| `label` | string | yes | Rule label this handler is for |
| `parse_mode` | string | yes | `"seek"` or `"consume"` |
| `preamble` | string | no | I-block code (initialization) |
| `lxcode` | string | no | Loop-exit code (no-match / failure path) |
| `lscode` | string | no | Loop-start code (after successful match) |
| `lecode` | string | no | Loop-end code (before collection/return) |
| `ecode` | string | no | End code (exhaustion / final return) |
| `excode` | string | no | Extended-exit code (REP loop exhaustion fallback) |
| `itcode` | string | no | Iteration code (REP per-iteration collection) |

### Dispatch Fields

| Field | Type | Required | Description |
|---|---|---|---|
| `acodes_ref` | arrayref | for acode variants | Per-child action code strings, indexed by child position |
| `bcodes_ref` | hashref | for bcode variants | Per-child blind-call code strings, keyed by child label |
| `bcalls_ref` | arrayref | for bcode variants | Ordered list of child labels for blind-call dispatch |
| `and_icode` | string | no | AND I-block code (used when AND rules carry I-blocks) |

### Repetition Bounds (REP variants only)

| Field | Type | Required | Description |
|---|---|---|---|
| `rep_min` | int or undef | for REP variants | Minimum repetitions (0 for `*`, 1 for `+`, etc.) |
| `rep_max` | int or undef | for REP variants | Maximum repetitions (large int for unbounded) |

## Variant Kinds

### `default`
- **Rule mode**: `OR` (repeated choice) or bare `rule:` without mode suffix
- **Loop**: unbounded `while(1)` — exits on match failure
- **Match**: `LinkedRE::or` — alternation over all child regexes
- **Dispatch**: `if/elsif` chain over matched index → corresponding acode
- **Lifecycle slots active**: preamble, lxcode, lscode, lecode

### `and_bcode`
- **Rule mode**: `AND`
- **Loop**: `foreach` over ordered child list (`bcalls_ref`)
- **Match**: per-child regex, matched sequentially
- **Dispatch**: `if/elsif` chain by child label → corresponding bcode
- **Lifecycle slots active**: preamble, lxcode, lscode, lecode, ecode

### `and_single_acode`
- **Rule mode**: `AND` with a single child (optimization)
- **Match**: single match, `index==0` guard
- **Dispatch**: single acode at index 0
- **Lifecycle slots active**: preamble, lscode, lecode

### `and_acode_seq`
- **Rule mode**: `AND` with multiple acode children
- **Loop**: `while(idx < N)` — sequential iteration with index tracking
- **Match**: `LinkedRE::or` + index check — matches only when the matched index equals the expected sequential index
- **Dispatch**: `if/elsif` by matched index → corresponding acode
- **Lifecycle slots active**: preamble, lxcode, lscode, lecode, ecode

### `or_bcode`
- **Rule mode**: `OR` with blind-call children
- **Match**: per-child regex, first-match-wins
- **Loop**: `foreach` over child list, exits on first match
- **Dispatch**: matched child's bcode
- **Lifecycle slots active**: preamble, lxcode, lscode, lecode

### `or_acode`
- **Rule mode**: `OR` with single acode child (optimization)
- **Match**: single match, no index check needed
- **Dispatch**: single acode
- **Lifecycle slots active**: preamble, lxcode, lscode, lecode

### `rep_bcode`
- **Rule mode**: `OR+`, `OR*`, `OR?`, `OR{N,M}`, `:+`, `:*`, `:?`
- **Loop**: `while(1)` with repetition bounds (`rep_min`/`rep_max`)
- **Inner loop**: embeds an `or_bcode` handler as a coderef
- **Lifecycle slots active**: preamble, lxcode, lscode, lecode, ecode, excode, itcode

### `rep_and_bcode`
- **Rule mode**: `AND+`, `AND{N,M}`
- **Loop**: `while(1)` with repetition bounds
- **Inner loop**: embeds an `and_bcode` handler as a coderef
- **Lifecycle slots active**: preamble, lxcode, lscode, lecode, ecode, excode, itcode

### `rep_and_acode`
- **Rule mode**: `AND+`, `AND{N,M}` with acode children
- **Loop**: `while(1)` with repetition bounds
- **Inner loop**: embeds an `and_acode_seq` handler as a coderef
- **Lifecycle slots active**: preamble, lxcode, lscode, lecode, ecode, excode, itcode

### `rep_acode`
- **Rule mode**: `OR+`, `OR*`, `OR{N,M}` with acode children
- **Loop**: `while(1)` with repetition bounds
- **Match**: `LinkedRE::or` alternation
- **Dispatch**: `if/elsif` by matched index → corresponding acode
- **Lifecycle slots active**: preamble, lxcode, lscode, lecode, ecode, excode, itcode

## Emitter Contract

An emitter is a function `f($ir_hashref) → $output` where:

1. It receives a single HandlerIR node as a plain hashref.
2. It returns a string, data structure, or coderef — the backend determines the
   return type.
3. It must process all 10 variant kinds. Unknown kinds should produce a clear
   error, not a silent fallback.
4. It must respect all lifecycle slots that are present (non-empty string).
5. It must produce **behaviorally equivalent** output to the Perl emitter for the
   same HandlerIR input. The Phase 0 regression contract defines equivalence.

### Perl Emitter (`_emit_handler_perl`)

The default emitter. Consumes HandlerIR nodes and produces Perl source strings
identical to the pre-HandlerIR inline builders. Registered as the `'perl'`
backend in `%BACKEND_EMITTERS`.

### JSON Diagnostic Emitter (`_emit_handler_json`)

A proof-of-concept non-Perl backend. Serializes the HandlerIR node as canonical
pretty-printed JSON via `JSON::PP`. Registered as the `'json'` backend. Proves
that the IR → emitter contract is backend-neutral — the same HandlerIR node
produces dramatically different output under different emitters.

### Adding a New Backend

1. Write a function that accepts a HandlerIR hashref.
2. Handle all 10 variant kinds (or reject unsupported ones explicitly).
3. Produce output idiomatic for the target language (Rust source, Julia source,
   Dart source, etc.).
4. Register it in `%BACKEND_EMITTERS` under a backend name.
5. Thread the backend name through `SpecEntry` via `$deps->{backend}`.
6. Validate against the language-neutral test corpus (`tests/corpus/`).

## Lifecycle Slot Semantics

Lifecycle code strings in HandlerIR nodes are the **output of ActionIR lowering** —
they are already lowered to the target language (currently Perl). This is a known
coupling point: ActionIR lowering produces language-specific code strings.

The long-term decoupling path:
1. ActionIR lowering produces **lowered ActionIR** (a structured, language-neutral
   representation of what each lifecycle block does).
2. HandlerIR absorbs those structured nodes instead of lowered code strings.
3. Each backend emitter lowers the structured ActionIR to its target language.

For Phase 8, lifecycle slots remain lowered code strings. The HandlerIR decoupling
is at the **handler structure** level — loop type, dispatch style, slot placement —
which is already backend-neutral.

## Relationship to ActionIR

HandlerIR and ActionIR serve different roles:

| Layer | What it represents | Current output |
|---|---|---|
| ActionIR | What the user's DSL code **means** (declare, assign, return, if, switch, etc.) | Lowered Perl code strings |
| HandlerIR | How the parser **executes** (loop type, match expression, dispatch, lifecycle order) | Structured hashref AST |

ActionIR lowering happens first: `.spec` DSL → ActionIR scanner → canonical events →
lowered code strings. Then HandlerIR assembly: lowered code strings + rule metadata →
HandlerIR node. Finally, backend emission: HandlerIR node -> Perl/JSON/Rust/Dart/Julia/Lua.

## Current Limitations (Phase 8 awareness)

- **Lifecycle slots are lowered code strings**, not structured ASTs. A non-Perl
  backend must either re-lower these or accept Perl strings.
- **`LinkedRE::or` dependency**: Match expressions assume Perl regex dispatch.
  An abstraction layer is needed.
- **Accumulator convention**: `@$label` and `@collect` are Perl conventions.
  A language-neutral accumulator model is needed.
- **Repetition bounds use `10**9` for unbounded**: A sentinel constant, not an
  explicit "unbounded" marker. Ports should treat `rep_max >= 10**9` as unbounded.

These are documented so a Rust/Dart/Julia/Lua implementer knows where the Perl coupling
still exists and can plan their shim or reimplementation accordingly.

## Links

- [[language-agnostic-backend-vision]] — the multi-backend vision (ADR 0006)
- [[specentry-backend-portability-ceiling]] — why SpecEntry is the portability ceiling
- [[actionir-lowering-stack]] — how ActionIR lowers .spec DSL to code strings
- Formal grammar: `docs/linkedspec-book/src/appendix/formal-grammar.md`
- Implementation: `perl/LinkedSpec/HandlerVariantEmitter.pm`
- Backend handoff: `docs/linkedspec-book/src/appendix/` (Phase 8.7)
