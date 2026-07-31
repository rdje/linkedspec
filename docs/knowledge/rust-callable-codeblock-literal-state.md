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
date: 2026-07-30
status: current
tags: [rust, actionir, codeblock, callable, generated-source, semantic-introspection, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.11.4.1 adds exact {| recognition, the neutral eight-field literal/fixed-rest signature record, Unicode character-coordinate spans, inert RuntimeValue state, compiled JSON and generated-source preservation, and semantic codeblock shapes. Seven focused construction tests cover the neutral literal inventory, nine diagnostics, non-execution, user-function transport, eager-dependency isolation, and descriptors; dynamic invocation subsequently lands in .11.4.2."
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
`FUTURE-PARITY-BACKLOG.11.4.2`; generic attached/parenthesized final blocks remain `.11.4.3`.

Related facts: [[callable-codeblock-literal-contract]], [[perl-callable-codeblock-literal-record]],
[[rust-callable-codeblock-dynamic-invocation]], [[variadic-callable-signature-seams]].
