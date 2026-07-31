# ADR 0064: Expressive self-containment and EBNF-like authoring use one semantic core

- Date: 2026-07-30
- Status: accepted direction; contract and implementation pending under `SPEC-LANGUAGE-SELF-CONTAINMENT.1-.6`
- Tags: architecture, dsl, expressiveness, self-containment, ebnf, frontend, lowering, source-map, portability, parity

## Context

LinkedSpec's purpose is unusually centered on connected recursive rules, precise cursor control, and extracting or
transforming text from captured source boundaries. The director described the desired end state without treating
literal Turing-completeness as the goal: an author should not feel limited inside a `.spec` file when expressing
LinkedSpec's own parsing/extraction objectives. The director separately clarified that arbitrary interaction with
the outside world is probably unnecessary and may not move the project forward. The desired property is language
closure for the problem domain, not ambient host authority.

The director then proposed an alternative syntax that resembles EBNF as closely as possible while retaining full
LinkedSpec power underneath, including natural recursion, cursor movement, and capture from cursor-derived
positions. That idea is viable only if it does not create a misleading “standard EBNF” claim, a second semantics
engine, hidden cursor/action magic, or backend dialects.

Existing accepted architecture constrains the answer:

- ADR `0006` makes identical `.spec` meaning and HandlerIR the one portable backend contract.
- ADRs `0007` and `0035` require terse, readable, highly expressive authoring through small orthogonal mechanisms,
  not host callbacks or format-named special cases.
- ADR `0056` already owns the typed source-location, cursor, span, provenance, recursion-progress, and parser-
  composition algebra that future syntax must project rather than reinvent.
- ADRs `0049`/`0050` require semantic introspection and staged artifacts to describe one native semantic model;
  MCP remains a thin projection rather than another owner.

## Decision

### 1. Define expressive self-containment for LinkedSpec's problem domain

The target language can express normal objectives involving grammar, recursive parser composition, cursor and
source-location control, capture intervals, scoped typed state, callable abstractions, branching, iteration,
transformation, and typed result construction without routine backend-host escape hatches.

This is a governed problem-domain closure claim, not a claim of unrestricted computation. Acceptance depends on
representative executable objectives and a capability/gap ledger, not on using “Turing complete” as shorthand.
Resource bounds, progress guarantees, deterministic semantics, typed failures, and portable behavior remain part
of the definition.

### 2. Keep outside-world effects outside the default `.spec` language

Self-containment grants no implicit filesystem, process, network, environment, clock, randomness, package-loading,
or host-FFI authority. Host runtimes remain the substrate and caller-owned input/result boundary. A future external
effect would require its own explicit capability, authorization, determinism, security, storage, diagnostic, and
five-backend contract; it cannot arrive as an incidental escape hatch for an expressiveness gap.

### 3. Retain one canonical semantic model and runtime path

Ordinary `.spec` syntax and every accepted authoring profile lower into one versioned canonical AST/HandlerIR
contract. They share validation, compilation, runtime semantics, serialization/reconstruction, generated source,
semantic introspection, MCP projection, diagnostics, and resource policy. A profile cannot introduce nodes with
profile-only execution meaning, bypass validation, or own a second evaluator.

The five native implementations—Perl reference, Rust, Dart, Julia, and Lua on both supported ABIs—implement that
one contract. Source spelling may differ by profile; observable semantics may not.

### 4. Accept an optional EBNF-like profile, not a claim of literal EBNF identity

The proposed alternative syntax is accepted in principle as an optional authoring frontend. It should preserve
familiar EBNF production, sequence, choice, grouping, optionality, repetition, terminal, and nonterminal notation
only where LinkedSpec semantics honestly agree.

A normative semantic-difference table must make ordered matching, seek/consume policy, forward cursor movement,
explicit local rewind/transactions, capture boundaries, state/actions, result construction, and failure/progress
semantics visible. LinkedSpec-only powers use explicit, composable extensions rather than silently overloading
standard-looking EBNF punctuation. Awkward real examples trigger profile redesign; compiler magic may not conceal
the difference.

### 5. Make lowering lossless and diagnostics author-facing

The canonical representation retains profile identity, original source, exact Unicode-scalar spans, authored-to-
canonical node correspondence, and deterministic diagnostic remapping. Invalid syntax and semantic/runtime
failures point to the form the author wrote. Generated or reconstructed execution preserves that provenance rather
than exposing only synthetic canonical text.

Where two ordinary/profile inputs are semantically equivalent, independent tooling must prove equal canonical
semantic digests and runtime behavior while allowing their authored source identities/spans to remain distinct.

### 6. Prove core expressiveness before implementing alternate syntax

The program first inventories current capabilities and host-dependent gaps, defines neutral self-containment
fixtures, and closes only evidence-backed missing core primitives. The EBNF-like profile may not mask missing
semantics in its frontend. Its design is tried against real recursive, cursor-sensitive, capture-heavy, stateful,
and transformation-heavy formats before backend implementation.

### 7. Preserve current scheduling and claims

This record changes architecture/governance only. It adds no current syntax, parser/compiler/runtime behavior,
descriptor/version, generated format, semantic/MCP response, capability status, backend admission, or public claim
that an EBNF-like profile already exists. After the behavior-free `.0` routing leaf commits cleanly, the active
callable-codeblock backend-parity program remains next unless the director explicitly reprioritizes from a clean
boundary.

## Consequences

- “Self-contained” now has a precise positive and negative boundary: rich portable language expression inside the
  parsing/extraction domain, no default ambient effects.
- Host-language callbacks are not an acceptable substitute for a missing portable primitive. A real gap becomes a
  neutral contract and five-backend obligation or stays explicitly unsupported.
- The EBNF-like idea is preserved as a serious design direction while avoiding a deceptive literal-EBNF promise.
- One canonical model prevents ordinary/profile/backend drift and lets existing generated, semantic, MCP, and
  diagnostic machinery remain shared.
- Exact source maps and semantic digests become mandatory frontend infrastructure, not optional tooling polish.
- `SPEC-LANGUAGE-SELF-CONTAINMENT.1-.6` owns the inventory, contract, core-gap closure, profile design, five-backend
  implementation, examples/migration, and no-drift signoff.

## Links

- Owning tree: `docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md`
- Universal contract and HandlerIR: ADR `0006`
- Terse/readable/expressive authoring: ADRs `0007`, `0035`
- Typed source-location/cursor algebra: ADR `0056`
- Semantic model and staged artifacts: ADRs `0049`, `0050`
- Structured-text evidence program: ADR `0034` and `docs/tasks/STRUCTURED-TEXT-FORMAT-PROGRAM.md`
