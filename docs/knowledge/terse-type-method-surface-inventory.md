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
date: 2026-10-21
status: bounded Perl value/numeric/drop/aggregate repairs; inventory pending
tags: [spec-format-terse, method-chaining, receiver-dot, audit, mdbook, rust-parity]
evidence: "TYPE-REFERENCE-BOOK.1.2.3-.7 retain actual source/fault epochs. Aggregate7 binds portable input custody;95/9 remain owned."
reverify: "bash tools/run_python_project_data.sh docs/checkpoints/type-aggregate-codeblocks/publish_portable.py"
---

# Value model and bounded Perl helper execution

Bindings hold scalar/array/harray/codeblock. Generic with passes false; deferred
bodies read caller slots. Constructors/keys/arguments retain evaluated values;
updates use copy-on-write. Scoped with: [[perl-generic-final-codeblock-normalization]].

Scalar and aggregate Numeric dispatch differ. Shape checks precede effects;
comparisons/reducers terminate. Complete undef prevents emitted fallthrough.
Aggregates take one array, receiver reducers no arguments. Explicit min/max
operands evaluate before rejection. Perl checks every term with legacy decimal
rules: empty sum0, othersundef; Rust filtering differs.

[[perl-numeric-reducer-string-result-kinds]] owns selected-string defect95:
numeric JSON can hide string-kind index rejection. Boolean35/Unicode20/
constructor94 stay separate. Deferred sorted/take raises unknown_helper:sorted,
owned next9; availability admits no whole family/backend.

drop_keys materializes private keys/splices from copied harrays, remains quiet
under FATAL warnings and retains source/null diagnostics. Prior numeric/drop
epochs survive. The dated c053c9dcf inventory included substr/typed receivers;
inventory1 follows7/9, then mapping/layout. Rejected preparations stay retained.

The paired builds reproduce both measured pages exactly. Their only normalized
HTML difference is the generated search-index filename. Decoded indexes differ
only in15 chapter-body whitespace strings; all other fields match. The reader
verifies these actual payloads before normalizing that single reference. The
initial strict comparator rejection stays retained. This is a bounded observed
reflow result, not permission to ignore arbitrary asset or search changes.

Context stopped embedding immutable gzip/chunks. Oversized drafts recover from37 verified32MiB parts into ignored local aliases; exact bytes/modes and nested-repository guards remain checked. Old recursive snapshots stay retained.
