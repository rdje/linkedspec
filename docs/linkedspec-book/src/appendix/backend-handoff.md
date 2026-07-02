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
Canonical wrappers `scalar(...)`/`array(...)`/`hash(...)` remain the destination
surface; short wrapper aliases `s(...)`/`a(...)`/`h(...)` are retired and should be reported
as unresolved helpers rather than normalized. Unsupported covered helper
forms now report unresolved-helper metadata instead of leaking as generated host-language
calls. Receiver-dot value chains now lower from AST `fluent_chain` nodes for the array,
hash, string, and number receiver families before the legacy receiver-dot text normalizers
run. Generalized return payloads now lower typed value/call/chain nodes through the same
AST traversal before raw fallback, while narrow untyped compatibility payloads still
remain migration debt. Assignment and mutation operator statements now consume typed AST
target/key/value fields before legacy fallback. Helper-call statements and returns now
consume typed AST `call` fields for `set`/`assign`, `set_key`, `push`, `push_value`,
`push_nonempty`, `return`, and `return_undef`, and array end-mutation receiver statements
consume typed AST `fluent_chain` fields. Expression-valued block side effects,
block-local returns, and final block expressions now consume typed block/statement AST
fields. Structured control-flow lowering now consumes typed AST fields for the if/when,
switch/case/default, and attached-while statement families. Standalone supported value
statements now produce canonical `VALUE_DROP` events: the backend computes the typed
value expression and intentionally discards the result. Unknown typed calls and
function-call receiver chains in return/value positions now use the unresolved-helper
diagnostic path instead of becoming generated host-language calls.
Top-level `fn name(args) { body }` definitions are now accepted and recorded in the Perl
reference descriptor registry. Each definition carries params, arity, source/body spans,
body source, and an ActionIR body AST. The registry rejects duplicate functions,
reserved names, built-in helper/control collisions, rule-label collisions, and invalid
or duplicate parameters before runtime. The Perl reference now resolves registered
exact-arity calls during value-expression lowering; wrong-arity registered calls remain
unresolved-helper diagnostics with zero raw fallback. Registered standalone calls and
receiver chains now lower as canonical `VALUE_DROP` statements on the Perl reference.
The Rust backend carries the same definitions through parsed and compiled registry
records and executes the MVP runtime surface: registered calls resolve before helper
fallback, run in fresh function-local stores, feed compatible receiver chains, and
discard standalone results.
The function surface is closed at that MVP boundary. New backends should implement
top-level `fn name(args) { ... }` with explicit parentheses and braced, value-oriented
bodies. Do not add alternate spellings (`function ... endfunction`, `fn ... endfn`),
optional zero-argument parentheses, brace-less bodies, caller-state-mutating functions,
recursive user functions, closures/lambdas/currying, or function namespaces unless a
future task-tree leaf and contract explicitly adopt them.

The remaining fallback boundary is not a backend pattern to copy. Malformed helper forms
already covered by the typed AST path report unresolved-helper metadata rather than host
calls. Retired helpers, non-DSL host-shaped statements, and a few narrow return payload
compatibility shapes remain fenced migration debt. Unknown typed calls and receiver
chains are reserved for user-defined function resolution and diagnostics, not broad
host-language fallback. In the Perl reference, return/value-position unknown calls
currently diagnose. Standalone registered calls/chains lower as `VALUE_DROP`, while
unregistered call-shaped statements remain raw compatibility debt. New backends should
follow the typed-AST model used by the Rust implementation from the start, including a
validated function registry before runtime resolution.

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
`SPEC-FORMAT-TERSE.4.3.2`, the corpus has 54 fixtures, including the two minimal shipped
`tclite.spec` cases restored by the default-mode repetition parity work; terse
receiver-chain fixtures for arrays, hashes, strings, numbers, aggregate wrapper quoting,
and block-valued receivers; numeric word aliases; and the shared Perl/Rust
`terse_4_3_2_user_function_runtime` fixture. Broader recursive shipped-spec parity,
including Lispish, remains tracked separately.

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
- An active `fn name(args) { ... }` definition surface owned by `spec.spec` and projected
  through the descriptor `functions` registry. The Perl reference currently uses a
  temporary pre-bootstrap extraction bridge; do not copy that bridge as the language
  contract. The accepted MVP is exact-arity, pure value/block functions with fresh
  function-local scope, no implicit caller capture, and registry resolution before
  unknown-helper fallback. Calls execute in value positions and compatible receiver
  chains; registered standalone calls compute and discard through `VALUE_DROP`. Recursion
  and unsupported function-body forms are diagnostics, not raw fallback.
- The Rust backend's parsed and compiled state records the same top-level function
  registry shape with parsed body `CodeBlock` values, and its runtime resolves registered
  calls before helper fallback with fresh function-local stores, receiver-chain
  continuation, standalone discard, and recursion diagnostics. The accepted MVP stops at
  explicit-paren, braced `fn` definitions; alternate spellings, omitted zero-arg parens,
  brace-less forms, statementful/caller-mutating functions, recursion support,
  closures/lambdas/currying, and namespaces remain deferred.
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

3. **User-function registry and resolver** — records top-level `fn name(args) { body }`
   definitions as validated AST-backed records before runtime. The registry must preserve
   definition order, expose definitions by name, reject helper/rule/reserved-name
   collisions, and resolve exact-arity value calls before unknown-helper fallback.

4. **Compiler** — transforms parsed entries and helper/action AST nodes into
   HandlerIR nodes. You can reuse the ActionIR lowering approach, but the input to
   lowering is structured AST/IR rather than raw helper source text.

5. **HandlerIR emitter** — consumes HandlerIR nodes and produces runnable code
   in your target language. Must handle all 10 variant kinds.

6. **Runtime** — the execution engine:
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
