---
id: terse-type-method-surface-inventory
title: "Perl value/helper contracts"
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
  - "can Perl count and first run inside deferred codeblocks"
  - "can Perl sorted and take run inside a deferred codeblock"
  - "why do sorted numbers become strings after a container copy"
  - "which task owns deferred last count first indexed writes and registered sorted"
  - "why do malformed fluent arguments leak a Perl array-reference error"
  - "why do private count captures expect old defined guards"
date: 2026-10-22
status: bounded Perl; inventory pending
tags: [spec-format-terse, method-chaining, receiver-dot, audit, mdbook, rust-parity]
evidence: "Type epochs retained; count/first10 verified."
reverify: "bash tools/project_data_run.sh prove -Iperl t/scalar_numeric_contract.t"
---

# Value model and bounded Perl helper execution

Scalar/array/harray/codeblock bindings retain evaluated constructor/key/argument
values; deferred bodies read caller slots; updates use copy-on-write.
See [[perl-generic-final-codeblock-normalization]].

Scalar/aggregate Numeric policies differ. Shape checks precede effects;
comparisons/reducers terminate. Aggregates take one array; receivers no operands.
Scalar min/max evaluates operands before rejection. Perl checks each decimal
term: empty sum0, othersundef; Rust filters differently. Reducer95:
[[perl-numeric-reducer-string-result-kinds]]. Boolean35, Unicode20/constructor94
remain separate.

Deferred sorted/take have free/receiver forms. Lexical sort preserves copied
numeric/string kinds across clones/indexes; measure flags before Storable caches
private iOK on floats.
take defaults1; integer spelling only; negative/invalid0; oversized clamp.
Nonarrays yield[] and skip count; sources/results stay independent.
count/first execute deferred: free calls take one operand, terminal receivers none.
Nonarrays yield0/undef; first preserves kinds/callables; invalid shapes skip effects.
11 owns registered sorted/ordinary length,12 indexed writes,14 last.
Fluent args require arrays before preflight. Three private count goldens retain
native captures; current guards execute against arrays/nonarrays. No backend admission.

drop_keys copies keys/splices, keeps null diagnostics and FATAL-warning silence.
c053c9dcf inventories substr/typed receivers; references pending.

Accepted7 HTML: only the search-index reference differs; decoded changes are15
body-whitespace strings. Strict rejection remains.

Context hash-gates gzip/37 verified32MiB chunks and three byte/mode aliases;
nested-Git guards apply. Recursive originals:49ce.
