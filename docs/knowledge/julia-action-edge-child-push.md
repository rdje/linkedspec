---
id: julia-action-edge-child-push
title: Julia action-edge child push preserves whole and indexed child returns
answers:
  - does Julia support push child target
  - does Julia support push child index
  - why did Julia spec spec smokes return empty paragraphs
  - why did Julia EBNF lose structural tokens
  - why do Julia EBNF values still contain quotes after child push
  - what does JULIA-BACKEND-PARITY.6.2.4.4 prove
date: 2026-07-10
status: current
tags: [julia, runtime, action-edge, push, ebnf, spec-spec, corpus, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.6.2.4.4 traces ebnf_logging_annotation and spec_spec_minimal_rule and proves their child rules return correct structures through the current action edge while _call_runtime_push! misclassifies all-bare push(child, target) and literal push(child, index) as ordinary target/value append. Julia now gives a compiled-rule first argument child-call precedence, reuses the current edge's cached child result, supports implicit/explicit whole and indexed append forms, and keeps ordinary push(array(target), value) behavior. Focused coverage locks all four forms. All four spec.spec smokes pass. Both EBNF fixtures preserve complete structures and differ only at quoted strings because statement-form regex substr has not mutated its scalar target; that residual is routed to JULIA-BACKEND-PARITY.6.2.4.5.2. Full Pkg.test() passes with 793 assertions, shipped smoke is 25/31, and status is runtime-corpus-action-edge-child-push."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia -e 'using Pkg; Pkg.test()' && JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot /opt/homebrew/bin/julia --project=julia julia/bin/corpus_runner.jl --corpus rust/linkedspec-runtime/tests/corpus --execute --case ebnf_expression_rules --case ebnf_logging_annotation --case spec_spec_minimal_rule --case spec_spec_action_edge --case spec_spec_user_function_definition --case spec_spec_comment_skip || true"
---

Julia's parent action-edge regex already consumed the token that selected a child. Child-call `push(...)` forms
must therefore use that action edge's scoped child result instead of interpreting the arguments as an ordinary
target/value append or searching again from the advanced cursor.

Julia now supports the complete documented statement family:

- `push(Child)` appends the whole child result to the current rule accumulator.
- `push(Child, target)` appends the whole child result to an explicit accumulator.
- `push(Child, index)` selects a zero-based child-result item and appends it to the current rule accumulator.
- `push(Child, target, index)` selects and appends to an explicit accumulator.

A compiled-rule first bare argument establishes child-call precedence. Numeric disambiguation requires a literal
nonnegative integer. The current action edge caches and reuses its child result; another named child executes
normally. Explicit value append such as `push(array(items), value)` keeps its existing meaning.

This makes all four `spec.spec` smokes pass. EBNF now retains rule headers, rule references, groups, strings,
operators, and logging annotations. Its remaining mismatch is narrower: quoted-string rules use statement-form
regex `substr(...)`, which Julia does not yet apply as target mutation. That quote-only residual belongs to
`JULIA-BACKEND-PARITY.6.2.4.5.2` with the existing lib_reader normalization cases.

Related facts: [[rust-action-edge-child-return-dispatch]], [[dart-structural-pcre-parser-smoke-parity]],
[[julia-shipped-corpus-smoke-split]], [[julia-recursive-rule-local-reset-scope]].
