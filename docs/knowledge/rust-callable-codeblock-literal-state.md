---
id: rust-callable-codeblock-literal-state
title: Rust preserves callable codeblock literals as inert typed state
answers:
  - "does Rust parse callable codeblock literals"
  - "can Rust construct a {|params| body } codeblock"
  - "what fields are in a Rust callable codeblock value"
  - "does constructing a Rust codeblock execute its body"
  - "does a Rust callable codeblock capture a closure or environment"
  - "are Rust callable codeblock spans byte or character offsets"
  - "does emitted Rust preserve callable codeblocks"
  - "does Rust semantic introspection report codeblock signatures"
  - "can Rust invoke a codeblock variable with cb parentheses"
  - "does Rust Expr Display preserve authored source or serialize typed state"
  - "how does the Rust expression parser byte cursor differ from callable spans"
date: 2026-09-07
status: current
tags: [rust, actionir, codeblock, callable, generated-source, semantic-introspection, FUTURE-PARITY-BACKLOG]
evidence: "The seven construction tests and nine diagnostics below are the July 2026 milestone evidence, not a September native rerun. FUTURE-PARITY-BACKLOG.11.4.1 adds exact {| recognition, the neutral eight-field literal/fixed-rest signature record, Unicode character-coordinate spans, inert RuntimeValue state, compiled JSON and generated-source preservation, and semantic codeblock shapes. Seven focused construction tests cover the neutral literal inventory, nine diagnostics, non-execution, user-function transport, eager-dependency isolation, and descriptors; dynamic invocation subsequently lands in .11.4.2. SESSION-STARTUP-READING.3.3.5 rechecks unchanged expression carrier and parser source, distinguishing byte cursors, character spans, and debug Display."
reverify: "bash tools/run_python_project_data.sh tools/check_callable_codeblock_contract.py && bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test callable_codeblock_literal_contract"
---

# Rust Callable Codeblock Literal State

Rust recognizes exact `{|params| body }` and `{|| body }` before its existing harray and eager-block brace
classifiers. A valid literal is one plain serializable `codeblock_literal` record with exactly eight top-level
fields: `kind`, `version`, `signature`, `body_source`, `body_ast`, `source_text`, `source_span`, and `body_span`.
The signature reuses the neutral fixed/final-rest schema; the body is typed ActionIR, not Rust source.

Literal and body spans are half-open Unicode character offsets in the containing ActionIR source. Nested literals
retain that same coordinate space rather than resetting inside the outer body. Construction produces
`RuntimeValue::Codeblock`, is truthy/non-text/non-numeric data, captures no environment, and never evaluates the
body. Eager action-edge dependency scans likewise ignore calls and `retv` reads inside the retained body.

The one `CompiledSpec` serde representation carries the record through JSON reconstruction. User functions can
receive and return it as ordinary data. Generated Rust embeds that same serialized compiled state and introduces
no `Fn`, closure, or capture object. Semantic binding projection reports `kind = codeblock` plus the exact
fixed/rest callable signature.

Construction/state remains inert, while bound-variable dispatch such as `cb(args)` is now current through
`FUTURE-PARITY-BACKLOG.11.4.2`; generic attached/parenthesized final blocks are also
current through `.11.4.3`, documented in [[rust-generic-final-codeblock-normalization]].

Reading checkpoint `SESSION-STARTUP-READING.3.3.5` confirms that the expression
parser's `pos` is a byte cursor, while `ExpressionSpan` is explicitly a half-open
character span and nested parsing retains a `character_base`. Retained authored
`source_text`, `body_source`, and typed serde state are independent of formatting.

`Expr::Display` is explicitly a debugging surface. Some variants write retained
source; others reconstruct text, and staged parse-job nodes print Debug text plans
and options. This is not a general authored-source round-trip or serialization
contract. Selected round-trip examples do not establish one for every typed node.
The September checkpoint records source-reading evidence and neutral staged/write
checks, without rerunning the historical native construction suite.

Checkpoint `.3.3.8` reads the remaining expression tests through EOF. The general
`assert_roundtrip` helper compares selected expressions after Display/parse, but
the fluent-chain tests inspect only selected structure and the trailing serde tests
check decode success or statement count. The nested-write test separately checks
complete typed equality. These differing assertions must not be summarized as one
exhaustive AST or authored-source round-trip guarantee.

Related facts: [[callable-codeblock-literal-contract]], [[perl-callable-codeblock-literal-record]],
[[rust-callable-codeblock-dynamic-invocation]], [[variadic-callable-signature-seams]].

## September 7 callable consumer prefix reading

`SESSION-STARTUP-READING.3.3.41` reads test lines 1–791: 27,469 baseline-identical bytes,
SHA-256 `7b867d0449c8b168d28d85b994ceb97ba2c075130d63c455d76fdbd7b1d54e21`.
This is partial physical coverage of the 958-line consumer; the final tests remain the next leaf.
The prefix checks exact literal field sets and retained source/body, signatures and spans, Unicode containing
coordinates, inert construction/copy/function transport, dependency-scan isolation and compiled JSON equality.
Generated construction checks inspect source strings and execute the generated-plan route; a separate test
creates a unique repository-local Cargo workspace, builds emitted fixture/failure modules offline, executes
them and attempts removal of that exact owned workspace through Drop. Reading that test is not a new emitted execution.

Invalid literal tests require the expected code to occur in the parser error string. They do not compare
a full structured diagnostic envelope. Fresh neutral checking passes 7 literals, 11 calls, 9 invalid
literals, 7 invalid calls, 4 invalid declarations, 8 contextual forms and 23 governance mutations.
The historical native milestone counts above remain dated evidence.

## September 8 consumer reading completion

Checkpoint SESSION-STARTUP-READING.3.3.42 reads the remaining 792–958 lines, completing physical coverage of the 958-line consumer. Its semantic binding test requires codeblock shape plus the fixed/rest callable signature. Fresh validation is the neutral contract; no native consumer rerun is claimed.
