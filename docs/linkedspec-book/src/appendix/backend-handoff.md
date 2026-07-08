# Backend Handoff

This chapter is the **single entry point** for anyone building a LinkedSpec backend
in a new language (Rust, Julia, Dart, etc.). It links every specification, contract,
and test artifact you need — in reading order.

## What You're Building

A LinkedSpec backend compiles `.spec` grammar files into runnable parsers. It must:

1. Parse `.spec` files according to the formal grammar.
2. Parse helper/action language text into typed AST/IR nodes before lowering,
   interpretation, or code emission.
3. Preserve staged linked parsing semantics: extracted text payloads can become
   source-provenance parse jobs routed to later `.spec` parsers.
4. Compile the parsed model into runtime handlers via the HandlerIR pipeline.
5. Execute those handlers with identical semantics to the Perl reference.
6. Pass the language-neutral test corpus.

The backend contract is implementation-language neutral. The same `.spec` source,
AST payloads, parse-job metadata, descriptors, diagnostics, and parser entry semantics
apply whether the implementation is Perl5, Raku, Rust, Julia, Lua, Dart, Zig, Go, or a
future language.

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
Bare scalar reads plus canonical aggregate wrappers `array(...)`/`hash(...)` remain the destination
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

Staged linked parsing is also a backend conformance rule. A backend must be able to
represent an AST node that contains extracted text and a parse intent, then dispatch that
payload to a deterministic next parser while preserving source spans and parent-node
context. One stage can emit several different parse-job kinds; each kind may route to a
different next-stage `.spec`. This is different from spec imports: imports compose grammar
files, while staged dispatch parses runtime payload text already extracted by a parser.
For `.spec` language evolution, `specs/spec.spec` is the first authoritative grammar and
later `.spec` stages derive from its parsed payloads rather than a competing permanent
bootstrap grammar.

The accepted parse-job annotation design is `parse_job(text_expr, options)` once
implemented. It yields a marker value plus sidecar metadata: deterministic job id, parent
AST path, node kind, payload kind, exact text, source span, parser spec id, optional top
rule, result policy, and failure policy. Result policies are `replace_marker`,
`replace_field`, `sibling_field`, and `append_child`; failure policies are `fail`,
`keep_text`, and `diagnostic_node`. Backends must treat this as a neutral metadata
contract, not a host-language callback surface. Current shipped parsers do not yet accept
or execute `parse_job(...)`.

The accepted staged dispatch design is also neutral. Implement a registry with
`resolve`, `load`, `compile`, and `execute` operations. Resolution order is parent
import aliases/composed identities, declaring-spec-relative paths, configured search
roots, then explicit registry providers. Cache compiled parsers by normalized spec
identity, content digest, import/include graph fingerprint, selected top rule, `.spec`
language version, helper/action contract version, staged parsing contract version, and
backend capability set. Dispatch jobs in stable parent-AST-path/source-span/job-id order,
and diagnose active-chain cycles that repeat spec identity, top rule, payload digest, and
source span. Current shipped parsers implement only the first narrow function-body
provider; general staged registry/provider search and recursive dispatch queues remain
future work.

The first prototype target is user-function body payloads. A backend should treat that
as a narrow proof of the neutral staged contract: `specs/spec.spec` extracts a bounded
body payload, a parse job names the next parser/top rule, source provenance is preserved,
and the refined body AST is stitched back deterministically. Do not copy a Perl or Rust
bridge as the semantic model; host implementation details are adapters around the
`.spec`/AST contract.

The proof must include an AST-shape oracle for the returned function-definition node.
Runtime equality alone is not enough: a backend must be able to predict and then assert
the `function_definition` AST shape, including the refined body payload and provenance
fields that staged dispatch is responsible for. That oracle should be fed by a large
variation suite for the spec rule returning the AST: whitespace forms, arity forms,
nested blocks, quoted strings, regex-looking payloads, adjacency to rules or other
definitions, and invalid definitions with expected diagnostics. Use a dedicated small
spec file/top rule for those focused AST-shape tests when that gives a tighter harness.

For backend implementers, the expected harness is a wrapper top rule that dispatches to
a normal `function_definition` rule and returns collected nodes. The function rule must
not rely on compacted numbered captures for optional fields. The neutral returned node
uses parsed parameter arrays, exact inner body text, neutral source/body spans, a
function-body parse-job field, and a stitched body AST after dispatch.

The current provenance seam is the neutral `body_payload` plus `body_parse_job` returned
by `specs/user_function_definition.spec`. Neither field is a backend callback.
`body_payload` contains exact function-body text,
half-open source span, source-slice provenance, source-order parent path, function name,
params, arity, `node_kind = function_definition`, and `payload_kind = function_body`.
`body_parse_job` is the parse-intent sidecar for that payload: deterministic job id,
parent AST path, parser spec identity, top rule, result/failure policies, exact text,
source span, and diagnostic ownership. The Perl reference and Rust runtime both consume
that spec-returned AST today and normalize the source-order path/job id once the function
ordinal is known. They dispatch that job through the minimal staged parser registry:
`resolve` maps `actionir-body.spec` to a built-in provider identity, `load` records the
adapter contract digest, `compile` selects top rule `action_block`, and `execute` returns
the body `action_block` AST stitched into `body_ast`. General provider search roots,
imports, and recursive staged queues remain future work. The spec's body shell is a
linked opener/closer parse: `body_brace`
handles nested brace islands, quoted strings, comments, and regex literals are protected
before brace dispatch, and the outer close is matched by `function_definition[1]`.
Backends must converge on this same spec-defined AST contract instead of maintaining
host-language definition grammars as the staged dispatch queue becomes portable.

Rust is interpreted rather than generated Perl source, so the inspectable artifact is
the compiled rule table plus lifecycle/action expression AST rather than emitted handler
code. The Rust adapter still follows the same contract: it executes
`specs/user_function_definition.spec`, validates the returned nodes, strips definition
spans, dispatches normalized body parse jobs through the staged registry adapter, and
only then passes rule-only source to the core parser.

Spec import/composition is a separate backend conformance target once implemented. The
accepted design uses file-scope `import "path.spec" as alias` and
`include "path.spec"` directives. `import` creates a qualified namespace such as
`alias.Rule`; `include` performs a structured merge into the current unqualified
namespace. Implement this as parsed `.spec` composition, not raw text concatenation.
Backends must agree on resolution order, normalized spec identities, duplicate-name
diagnostics, import-cycle diagnostics, source provenance, and descriptor fingerprints.
Current shipped parsers do not yet accept these directives, so do not treat them as a
runtime requirement until the implementation leaf lands.

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

The Rust backend currently executes an interpreted structural model
(`CompiledSpec`/`CompiledRule`) rather than direct generated Rust handlers. Its
generated-source path is tracked separately under `RUST-PARITY.8`: `.8.1`
split the work, `.8.2` added the minimal scaffold/compile-run proof, and
`.8.3.1` added a generated rule-family plan. `.8.3.2` made default/OR acode
families run directly, `.8.3.3` made AND single/sequential acode families run
directly while enforcing ordered non-repetition AND regex/acode sequence
semantics, and `.8.3.4` made AND/OR bcode families run directly with shared
blind-edge tail execution. `.8.3.5` closed the non-repetition matrix by making
generated-plan routing exhaustive for all six non-REP generated families and by
asserting that family coverage in the source-emitter matrix. `.8.4` added direct
generated execution for the four explicit REP subfamilies (`RepAcode`,
`RepBcode`, `RepAndAcode`, and `RepAndBcode`), including bounded repetition,
zero-progress termination, and same-position recursive-call guard coverage.
`.8.5` integrated the generated-source proof with the oracle corpus: the
source-emitter test still compiles and runs an all-family generated matrix, and
it now also compiles/runs a curated subset selected from the checked-in
`rust/linkedspec-runtime/tests/corpus/manifest.json`. That generated-source corpus subset includes
authored proof fixtures, terse helper/control/user-function fixtures, and
shipped `tclite`/`portmap` smokes. This is deliberately a subset proof; the
full 96-fixture corpus remains the Rust interpreter oracle gate unless a later
leaf explicitly broadens generated-source corpus coverage.
`RUST-PARITY.9` closed the Rust follow-on documentation state around that
boundary: interpreter parity is the 96-fixture corpus contract, while generated
source currently proves direct structural-family execution plus the curated
manifest subset.

### Step 6: Validate Against the Test Corpus
Run your backend against the manifest-backed corpus under
`rust/linkedspec-runtime/tests/corpus/`. The corpus root has a `manifest.json`
with `case_count` and the ordered `cases` list; every manifest entry has an
`input.spec`, `input.txt`, and `expected.json`. Your backend is compliant with
the current corpus gate when it produces structurally equivalent output for
every manifest entry, and its runner rejects missing fixture directories or
stale extra fixture directories.

The checked-in Rust corpus is kept green while parity work lands incrementally. It now has
96 fixtures, including the `with(...) { ... }` helper, `.with() { ... }` receiver trailing block case, and hash-tree traversal receiver block case; the two minimal shipped `tclite.spec` cases restored by the
default-mode repetition parity work; the shipped `Lispish.spec` `lispish_x_y` case now
migrated to direct nested access; the first `hlink_substitution` raw-string cases plus the
JSON-safe `{abc}` curly-brace delimiter case; `lib_reader.spec` scalar-attribute and
comma-list attribute cases; `portmap.spec` bare, bit, slice, constant, and concatenation
cases; `ebnf.spec` expression-rule and logging-annotation payload cases; four `spec.spec`
smokes for minimal rules, action edges, user-function definitions, and comments; seven
RTL/plugin/legacy safety smokes covering `regdef`, `tablegrep`, `simenv`, `vhdl`,
`ds_vhistory`, empty `pplugin`, and empty `tkgui`; terse receiver-chain fixtures for
arrays, hashes, strings, numbers, aggregate wrapper quoting, and block-valued receivers;
array-tree traversal receiver blocks are implemented on the Perl reference and remain pending for the Rust
interpreter/oracle until `SPEC-FORMAT-TERSE.13.3`;
numeric word aliases; arithmetic/comparison symbol callees; the terse bare-read `name`
fixture for scalar reads, scalar mutation targets, and scalar-held shape payloads;
explicit string comparisons; assignment-expression fixtures; and the shared Perl/Rust
user-function runtime fixture; plus recursive top-rule/body value fixtures for wrapper-body
recursion, nested top-rule `LX` recursion, and top-rule sequence recursion.
`RUST-PARITY.7.4` finalized the corpus guard: the generator writes
`manifest.json`, and the Rust runner fails malformed manifests, duplicate case
names, missing manifest entries, or stale extra fixture directories. The richer
legacy/plugin mismatches above remain follow-up blockers until a narrower parity
owner promotes them safely.

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
- Phase 0 baseline showing all 21 shipped specs compile at `language_agnostic_ready_ratio == 1.0000`.

## What You Must Build

1. **`.spec` parser** — reads `.spec` files and produces parsed rule entries.
   Can be bootstrap-driven (hardcoded grammar) or self-hosted (parse spec.spec
   with itself, once bootstrapped).

2. **Staged parse-job model** — records source-provenance payload text, parser spec id,
   optional top rule, parent AST path, payload kind, result insertion policy, and failure
   behavior. Parser resolution must be deterministic and diagnostics must report both the
   selected next-stage parser and the original parent source span.

   Once implemented, the portable authoring marker is `parse_job(text_expr, options)`.
   It creates a marker value plus sidecar metadata rather than executing the next parser
   inline.

3. **Staged parser registry and queue** — resolves parser spec ids deterministically,
   caches compiled next-stage parsers by content/version/capability fingerprints,
   dispatches jobs in stable queue order, isolates runtime contexts, stitches results,
   and diagnoses cycles.

4. **Spec import/composition graph** — once implemented, loads file-scope `import` and
   `include` directives as parsed `.spec` dependencies with aliases, structured namespace
   merges, cycle diagnostics, source provenance, and descriptor fingerprints.

5. **Helper/action AST parser** — parses lifecycle/action helper code into typed
   expression and statement nodes. Calls, literals, variables, blocks, direct
   access, assignments, and receiver-dot chains must be represented structurally.
   Text-to-text helper rewriting is not a conforming design for new backends.

6. **User-function registry and resolver** — records top-level `fn name(args) { body }`
   definitions as validated AST-backed records before runtime. The registry must preserve
   definition order, expose definitions by name, reject helper/rule/reserved-name
   collisions, and resolve exact-arity value calls before unknown-helper fallback.

7. **Compiler** — transforms parsed entries and helper/action AST nodes into
   HandlerIR nodes. You can reuse the ActionIR lowering approach, but the input to
   lowering is structured AST/IR rather than raw helper source text.

8. **HandlerIR emitter** — consumes HandlerIR nodes and produces runnable code
   in your target language. Must handle all 10 variant kinds.

9. **Runtime** — the execution engine:
   - Regex engine with position tracking (equivalent to `//gcp` and `\G` anchoring).
   - Accumulator model (arrays, hashes, scalars).
   - Lifecycle execution engine (I/LS/LE/E/EX/IT/LX ordering).
   - BACKTRACK (local cursor save/restore).
   - Zero-progress guard.

10. **Test harness** — runs `tests/corpus/` entries and compares output to
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
| Test Corpus | `rust/linkedspec-runtime/tests/corpus/` | Manifest-backed language-neutral compliance tests |

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
