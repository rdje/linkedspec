---
id: julia-callable-codeblock-literal-state
title: Julia preserves callable codeblock literals as inert typed state
answers:
  - "does Julia parse callable codeblock literals"
  - "can Julia construct a {|params| body } codeblock"
  - "what fields are in a Julia callable codeblock value"
  - "does constructing a Julia codeblock execute its body"
  - "does a Julia callable codeblock capture a closure or environment"
  - "are Julia callable codeblock spans byte or Unicode character offsets"
  - "does emitted Julia preserve callable codeblocks"
  - "does Julia semantic introspection report codeblock signatures"
  - "can a Julia variadic user function have a null rest parameter"
  - "can Julia invoke a codeblock variable with cb parentheses"
date: 2026-07-30
status: current
tags: [julia, actionir, codeblock, callable, generated-source, semantic-introspection, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.11.6.1 adds exact {| recognition, the neutral eight-field literal/fixed-rest signature record, containing Unicode-character-coordinate literal/body spans, inert plain-data runtime state, compiled JSON and generated-source preservation, and semantic codeblock shapes. FUTURE-PARITY-BACKLOG.11.6.2 adds dynamic bound invocation without changing construction. Focused proof passes 239 construction plus 125 invocation assertions across native/reconstructed/generated/emitted roles; the complete Julia package and local gate pass."
reverify: "bash tools/run_python_project_data.sh tools/check_callable_codeblock_contract.py && bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT=pwd(); include(\"julia/test/callable_codeblock_literal_contract_test.jl\")' && bash tools/run_julia_local.sh"
---

# Julia Callable Codeblock Literal State

Julia recognizes exact `{|params| body }` and `{|| body }` before its existing harray and eager-block brace
classifiers. A valid literal is one plain serializable `codeblock_literal` record with exactly eight top-level
fields: `kind`, `version`, `signature`, `body_source`, `body_ast`, `source_text`, `source_span`, and `body_span`.
The shared signature type now represents fixed signatures with `rest_param = null` as well as final-rest
signatures. This nullable form is limited to fixed literals: Julia's validator still rejects a reconstructed
variadic user-function signature whose rest name is null.

Literal and body spans are half-open Unicode character offsets in the containing ActionIR source. Nested literals
retain the same coordinate space. The retained body is typed ActionIR, not Julia source, and is a deferred leaf
for eager helper/dependency and removed-selector scans. Runtime construction returns a recursively copied plain
dictionary, captures no environment, and never executes body mutations, calls, or `retv` reads.

The ordinary compiled ActionIR payload carries the record. User functions can receive and return it as ordinary
data. Generated-plan execution uses compiled state, while emitted Julia embeds normalized `SpecFile` JSON and
reconstructs it through the same compiler/runtime path in a freshly loaded module. No Julia closure, callback
object, or second generated executor is introduced. Semantic binding projection reports `kind = codeblock` plus
the exact fixed/rest callable signature.

Construction/state remains intentionally inert. Bound-variable dispatch such as `cb(args)` is now implemented by
`FUTURE-PARITY-BACKLOG.11.6.2` without changing the stored record; generic attached/parenthesized final blocks
remain `.11.6.3`.

Related facts: [[callable-codeblock-literal-contract]], [[julia-callable-codeblock-construction-gap]],
[[julia-variadic-user-functions]], [[julia-generated-source-scaffold]],
[[julia-callable-codeblock-dynamic-invocation]], [[dart-callable-codeblock-literal-state]],
[[rust-callable-codeblock-literal-state]].
