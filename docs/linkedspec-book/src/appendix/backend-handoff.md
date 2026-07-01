# Backend Handoff

This chapter is the **single entry point** for anyone building a LinkedSpec backend
in a new language (Rust, Julia, Dart, etc.). It links every specification, contract,
and test artifact you need — in reading order.

## What You're Building

A LinkedSpec backend compiles `.spec` grammar files into runnable parsers. It must:

1. Parse `.spec` files according to the formal grammar.
2. Parse helper/action language text into typed AST/IR nodes before lowering,
   interpretation, or code emission.
3. Compile the parsed model into runtime handlers via the HandlerIR pipeline.
4. Execute those handlers with identical semantics to the Perl reference.
5. Pass the language-neutral test corpus.

Text-to-AST is a backend conformance rule, not an optional implementation style.
Do not build a backend by applying textual helper rewrites directly into host-language
source. The Perl reference now has an additive `LinkedSpec::ActionIR::AST` parser seam
for calls, literals, variables, direct access, shape literals, block values,
assignments, expression statements, and receiver-dot chains. Its `MethodLowering`
consumer has started using that AST for non-call value expressions: primitive literals,
scoped bare scalar reads, direct indexed/nested access, shape literals, and block
values. It also lowers value-only helper-call composition from AST `call` nodes for
scalar normalization, string predicate/composition, coalesce/concat, and scalar-argument
numeric helpers. It also lowers aggregate-wrapper, collection/reducer, and hash helper
calls from AST `call` nodes while preserving their existing symbol/value slot policy.
Deprecated wrapper aliases such as `scalar(...)`/`array(...)`/`hash(...)` remain
compatibility syntax, not the canonical destination surface. Receiver-dot chains,
statement/control lowering, unsupported covered-call diagnostics, and remaining
return-payload substitution are still migrating family by family, so any remaining
text-to-text lowering is migration debt rather than a backend pattern to copy.
New backends should follow the typed-AST model used by the Rust implementation.

You do **not** need to read the Perl source code. Every behavioral contract is
specified in the documents below.

## Reading Order

### Step 1: Understand the Big Picture
Read the [ADR 0006](../../../docs/decisions/0006-multi-backend-vision.md) — the multi-backend
decision record. It defines the lockstep contract: same `.spec` files, same semantics,
same test corpus across all backends.

### Step 2: Learn the `.spec` Language
Read the [Formal `.spec` Grammar](formal-grammar.md). This is the definitive syntax
reference. A valid backend must accept exactly this language. No Perl bootstrap parser
knowledge is needed.

### Step 3: Understand Runtime Behavior
Read the [Runtime Semantics](runtime-semantics.md). This defines how `.spec` rules
execute: parse modes, lifecycles, BACKTRACK, accumulators, edge dispatch, repetition
bounds, and determinism guarantees. Two independent implementations of this document
must produce identical parser behavior.

### Step 4: Implement the Helper Surface
Read the [Helper Contract Catalog](helper-contract-catalog.md). Every helper function
(100+ across 10 families) is documented with its signature, type contract, behavioral
semantics, and edge cases. Implement these helpers in your target language — they
are the building blocks users write in `.spec` lifecycle blocks.

### Step 5: Implement HandlerIR
Read the [HandlerIR Specification](../../../docs/knowledge/handler-ir-design.md). The
HandlerIR is the structured AST between the compiler and code generation. Your backend
writes an **emitter** that consumes HandlerIR nodes and produces runnable code in
your language. The JSON diagnostic backend (`_emit_handler_json`) proves the pattern.

### Step 6: Validate Against the Test Corpus
Run your backend against `tests/corpus/`. Every entry has an `input.spec`,
`input.txt`, and `expected.json`. Your backend is compliant when it produces
structurally equivalent output for every entry.

The checked-in Rust corpus is kept green while parity work lands incrementally. As of
`SPEC-FORMAT-TERSE.2.3.5.5`, the corpus has 52 fixtures, including the two minimal shipped
`tclite.spec` cases restored by the default-mode repetition parity work and the newer terse
receiver-chain fixtures for arrays, hashes, strings, numbers, aggregate wrapper quoting, and
block-valued receivers. Broader recursive shipped-spec parity, including Lispish, remains
tracked separately.

## Architecture Overview

```
.spec file
    │
    ▼
┌─────────────────────────┐
│  Compiler (language-     │
│  specific but spec-      │
│  driven — see spec.spec) │
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│  Parsed .spec +          │  ← typed AST/IR, never raw textual helper rewrites
│  helper/action AST       │
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│  ActionIR Lowering       │  ← Backend-neutral (helpers → canonical events)
│  (100+ helpers, 10       │
│   families)              │
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│  HandlerIR               │  ← The decoupling seam
│  (10 variant kinds,      │
│   structured AST)        │
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│  Backend Emitter         │  ← YOUR CODE HERE
│  (Rust / Julia / Dart)   │
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│  Runtime                 │  ← Language-specific runtime
│  (regex engine, memory   │
│   model, I/O)            │
└─────────────────────────┘
```

## What the Perl Reference Provides

The Perl implementation is the **reference** — the canonical behavioral oracle.
It provides:

- A working compiler pipeline you can study for architecture understanding.
- `spec.spec` — a self-hosted grammar that can bootstrap a new compiler.
- `t/phase0_regression.t` — comprehensive regression tests.
- Phase 0 baseline showing all 20 shipped specs compile at `language_agnostic_ready_ratio == 1.0000`.

## What You Must Build

1. **`.spec` parser** — reads `.spec` files and produces parsed rule entries.
   Can be bootstrap-driven (hardcoded grammar) or self-hosted (parse spec.spec
   with itself, once bootstrapped).

2. **Helper/action AST parser** — parses lifecycle/action helper code into typed
   expression and statement nodes. Calls, literals, variables, blocks, direct
   access, assignments, and receiver-dot chains must be represented structurally.
   Text-to-text helper rewriting is not a conforming design for new backends.

3. **Compiler** — transforms parsed entries and helper/action AST nodes into
   HandlerIR nodes. You can reuse the ActionIR lowering approach, but the input to
   lowering is structured AST/IR rather than raw helper source text.

4. **HandlerIR emitter** — consumes HandlerIR nodes and produces runnable code
   in your target language. Must handle all 10 variant kinds.

5. **Runtime** — the execution engine:
   - Regex engine with position tracking (equivalent to `//gcp` and `\G` anchoring).
   - Accumulator model (arrays, hashes, scalars).
   - Lifecycle execution engine (I/LS/LE/E/EX/IT/LX ordering).
   - BACKTRACK (local cursor save/restore).
   - Zero-progress guard.

6. **Test harness** — runs `tests/corpus/` entries and compares output to
   `expected.json`.

## Practical Notes

### Regex Engine
The biggest implementation dependency. LinkedSpec requires:
- Position-tracked matching (set/query current match position).
- Ungrounded matching (match anywhere) and anchored matching (match at position).
- Identification of **which** alternative matched in a group.
- Capture groups (indexed and named).

If your target language's regex engine doesn't support embedded code position
tracking, you may need to iterate alternatives individually rather than
compiling a combined alternation.

### Memory Model
LinkedSpec uses mutable working variables (scalars, arrays, hashes) within
rule scope. These are declare-and-assign, not functional. Your runtime needs
a variable store per rule invocation.

### Determinism
All operations must be deterministic. Specifically:
- No random number generation.
- Hash key iteration must be sorted (not insertion-order or random).
- First-match-wins for OR dispatch.

## Specification Index

| Document | Location | What it defines |
|---|---|---|
| Multi-backend ADR | `docs/decisions/0006-multi-backend-vision.md` | Vision, lockstep contract, reach matrix |
| Formal `.spec` Grammar | `docs/linkedspec-book/src/appendix/formal-grammar.md` | Accepted `.spec` syntax |
| HandlerIR Spec | `docs/knowledge/handler-ir-design.md` | HandlerIR node structure and emitter contract |
| Helper Contract Catalog | `docs/linkedspec-book/src/appendix/helper-contract-catalog.md` | Every helper's behavioral contract |
| Runtime Semantics | `docs/linkedspec-book/src/appendix/runtime-semantics.md` | Parse modes, lifecycles, dispatch |
| Test Corpus | `tests/corpus/` | Language-neutral compliance tests |

## Handoff Checklist

Before starting a new backend, verify:
- [ ] You've read all six specification documents above.
- [ ] You understand the `.spec` language syntax (formal grammar).
- [ ] You understand the runtime execution model (runtime semantics).
- [ ] You can implement all 100+ helpers (helper catalog).
- [ ] You can implement a HandlerIR emitter for all 10 variant kinds.
- [ ] You have a regex engine capable of position-tracked alternation matching.
- [ ] You've studied the test corpus format and know how compliance is measured.
- [ ] You understand that `.spec` files are the universal contract — no
      per-backend dialects.
