---
id: terse-type-method-surface-inventory
title: "Value kinds and Perl evaluated-value boundaries; dated method inventory"
answers:
  - "what receiver methods already exist in the terse type method surface"
  - "does string substr already work as a method"
  - "which helpers should remain function only or statement only"
  - "what did SPEC-FORMAT-TERSE.7.1 inventory"
  - "which method backfill leaf follows SPEC-FORMAT-TERSE.7.1"
  - "do block yielded values and user function returns have their own method table"
  - "why did a later callback change an earlier Perl array element"
  - "do Perl hash keys and callable arguments retain evaluated values"
  - "can Perl num_add run inside a deferred codeblock"
  - "does Perl drop_keys warn for a single literal key"
  - "why does Perl drop_keys ignore flat_array keys"
  - "why can a later drop key callback change an earlier key"
  - "why can a later numeric operand change an earlier value"
  - "can Perl numeric comparison receivers continue into cat"
  - "can Perl sum run inside a deferred codeblock"
  - "why does invalid aggregate receiver arity reach a host function"
  - "why did prose reflow change otherwise identical rendered book HTML"
  - "how is the generated mdBook search-index reference compared"
  - "why did checkpoint input snapshots grow recursively"
  - "how do checkpoint chunks restore data and reject nested Git roots"
  - "can Perl sorted and take run inside a deferred codeblock"
  - "why do sorted numbers become strings after a container copy"
  - "which task owns deferred count first indexed writes and registered sorted"
  - "why do malformed fluent arguments leak a Perl array-reference error"
date: 2026-10-21
status: bounded Perl helpers; sorted-kind13 and inventory pending
tags: [spec-format-terse, method-chaining, receiver-dot, audit, mdbook, rust-parity]
evidence: "Type3-.9 retain exact epochs;9 admits only callable sorted/take. kind13/10/11/12 remain owned."
reverify: "bash tools/run_python_project_data.sh docs/checkpoints/type-array-pipelines/publish.py"
---

# Value model and bounded Perl helper execution

Bindings hold scalar/array/harray/codeblock; deferred bodies read caller slots.
Constructors, keys and arguments retain evaluated values; updates use copy-on-write.
Scoped with: [[perl-generic-final-codeblock-normalization]].

Scalar/aggregate Numeric policies differ. Shape checks precede effects;
comparisons/reducers terminate. Aggregates take one array; receiver reducers no
operands. Explicit scalar min/max evaluates operands before rejection. Legacy
Perl checks every decimal term: empty sum0, othersundef; Rust filtering differs.
[[perl-numeric-reducer-string-result-kinds]] owns reducer95. Boolean35,
Unicode20/constructor94 remain separate.

Perl callable sorted/take now execute free/receiver forms. Sort is lexical;
take defaults1, integer spelling only, negative/invalid0, oversized counts clamp.
Non-arrays yield[] and skip count; sources stay independent.13 owns sorted/copy
kinds next: comparison adds POK; Storable
clone drops numeric flags. Actual array-index writes reject.10 owns deferred
count/first,11 registered sorted/ordinary length,12 deferred indexed writes.
Serialized fluent args require arrays before preflight.
No family/backend admission.

drop_keys copies keys/splices, stays FATAL-warning quiet and retains null
diagnostics. c053c9dcf inventoried substr/typed receivers; references remain pending.

Accepted7 builds reproduce both pages except their search-index reference.
Decoded indexes differ only in15 body-whitespace strings; other fields match.
The strict rejection survives. Verify payloads before normalizing that reference;
this grants no general asset normalization.

Context hash-gates immutable gzip/chunks without embedding.37 verified32MiB parts
restore three exact byte/mode aliases with nested-repository guards. Old recursive
snapshots survive at accepted49ce.
