---
id: working-vars-no-strict-need-my-lexical
title: "Generated rule handlers run WITHOUT `use strict`, and a rule's I-block + all edges + LX compile into ONE lexical scope. So a `.spec` working variable referenced via scalar(x)/array(x)/hash(x) needs exactly one `my $x`/`@x`/`%x` emitted in the handler preamble (run once). declare(type, name) supplies that today; WITHOUT a declare the bare name silently becomes a leaky PACKAGE global (state-leaks across parser invocations and recursion), it does NOT fail loudly. This is the engine grounding for SPEC-FORMAT-TERSE.1.1 (auto-existing variables): auto-collect wrapper-referenced var names rule-wide and inject the `my` into the preamble, deduped vs the @<label> accumulator and any explicit declare."
answers:
  - "do generated linkedspec rule handlers run under use strict"
  - "what happens to a .spec working variable used without declare"
  - "what does declare actually do at codegen / why does declare matter"
  - "are a rule's I-block, edges, and LX in the same lexical scope"
  - "where are working-variable my-declarations emitted in the generated handler"
  - "what is the engine basis for auto-existing variables (SPEC-FORMAT-TERSE.1.1)"
  - "why would a bare working variable leak across parser invocations or recursion"
  - "how does scalar(x)/array(x)/hash(x) map to a perl sigil in generated handler code"
  - "why can an inline my not be used for a .spec accumulator variable"
date: 2026-06-23
status: confirmed
tags: [engine, codegen, SpecEntry, dsl, variables, declare, spec-format-terse, strict, SPEC-FORMAT-TERSE]
evidence: "TOOLBOX dump_parser_source probes 2026-06-23 (scratchpad probe_autovar*.pl, dump-don't-transcribe). (1) `declare(scalar, count=0)` -> `my $count = 0 ;` emitted once right after the auto `my @<label>;` accumulator, BEFORE the `while(1)` dispatch loop; edges (`$count = ...`) and `LX` (`return $count ;`) reference it -> the whole rule is ONE sub / ONE lexical scope. (2) `declare(array, items)` -> `my @items ;` once in the preamble; `push @items, ...` across edges; `return [@items]` in LX -> accumulator works because the `my` runs once (an inline per-edge `my` would reset it each dispatch iteration). (3) Same spec with the declare line removed still BUILDS (returns a CODE parser) but the generated handler has a bare `$count`/`@items` with NO `my`; SpecEntry.pm has neither `use strict` nor `no strict` (grep count 0), so eval'd handlers are non-strict and the bare name is a package global -> the no-declare scalar counter returns undef (uninitialized global), not a loud failure. Files: perl/LinkedSpec/SpecEntry.pm `_build_handler_preamble` (emits `my @<label>;`) + `_build_runtime_handler` (eval of the sub source), perl/LinkedSpec/ActionIR/DeclareMethod.pm (`_extract_declare_statement_from_method_expr`, `_lower_declare_*`), perl/LinkedSpec/ActionIR/MethodLowering.pm `_lower_typed_declare_statement` (`my ${sigil}$name [= init]`)."
reverify: "grep -c 'use strict' perl/LinkedSpec/SpecEntry.pm   # 0 -> generated handlers are non-strict; then dump a declare(array,items) spec via dump_parser_source to see `my @items ;` once in the preamble"
---

# Working variables: non-strict handlers, one lexical scope, `my` in the preamble

**Confirmed 2026-06-23** via `dump_parser_source` probes (`SPEC-FORMAT-TERSE.1.1` analysis;
direction ratified in ADR [0007](../decisions/0007-spec-format-terse-direction.md)). This is the
engine grounding for the terse-format leaf "auto-existing variables".

## What the generated handler looks like

A whole rule — its `I` block, every `->`/`=>` edge body, and its `LX` (and other lifecycle
blocks) — compiles into **one** `sub { ... }` with **one** lexical scope (built by
`SpecEntry::_build_runtime_handler`, preamble by `_build_handler_preamble`). The preamble emits the
`$descr/$STRING/$info`, the `IMATCH*` locals, and the per-rule accumulator `my @<label>;`. The
`I`-block code is lowered right after that, then a `while(1)` dispatch loop matches and runs edge
code, and the no-match branch runs `LX`. Example (counter, dump-don't-transcribe):

```perl
my @top;
 my $count = 0 ;             # declare(scalar, count=0)
 while (1) {
  my $minfo = LinkedRE::or($STRING, $$descr{dependency_regex_map}{top}, $info);
  unless($minfo) { return $count ; }            # LX: return(scalar(count))
  ...
  if($$minfo{index} == 0) { $count = do { ...num_add... } }   # edge: assign(scalar(count), num_add(...))
 }
```

So `declare(scalar,x)`→`my $x`, `declare(array,x)`→`my @x`, `declare(hash,x)`→`my %x` (joined with
`; `), emitted once in the preamble region. `scalar(x)`/`array(x)`/`hash(x)` reference that var
with the `$`/`@`/`%` sigil. Because they live in one scope, a variable declared in `I {}` is visible
to every edge and to `LX`.

## Why this matters (the non-strict hazard)

`perl/LinkedSpec/SpecEntry.pm` has **neither `use strict` nor `no strict`**, so the eval'd handler
source runs **non-strict**. Remove the `declare` and the handler still compiles — but the bare
`$count`/`@items` is now a **package global**, not a lexical. Consequences:

- **State leak across invocations:** a package-global accumulator is shared by every `$parser->()`
  call and every recursive re-entry of the rule — wrong results, not a clean error.
- **No loud failure:** the no-declare scalar counter just returns `undef` (the global was never
  initialised; `num_add(undef,1)` → `undef`), masking the bug.

`declare(...)` exists precisely to make the working variable a **per-invocation `my` lexical**.

## The SPEC-FORMAT-TERSE.1.1 design that follows

"Auto-existing variables" = the engine auto-supplies the `my` so `declare(...)` becomes optional:

- **Collect rule-wide:** scan every action-code block of a rule for typed wrapper references
  `scalar(NAME)`/`s(NAME)` (scalar), `array(NAME)`/`a(NAME)` (array), `hash(NAME)`/`h(NAME)` (hash)
  where `NAME` is a single bare identifier (the variable form — not the 2-arg `scalar(container,key)`
  read).
- **Inject once in the preamble** (NOT inline per edge — an inline `my` in an edge would re-run every
  dispatch iteration and reset an accumulator).
- **Dedupe** against the `@<label>` accumulator and any name already covered by an explicit
  `declare(...)` (which keeps emitting its own `my`, possibly with an initializer) — avoid a double
  `my`. Preserve the all-target ActionIR-ready invariant (ratio 1.0000, ADR
  [0002](../decisions/0002-all-target-actionir-ready-invariant.md)).
- **Lockstep:** the Rust variant owes the same auto-existence (ADR
  [0006](../decisions/0006-multi-backend-vision.md)); tracked as a separate parity leaf.

## Links

- Tree: [[SPEC-FORMAT-TERSE]] (leaf `.1.1` → `.1.1.1` Perl / `.1.1.2` Rust parity).
- Decision: [0007](../decisions/0007-spec-format-terse-direction.md) (terse direction, gradual-alias).
- Related: [[specentry-backend-portability-ceiling]], [[actionir-lowering-stack]],
  [[spec-format-brainstorm-rounds-1-3]], [[phase0-all-target-actionir-ready-invariant]].
