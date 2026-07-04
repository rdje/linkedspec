# ActionIR Lowering Mental Model

ActionIR is the bridge between LinkedSpec action syntax and emitted runtime code.

It exists because the project does not want `.spec` files to remain tied forever to raw Perl fragments. The target is a cleaner semantic layer:

```text
.spec helper DSL -> canonical ActionIR -> emitted backend code
```

Today the emitted backend is Perl. The direction is backend-neutrality.

## Why not just keep raw Perl?

Raw Perl is powerful, but it has a cost:

- it is hard to validate structurally
- it is hard to translate to non-Perl backends
- it hides parser intent inside host-language details
- it makes examples harder for new users to generalize

Helper DSL makes common parser actions explicit.

Instead of asking readers to understand a substring expression, a mutable array push, and a return shape all at once, a rule can say:

```text
name = entry_group(0);
push(array(items), :name);
return(hash("kind", "names", "items", copy(array(items))));
```

That is still compact, but it is more self-describing.

## A simple lowering example

Source-level helper DSL:

```text
name = entry_group(0);
return(hash("kind", "token", "name", :name));
```

Semantic reading:

- write the first entry capture group to local scalar `name`
- return a structured payload with a fixed `kind` and the captured `name`

The exact emitted Perl is an implementation detail for most users. What matters is that these helper forms describe operations LinkedSpec can reason about.

## Canonical versus compatibility forms

LinkedSpec still recognizes older compatibility forms because real specs exist and migrations are incremental.

However, new public examples should prefer canonical helper forms:

```text
retv = call(Child);
push(array(items), :retv);
```

over raw or compatibility-heavy shapes such as direct Perl assignment and manual array mutation.

Compatibility is useful for migration. It should not be the teaching default.

## What counts as a good helper form?

A good helper form should make these questions easy to answer:

- What value is being read?
- What value is being written?
- Which parser boundary or mark is being used?
- Does the helper mutate a boundary or only read it?
- Is the result a scalar, array, hash, boolean, or rule call?

That is why recent naming work strongly favors explicit names such as:

- `capture_rest_from(name)`
- `capture_take_until_cursor_len_from(name)`
- `dependency_regex_map`
- `dependency_refs`

Names should reduce guessing.

## How to learn the surface

Start with the core families:

- `set(...)` for writing values
- `return(...)` for returning payloads
- `...`, `array(...)`, `hash(...)` for value construction
- `entry_*` and `match_*` readers for match data
- `capture_*` and `mark_*` helpers for parser boundary work
- `if(...)` and `switch` helpers for structured control flow

Then move into the more specialized helper families as needed.

## The lowering pipeline

The lowering *pipeline* — discover which helper contracts are present, split statements, canonicalize helpers into ActionIR events, then dispatch each to a lowering owner before emitting backend code — is a **backend-neutral** sequence. The specific owner module names and counts in this section (`ActionIR::Scanner`, `ScannerCore`, `StatementSplit`, `CanonicalEvents`, `RewritePipeline`, the per-family lowering owners, and `ActionIR::Contracts` with its 2,110 lines / 158 contracts) are the **Perl reference backend's** realization of those stages; another backend organizes the same scan → split → canonicalize → lower → emit flow in its own modules.

ActionIR lowering is not one monolithic pass. It flows through a pipeline of owners, each responsible for one stage:

```text
source rule paragraph text
  -> Scanner (contract discovery)
  -> StatementSplit (safe statement splitting)
  -> CanonicalEvents (normalize helpers into canonical ActionIR)
  -> RewritePipeline (glue scan/classify/lower phases)
  -> FlowExpr / ValueExpr / ControlFlow / MethodLowering / DeclareMethod / ArrayPipeline
  -> Emit (final backend code generation — Perl in the reference backend)
```

### Scanner

`ActionIR::Scanner` discovers which helper contracts are present in a rule's action text. It uses a registry of scanner rule families (`PrimitiveBasicRules`, `PrimitivePipelineRules`, `FlowRules`, `LegacyRules`) to match helper syntax patterns and classify them into contract families. `ScannerCore` is the single source of truth for the scanner dependency contract — the mapping between recognized helper patterns and their lowering handlers.

### StatementSplit

`ActionIR::StatementSplit` splits action text into individual statements safe for independent lowering. This is important because a single action block can contain multiple helper calls (`set(...)`, `push(...)`, `return(...)`) that must be lowered separately.

The separator contract is deliberately narrow: top-level semicolons split statements,
and top-level newlines split helper statements when no semicolon is present. Multiple
helper statements written on one physical line still need semicolons; plain spaces do not
create a boundary. Nested semicolons inside expression payloads stay inside the payload.

### CanonicalEvents

`ActionIR::CanonicalEvents` normalizes recognized helper calls into canonical ActionIR event records. Each event carries a contract ID, resolved arguments, and metadata needed by the later lowering stages. Compatibility aliases (older helper names) are normalized to canonical forms here.

### RewritePipeline

`ActionIR::RewritePipeline` glues the scan, classify, and lower phases together. It orchestrates the flow: scan for contracts, split statements, produce canonical events, and dispatch to the appropriate lowering owner for each event.

At `debug` trace level, the Perl reference pipeline reports these stages with
`actionir:<owner>:<phase>:<label>:<decision>` decisions. That trace can show scanner helper-event discovery,
canonical queue matches or RAW_PERL fallbacks, unresolved helper diagnostics, rewrite-rule construction, compact
flow/value/array/declaration/control-flow lowering choices, source-span or contract skips, normal statement
rewrites, unmatched helper events, implicit attached-if closure insertion, and `MethodLowering` helper-family,
assignment/mutation, receiver-chain, AST-vs-string fallback, and unsupported-helper decisions.

The planned Perl reference compile/ActionIR owner trace coverage is closed through MethodLowering; the remaining
trace work is cross-variant parity rather than another known opaque ActionIR owner.

### Lowering owners

Each contract family has a dedicated lowering owner:

- `FlowExpr` — flow-expression helpers (method chains, fluent continuations)
- `ValueExpr` — value construction (`...`, `array(...)`, `hash(...)`)
- `ControlFlow` — structured control flow (`if/elseif/else/endif`, `switch/case/default/endswitch`)
- `MethodLowering` — method-like helper lowering to Perl code
- `DeclareMethod` — legacy declaration helpers (`declare(...)`, `declare_s(...)`, `declare_a(...)`, `declare_h(...)`)
- `ArrayPipeline` — array pipeline operations (filter, map, sort, etc.)

### Contracts catalog

`ActionIR::Contracts` (2,110 lines, 158 contracts) is the contract catalog. It defines every supported helper surface — its name, its ActionIR node type, its diagnostic identity, and its unresolved pattern (the template matched before lowering resolves it). The 8 contract families are:

| Family | Contracts | Purpose |
| --- | --- | --- |
| capture_and_backtrack | 103 | Boundary capture, mark, cursor, and BACKTRACK helpers |
| call_and_dispatch | ~11 | Rule dispatch and call helpers |
| return | 4 | Return value construction |
| passthrough_ir | 12 | Compatibility pass-through surfaces |
| emit_and_declare | 7 | Declaration and emit helpers |
| array_pipeline | 8 | Array pipeline operations |
| flow_control | 9 | Structured control flow |
| assignment_and_regex | 4 | Assignment and regex-slot helpers |

Understanding the pipeline matters because it explains why a helper call in a `.spec` rule is not just a string substitution — it passes through discovery, normalization, classification, and lowering before becoming emitted backend code.

## Deeper reference

The repo-root ActionIR guides are the exhaustive working references while this book grows toward absorbing that surface:

- `USER_GUIDE_ActionIR_Contracts.md` — full contract catalog (158 contracts across 8 families)
- `USER_GUIDE_ActionIR_MethodLowering.md` — method lowering pipeline
- `USER_GUIDE_ActionIR_EmittedPerlReference.md` — emitted Perl for every supported helper
- `USER_GUIDE_RuleModesAndSplit.md` — rule modes and split-boundary details

These guides go deeper than the book chapters and include exact emitted-Perl shapes for compatibility and migration work.
